package asteroids

import "core:fmt"
import "core:math/rand"
import "core:mem"
import "core:strings"
import rl "vendor:raylib"

WINDOW_WIDTH :: 2000
WINDOW_HEIGHT :: 2000
TARGET_FPS :: 60
SCORE_TEXT_SIZE :: 50

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	player: Player
	player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}

	bullets := make([dynamic]Bullet)
	defer delete(bullets)

	asteroids := make([dynamic]Asteroid)
	defer delete(asteroids)

	asteroid_spawn_counter: uint = 100
	score: uint = 0

	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")
	rl.SetTargetFPS(TARGET_FPS)

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// Update
		if rl.IsKeyDown(.W) do player.vel += rl.Vector2Rotate(rl.Vector2{0, -1} * PLAYER_SPEED, player.angle)
		// if rl.IsKeyDown(.S) do player.vel = rl.Vector2MoveTowards(player.vel, {0, 0}, PLAYER_SPEED / 3)
		if rl.IsKeyDown(.A) do player.angle -= PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.D) do player.angle += PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.SPACE) && player.shoot_timer == 0 {
			append(&bullets, make_bullet(player))
			player.shoot_timer = PLAYER_SHOOT_DELAY
		}


		if asteroid_spawn_counter == 0 && len(asteroids) < MAX_ASTEROIDS {
			append(&asteroids, make_asteroid_rand())
			asteroid_spawn_counter = uint(rand.int_range(ASTEROID_MIN_DELAY, ASTEROID_MAX_DELAY))
		} else if asteroid_spawn_counter != 0 && len(asteroids) < MAX_ASTEROIDS do asteroid_spawn_counter -= 1

		update_player(&player, dt)
		update_bullets(&bullets, dt)
		update_asteroids(&asteroids, dt, &bullets, &score)

		shrink(&asteroids)

		score_text := strings.clone_to_cstring(
			fmt.aprintf("Score: %v", score, allocator = context.temp_allocator),
			context.temp_allocator,
		)

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		draw_player(player)
		draw_bullets(bullets[:])
		draw_asteroids(asteroids[:])

		rl.DrawText(
			score_text,
			i32((WINDOW_WIDTH / 2) - (rl.MeasureText(score_text, SCORE_TEXT_SIZE) / 2)),
			50,
			SCORE_TEXT_SIZE,
			rl.WHITE,
		)

		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}
