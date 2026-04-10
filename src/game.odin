package asteroids

import "core:fmt"
import "core:math/rand"
import "core:strings"
import rl "vendor:raylib"

// Font sizes
FONT_LARGE :: 300
FONT_MEDIUM :: 100
FONT_TINY :: 30
FONT_SMALL :: 50

// Game screens
GAME_SCREEN :: enum {
	MENU,
	HELP,
	GAME,
}

State :: struct {
	game_screen:            GAME_SCREEN,
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

// Deallocates state variables
delete_state :: proc(state: ^State) {
	delete(state.particles)
}

// Updates the state of the menu
update_menu :: proc(state: ^State, dt: f32) {
	if rl.IsKeyDown(.H) {
		state.game_screen = .HELP
	} else if state.restart_delay == 0 && rl.IsKeyDown(.SPACE) {
		reset_game_full(state)
	} else if state.restart_delay > 0 {
		state.restart_delay -= 1
	}

	update_menu_asteroids(state.menu_asteroids[:], dt)
}

// Updates the state the the help menu
update_help :: proc(state: ^State, dt: f32) {
	if rl.IsKeyDown(.BACKSPACE) {
		state.game_screen = .MENU
	}

	update_menu_asteroids(state.menu_asteroids[:], dt)
}

// Updates the state of the game
update_game :: proc(state: ^State, dt: f32) {
	if state.player.state == .Dead && state.player.death_timer == 0 {
		if state.player.lives == 0 {
			state.game_screen = .MENU
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

// Draws the menu
draw_menu :: proc(state: ^State) {
	draw_asteroids(state.menu_asteroids[:])

	rl.DrawText(
		"Asteroids",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Asteroids", FONT_LARGE) / 2)),
		i32(WINDOW_HEIGHT / 3),
		FONT_LARGE,
		rl.WHITE,
	)

	high_score_text := strings.unsafe_string_to_cstring(
		fmt.tprintf("High Score: %v", state.high_score),
	)
	rl.DrawText(
		high_score_text,
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText(high_score_text, FONT_MEDIUM) / 2)),
		i32(WINDOW_HEIGHT / 2),
		FONT_MEDIUM,
		rl.WHITE,
	)

	rl.DrawText(
		"PRESS SPACE TO PLAY",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("PRESS SPACE TO PLAY", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2) + FONT_SMALL + FONT_MEDIUM,
		FONT_SMALL,
		rl.WHITE,
	)

	help_text_half_height := i32(
		rl.MeasureTextEx(rl.GetFontDefault(), "PRESS H FOR HELP", FONT_SMALL, 0).y / 2,
	)
	rl.DrawText(
		"PRESS H FOR HELP",
		50,
		WINDOW_HEIGHT - 50 - help_text_half_height,
		FONT_TINY,
		rl.WHITE,
	)
}
// Draws the help menu
draw_help :: proc(state: ^State) {
	draw_asteroids(state.menu_asteroids[:])

	rl.DrawText(
		"Help",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Help", FONT_LARGE) / 2)),
		i32(WINDOW_HEIGHT / 3),
		FONT_LARGE,
		rl.WHITE,
	)

	rl.DrawText(
		"Movement: Arrow Keys",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Movement: Arrow Keys", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2),
		FONT_SMALL,
		rl.WHITE,
	)

	rl.DrawText(
		"Shoot: Space",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Shoot: Space", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2) + (2 * FONT_SMALL),
		FONT_SMALL,
		rl.WHITE,
	)

	rl.DrawText(
		"Menu: Backspace",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Menu: Backspace", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2) + (4 * FONT_SMALL),
		FONT_SMALL,
		rl.WHITE,
	)

	rl.DrawText(
		"Quit: Escape",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Quit: Escape", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2) + (6 * FONT_SMALL),
		FONT_SMALL,
		rl.WHITE,
	)
}

// Draws the game
draw_game :: proc(state: ^State) {
	draw_player(state.player)
	draw_player_lives(state.player)
	draw_bullets(state.bullets[:])
	draw_asteroids(state.asteroids[:])
	draw_particles(state.particles[:])

	score_text := strings.unsafe_string_to_cstring(fmt.tprintf("Score: %v", state.score))
	rl.DrawText(score_text, (PLAYER_WIDTH / 2) * PLAYER_SCALE + 15, 50, FONT_SMALL, rl.WHITE)
}

// Fully resets the state of the game
reset_game_full :: proc(state: ^State) {
	state.game_screen = .GAME

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
