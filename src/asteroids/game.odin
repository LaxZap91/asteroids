package asteroids

import "core:fmt"
import "core:math/rand"
import "core:strings"
import rl "vendor:raylib"

import "../assets"

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

// Levels of difficult
STAGE :: enum {
	EASY = 0,
	MEDIUM,
	HARD,
}
// How long you have to survive to get to next stage
STAGE_TIME :: 60 * 25
// How many points gained when stage stage_timer hits 0
STAGE_NEXT_POINTS :: 500
// How many points are lost upon death
PLAYER_DEATH_LOSS_POINTS :: 250

State :: struct {
	game_screen:            GAME_SCREEN,
	stage:                  STAGE,
	stage_timer:            uint,
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

Sounds :: struct {
	shoot:     rl.Sound,
	explosion: rl.Sound,
	select:    rl.Sound,
}

// Creates and initializes state
make_state :: proc() -> (state: State) {
	state.player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
	state.particles = make([dynamic]Particle)

	for i in 0 ..< ASTEROID_SOFT_MAX {
		state.menu_asteroids[i] = make_asteroid_rand()
	}

	state.asteroid_spawn_counter = ASTEROID_MIN_DELAY
	state.stage_timer = STAGE_TIME

	return
}

// Deallocates state variables
delete_state :: proc(state: ^State) {
	delete(state.particles)
}

// Creates and initialzes sounds
make_sounds :: proc() -> (sounds: Sounds) {
	// Load shoot sound
	shoot_wave := rl.LoadWaveFromMemory(assets.SHOOT_EXT, assets.SHOOT_PTR, assets.SHOOT_SIZE)
	defer rl.UnloadWave(shoot_wave)
	shoot_sound := rl.LoadSoundFromWave(shoot_wave)

	// Load explosion sound
	explosion_wave := rl.LoadWaveFromMemory(
		assets.EXPLOSION_EXT,
		assets.EXPLOSION_PTR,
		assets.EXPLOSION_SIZE,
	)
	defer rl.UnloadWave(explosion_wave)
	explosion_sound := rl.LoadSoundFromWave(explosion_wave)

	// Load select sound
	select_wave := rl.LoadWaveFromMemory(assets.SELECT_EXT, assets.SELECT_PTR, assets.SELECT_SIZE)
	defer rl.UnloadWave(select_wave)
	select_sound := rl.LoadSoundFromWave(select_wave)

	return {shoot_sound, explosion_sound, select_sound}
}

// Unloads sounds
delete_sounds :: proc(sounds: ^Sounds) {
	rl.UnloadSound(sounds.shoot)
	rl.UnloadSound(sounds.explosion)
	rl.UnloadSound(sounds.select)
}

// Updates the state of the menu
update_menu :: proc(state: ^State, sounds: Sounds, dt: f32) {
	if rl.IsKeyPressed(.H) {
		state.game_screen = .HELP
		rl.PlaySound(sounds.select)
	} else if state.restart_delay == 0 && rl.IsKeyPressed(.SPACE) {
		reset_game_full(state)
		rl.PlaySound(sounds.select)
	} else if state.restart_delay > 0 {
		state.restart_delay -= 1
	}

	update_menu_asteroids(state.menu_asteroids[:], dt)
}

// Updates the state the the help menu
update_help :: proc(state: ^State, sounds: Sounds, dt: f32) {
	if rl.IsKeyPressed(.BACKSPACE) {
		state.game_screen = .MENU
		rl.PlaySound(sounds.select)
	}

	update_menu_asteroids(state.menu_asteroids[:], dt)
}

// Updates the state of the game
update_game :: proc(state: ^State, sounds: Sounds, dt: f32) {
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

	// Decrements stage change timer if alive
	if state.player.state == .Alive {
		if state.stage_timer > 0 {
			state.stage_timer -= 1
		} else {
			if state.stage == .EASY {
				state.stage = .MEDIUM
			} else if state.stage == .MEDIUM {
				state.stage = .HARD
			}
			state.score += STAGE_NEXT_POINTS
			state.stage_timer = STAGE_TIME
		}
	}

	asteroid_max_increment_current := ASTEROID_MAX_INCREMENT * int(state.stage)
	asteroid_count_less_max :=
		len(state.asteroids) < (ASTEROID_SOFT_MAX + asteroid_max_increment_current)

	// Update game objects
	if state.asteroid_spawn_counter == 0 && asteroid_count_less_max {
		append(&state.asteroids, make_asteroid_rand())
		state.asteroid_spawn_counter = uint(rand.int_range(ASTEROID_MIN_DELAY, ASTEROID_MAX_DELAY))
	} else if state.asteroid_spawn_counter > 0 && asteroid_count_less_max {
		state.asteroid_spawn_counter -= 1
	}

	update_player(state, sounds, dt)
	update_bullets(state, dt)
	update_asteroids(state, sounds, dt)
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
	state.stage = .EASY
	state.stage_timer = STAGE_TIME

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
	if state.stage == .HARD {
		state.stage = .MEDIUM
	} else if state.stage == .MEDIUM {
		state.stage = .EASY
	}
	state.stage_timer = STAGE_TIME

	if state.score >= PLAYER_DEATH_LOSS_POINTS {
		state.score -= PLAYER_DEATH_LOSS_POINTS
	} else {
		state.score = 0
	}

	// Resets player
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
