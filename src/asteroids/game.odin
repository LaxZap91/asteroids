package asteroids

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
// How many frames before you can restart the game
RESTART_DELAY :: 10

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
	dt:                     f32,
}

Sounds :: struct {
	shoot:     rl.Sound,
	explosion: rl.Sound,
	select:    rl.Sound,
}

// Creates and initializes state
make_state :: proc() -> (state: State) {
	state.particles = make([dynamic]Particle)

	for i in 0 ..< ASTEROID_SOFT_MAX {
		state.menu_asteroids[i] = make_asteroid_menu()
	}

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

// Resets the game for respawn
reset_game_respawn :: proc(state: ^State) {
	// Reduces difficulty
	if state.stage == .HARD {
		state.stage = .MEDIUM
	} else if state.stage == .MEDIUM {
		state.stage = .EASY
	}
	state.stage_timer = STAGE_TIME

	// Reduce score
	if state.score > PLAYER_DEATH_LOSS_POINTS {
		state.score -= PLAYER_DEATH_LOSS_POINTS
	} else {
		state.score = 0
	}

	// Resets player
	state.player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
	state.player.vel = {0, 0}
	state.player.angle = 0
	state.player.shoot_timer = 0
	state.player.shield = 0
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
	state.player.shield = 0
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
