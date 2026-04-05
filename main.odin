package asteroids

import "core:fmt"
import rl "vendor:raylib"
import "core:mem"

WINDOW_WIDTH :: 2000
WINDOW_HEIGHT :: 2000
TARGET_FPS :: 60

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

	for _ in 0..<10 {
		append(&asteroids, make_asteroid_rand())
	}

	rl.SetTraceLogLevel(.WARNING)
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")
	rl.SetTargetFPS(TARGET_FPS)

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// Update
		if rl.IsKeyDown(.W) do player.vel += rl.Vector2Rotate(rl.Vector2{0, -1} * PLAYER_SPEED, player.angle)
		// if rl.IsKeyDown(.S) do player.vel -= rl.Vector2Rotate(rl.Vector2{0, -1} * PLAYER_SPEED, player.angle)
		if rl.IsKeyDown(.A) do player.angle -= PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.D) do player.angle += PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.SPACE) && player.shoot_timer == 0 {
			append(&bullets, make_bullet(player))
			player.shoot_timer = PLAYER_SHOOT_DELAY
		}

		update_player(&player, dt)
		update_bullets(&bullets, dt)
		update_asteroids(&asteroids, dt, &bullets)

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		draw_player(player)
		draw_bullets(bullets[:])
		draw_asteroids(asteroids[:])

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
