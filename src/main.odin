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

State :: struct {
	game_state:             GAME_STATE,
	high_score:             uint,
	score:                  uint,
	player:                 Player,
	bullets:                [dynamic; BULLET_MAX]Bullet,
	asteroids:              [dynamic; ASTEROID_MAX]Asteroid,
	menu_asteroids:         [ASTEROID_SOFT_MAX]Asteroid,
	particles:              [dynamic]Particle,
	restart_delay:          uint,
	asteroid_spawn_counter: uint,
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

	// Initialize game state
	state := make_state()
	defer delete_state(&state)

	// Initialize raylib window
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_UNDECORATED})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")
	rl.SetTargetFPS(TARGET_FPS)

	// Game loop
	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// Update game
		if state.game_state == .GAME {
			update_game(&state, dt)
		} else {
			update_menu(&state, dt)
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		// Draw game
		if state.game_state == .GAME {
			draw_game(&state)
		} else {
			draw_menu(&state)
		}

		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}

// Creates and initializes state
make_state :: proc() -> (state: State) {
	state.player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
	state.particles = make([dynamic]Particle)

	for i in 0 ..< ASTEROID_SOFT_MAX {
		state.menu_asteroids[i] = make_asteroid_rand()
	}

	state.asteroid_spawn_counter = ASTEROID_MIN_DELAY

	return
}

delete_state :: proc(state: ^State) {
	delete(state.particles)
}

// Updates the state of the menu
update_menu :: proc(state: ^State, dt: f32) {
	if state.restart_delay == 0 && rl.IsKeyDown(.SPACE) {
		reset_game_full(state)
	} else if state.restart_delay > 0 {
		state.restart_delay -= 1
	}

	update_menu_asteroids(state.menu_asteroids[:], dt)
}

// Updates the state of the game
update_game :: proc(state: ^State, dt: f32) {
	if state.player.state == .Dead && state.player.death_timer == 0 {
		if state.player.lives == 0 {
			state.game_state = .MENU
			if state.score > state.high_score {
				state.high_score = state.score
			}
			state.score = 0
			state.restart_delay = 10
		} else {
			reset_game_respawn(state)
		}
	}

	// Update game objects
	if state.asteroid_spawn_counter == 0 && len(state.asteroids) < ASTEROID_SOFT_MAX {
		append(&state.asteroids, make_asteroid_rand())
		state.asteroid_spawn_counter = uint(rand.int_range(ASTEROID_MIN_DELAY, ASTEROID_MAX_DELAY))
	} else if state.asteroid_spawn_counter > 0 && len(state.asteroids) < ASTEROID_SOFT_MAX {
		state.asteroid_spawn_counter -= 1
	}

	update_player(state, dt)
	update_bullets(state, dt)
	update_asteroids(state, dt)
	update_particles(state, dt)
}

// Draws the game
draw_game :: proc(state: ^State) {
	draw_player(state.player)
	draw_player_lives(state.player)
	draw_bullets(state.bullets[:])
	draw_asteroids(state.asteroids[:])
	draw_particles(state.particles[:])

	score_text := strings.unsafe_string_to_cstring(fmt.tprintf("Score: %v", state.score))
	rl.DrawText(score_text, (PLAYER_WIDTH / 2) * PLAYER_SCALE + 15, 50, SCORE_TEXT_SIZE, rl.WHITE)
}

// Draws the menu
draw_menu :: proc(state: ^State) {
	draw_asteroids(state.menu_asteroids[:])

	rl.DrawText(
		"Asteroids",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Asteroids", TITLE_TEXT_SIZE) / 2)),
		i32(WINDOW_HEIGHT / 3),
		TITLE_TEXT_SIZE,
		rl.WHITE,
	)

	high_score_text := strings.unsafe_string_to_cstring(
		fmt.tprintf("High Score: %v", state.high_score),
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

// Fully resets the state of the game
reset_game_full :: proc(state: ^State) {
	state.game_state = .GAME

	// Resets player
	state.player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
	state.player.vel = {0, 0}
	state.player.angle = 0
	state.player.shoot_timer = 0
	state.player.death_timer = PLAYER_DEATH_DELAY
	state.player.lives = PLAYER_MAX_LIVES
	state.player.state = .Alive

	// Resets bullets
	clear(&state.bullets)

	// Resets asteroids
	clear(&state.asteroids)
	state.asteroid_spawn_counter = ASTEROID_MIN_DELAY

	// Resets particles
	clear(&state.particles)
	shrink(&state.particles)
}

// Resets the game for respawn
reset_game_respawn :: proc(state: ^State) {
	state.player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
	state.player.vel = {0, 0}
	state.player.angle = 0
	state.player.shoot_timer = 0
	state.player.death_timer = PLAYER_DEATH_DELAY
	state.player.state = .Alive

	// Resets bullets
	clear(&state.bullets)

	// Resets asteroids
	clear(&state.asteroids)
	state.asteroid_spawn_counter = ASTEROID_MIN_DELAY

	// Resets particles
	clear(&state.particles)
	shrink(&state.particles)
}
