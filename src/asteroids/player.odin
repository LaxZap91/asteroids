package asteroids

import rl "vendor:raylib"

// Increment that the player angle rotates by
PLAYER_ROTATION_AMOUNT :: 5 * rl.DEG2RAD
// Increment that the player speed increases by
PLAYER_SPEED :: 25
// Max speed for the player
PLAYER_SPEED_CAP :: PLAYER_SPEED * 45
// Frames before returning to menu after death
PLAYER_DEATH_DELAY :: 150
// Frames before player can shoot again
PLAYER_SHOOT_DELAY :: 5
// Maximum number of lives player can have
PLAYER_MAX_LIVES :: 6
// Number of particles spawned on player death
PLAYER_PARTICLE_COUNT :: 30
// How long the player shield lasts
PLAYER_SHIELD_TIME :: 5 * TARGET_FPS
// Radius of the player shield
PLAYER_SHIELD_RADIUS :: PLAYER_SCALE * 6
// Color of the player shield
PLAYER_SHIELD_COLOR :: rl.WHITE
// Scale of the player spite
PLAYER_SCALE :: 20
// Height of the player sprite
PLAYER_HEIGHT :: 4
// Width of the player sprite
PLAYER_WIDTH :: 2
// Color of the player sprite
PLAYER_COLOR :: rl.WHITE
// State of the player
PLAYER_STATE :: enum {
	Alive,
	Dead,
}

Player :: struct {
	using obj:   Object,
	shoot_timer: uint,
	death_timer: uint,
	lives:       uint,
	shield:      uint,
	state:       PLAYER_STATE,
}
