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

	bullets: [dynamic; BULLET_MAX]Bullet

	asteroids: [dynamic; ASTEROID_MAX]Asteroid

	particles := make([dynamic]Particle)
	defer delete(particles)

	menu_asteroids: [ASTEROID_SOFT_MAX]Asteroid
	for i in 0 ..< ASTEROID_SOFT_MAX {
		menu_asteroids[i] = make_asteroid_rand()
	}

	asteroid_spawn_counter: uint = ASTEROID_MIN_DELAY
	score: uint
	restart_delay: uint

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
			if player.state == .Dead && player.death_timer == 0 {
				if player.lives == 0 {
					game_state = .MENU
					if score > high_score do high_score = score
					score = 0
					restart_delay = 10
				} else {
					reset_game_respawn(
						&player,
						&bullets,
						&asteroids,
						&particles,
						&asteroid_spawn_counter,
					)
				}
			}

			update_game(
				&player,
				&bullets,
				&asteroids,
				&particles,
				&asteroid_spawn_counter,
				&score,
				dt,
			)
		} else {
			if restart_delay == 0 {
				if rl.IsKeyDown(.SPACE) {
					game_state = .GAME

					reset_game_full(
						&player,
						&bullets,
						&asteroids,
						&particles,
						&asteroid_spawn_counter,
					)
				}
			} else if restart_delay > 0 do restart_delay -= 1

			update_menu_asteroids(menu_asteroids[:], dt)
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		// Draw game
		if game_state == .GAME {
			draw_game(player, bullets[:], asteroids[:], particles[:], score)
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
	bullets: ^[dynamic; BULLET_MAX]Bullet,
	asteroids: ^[dynamic; ASTEROID_MAX]Asteroid,
	particles: ^[dynamic]Particle,
	asteroid_spawn_counter: ^uint,
	score: ^uint,
	dt: f32,
) {
	// Update game objects
	if asteroid_spawn_counter^ == 0 && len(asteroids) < ASTEROID_SOFT_MAX {
		append(asteroids, make_asteroid_rand())
		asteroid_spawn_counter^ = uint(rand.int_range(ASTEROID_MIN_DELAY, ASTEROID_MAX_DELAY))
	} else if asteroid_spawn_counter^ > 0 && len(asteroids) < ASTEROID_SOFT_MAX do asteroid_spawn_counter^ -= 1

	update_player(player, asteroids[:], bullets, particles, dt)
	update_bullets(bullets, dt)
	update_asteroids(asteroids, bullets, particles, dt, score)
	update_particles(particles, dt)
}

// Draws the game
draw_game :: proc(
	player: Player,
	bullets: []Bullet,
	asteroids: []Asteroid,
	particles: []Particle,
	score: uint,
) {
	draw_player(player)
	draw_player_lives(player)
	draw_bullets(bullets)
	draw_asteroids(asteroids)
	draw_particles(particles)

	score_text := strings.clone_to_cstring(
		fmt.aprintf("Score: %v", score, allocator = context.temp_allocator),
		context.temp_allocator,
	)
	rl.DrawText(score_text, (PLAYER_WIDTH / 2) * PLAYER_SCALE + 15, 50, SCORE_TEXT_SIZE, rl.WHITE)
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

// Fully resets the state of the game
reset_game_full :: proc(
	player: ^Player,
	bullets: ^[dynamic; BULLET_MAX]Bullet,
	asteroids: ^[dynamic; ASTEROID_MAX]Asteroid,
	particles: ^[dynamic]Particle,
	asteroid_spawn_counter: ^uint,
) {
	// Resets player
	player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
	player.vel = {0, 0}
	player.angle = 0
	player.shoot_timer = 0
	player.death_timer = PLAYER_DEATH_DELAY
	player.lives = PLAYER_MAX_LIVES
	player.state = .Alive

	// Resets bullets
	clear(bullets)

	// Resets asteroids
	clear(asteroids)
	asteroid_spawn_counter^ = ASTEROID_MIN_DELAY

	// Resets particles
	clear(particles)
	shrink(particles)
}

// Resets the game for respawn
reset_game_respawn :: proc(
	player: ^Player,
	bullets: ^[dynamic; BULLET_MAX]Bullet,
	asteroids: ^[dynamic; ASTEROID_MAX]Asteroid,
	particles: ^[dynamic]Particle,
	asteroid_spawn_counter: ^uint,
) {
	player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
	player.vel = {0, 0}
	player.angle = 0
	player.shoot_timer = 0
	player.death_timer = PLAYER_DEATH_DELAY
	player.state = .Alive

	// Resets bullets
	clear(bullets)

	// Resets asteroids
	clear(asteroids)
	asteroid_spawn_counter^ = ASTEROID_MIN_DELAY

	// Resets particles
	clear(particles)
	shrink(particles)
}
