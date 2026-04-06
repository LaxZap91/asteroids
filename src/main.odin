package asteroids

import "core:fmt"
import "core:math/rand"
import "core:mem"
import "core:strings"
import rl "vendor:raylib"

// Width of the game window
WINDOW_WIDTH :: 2000
// Height of the game window
WINDOW_HEIGHT :: 2000
// Target fps of the game
TARGET_FPS :: 60

// Font size of the score text
SCORE_TEXT_SIZE :: 50
// Font size of the title text
TITLE_TEXT_SIZE :: 300
// Font size of the high score text
HIGH_SCORE_TEXT_SIZE :: 100
// Font size of the start text
START_TEXT_SCORE :: 50
// State of the game
GAME_STATE :: enum {
	MENU,
	GAME,
}

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

	// Initialize game variables
	game_state: GAME_STATE
	high_score: uint

	player: Player
	player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}

	bullets := make([dynamic]Bullet)
	defer delete(bullets)

	asteroids := make([dynamic]Asteroid)
	defer delete(asteroids)

	menu_asteroids: [MAX_ASTEROIDS]Asteroid
	for i in 0 ..< MAX_ASTEROIDS {
		menu_asteroids[i] = make_asteroid_rand()
	}

	asteroid_spawn_counter: uint = ASTEROID_DEFAULT_SPAWN_COUNTER
	score: uint = 0

	// Initialize raylib window
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")
	rl.SetTargetFPS(TARGET_FPS)

	// Game loop
	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// Update game
		if game_state == .GAME {
			update_game(&player, &bullets, &asteroids, &asteroid_spawn_counter, &score, dt)
			if player.state == .Dead {
				game_state = .MENU
				if score > high_score do high_score = score
				score = 0
			}
		} else {
			if rl.IsKeyDown(.SPACE) {
				game_state = .GAME

				reset_game(&player, &bullets, &asteroids, &asteroid_spawn_counter)
			}

			update_menu_asteroids(menu_asteroids[:], dt)
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		// Draw game
		if game_state == .GAME {
			draw_game(player, bullets[:], asteroids[:], score)
		} else {
			draw_asteroids(menu_asteroids[:])
			draw_menu(high_score)
		}

		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}

// Updates the state of the game
update_game :: proc(
	player: ^Player,
	bullets: ^[dynamic]Bullet,
	asteroids: ^[dynamic]Asteroid,
	asteroid_spawn_counter: ^uint,
	score: ^uint,
	dt: f32,
) {
	if player.state == .Alive {
		// Get keyboard input
		if rl.IsKeyDown(.W) do player.vel += rl.Vector2Rotate(rl.Vector2{0, -1} * PLAYER_SPEED, player.angle)
		// if rl.IsKeyDown(.S) do player.vel = rl.Vector2MoveTowards(player.vel, {0, 0}, PLAYER_SPEED / 3)
		if rl.IsKeyDown(.A) do player.angle -= PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.D) do player.angle += PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.SPACE) && player.shoot_timer == 0 {
			append(bullets, make_bullet(player^))
			player.shoot_timer = PLAYER_SHOOT_DELAY
		}
	}

	// Update game objects
	if asteroid_spawn_counter^ == 0 && len(asteroids) < MAX_ASTEROIDS {
		append(asteroids, make_asteroid_rand())
		asteroid_spawn_counter^ = uint(rand.int_range(ASTEROID_MIN_DELAY, ASTEROID_MAX_DELAY))
	} else if asteroid_spawn_counter^ > 0 && len(asteroids) < MAX_ASTEROIDS do asteroid_spawn_counter^ -= 1

	update_player(player, dt, asteroids[:])
	update_bullets(bullets, dt)
	update_asteroids(asteroids, dt, bullets, score)
}

// Draws the game
draw_game :: proc(player: Player, bullets: []Bullet, asteroids: []Asteroid, score: uint) {
	draw_player(player)
	draw_bullets(bullets)
	draw_asteroids(asteroids)

	score_text := strings.clone_to_cstring(
		fmt.aprintf("Score: %v", score, allocator = context.temp_allocator),
		context.temp_allocator,
	)
	rl.DrawText(
		score_text,
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText(score_text, SCORE_TEXT_SIZE) / 2)),
		50,
		SCORE_TEXT_SIZE,
		rl.WHITE,
	)
}

// Draws the menu
draw_menu :: proc(high_score: uint) {
	rl.DrawText(
		"Asteroids",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Asteroids", TITLE_TEXT_SIZE) / 2)),
		i32(WINDOW_HEIGHT / 3),
		TITLE_TEXT_SIZE,
		rl.WHITE,
	)

	high_score_text := strings.clone_to_cstring(
		fmt.aprintf("High Score: %v", high_score, allocator = context.temp_allocator),
		context.temp_allocator,
	)
	rl.DrawText(
		high_score_text,
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText(high_score_text, HIGH_SCORE_TEXT_SIZE) / 2)),
		i32(WINDOW_HEIGHT / 2),
		HIGH_SCORE_TEXT_SIZE,
		rl.WHITE,
	)

	rl.DrawText(
		"PRESS SPACE TO PLAY",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("PRESS SPACE TO PLAY", START_TEXT_SCORE) / 2)),
		i32(WINDOW_HEIGHT / 2) + START_TEXT_SCORE + HIGH_SCORE_TEXT_SIZE,
		START_TEXT_SCORE,
		rl.WHITE,
	)
}

// Resets the state of the game
reset_game :: proc(
	player: ^Player,
	bullets: ^[dynamic]Bullet,
	asteroids: ^[dynamic]Asteroid,
	asteroid_spawn_counter: ^uint,
) {
	// Resets player
	player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
	player.vel = {0, 0}
	player.angle = 0
	player.state = .Alive

	// Resets bullets
	clear(bullets)
	shrink(bullets)

	// Resets asteroids
	clear(asteroids)
	shrink(asteroids)
	asteroid_spawn_counter^ = 100
}
