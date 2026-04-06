package asteroids

import rl "vendor:raylib"

// Increment that the player angle rotates by
PLAYER_ROTATION_AMOUNT :: 5 * rl.DEG2RAD
// Increment that the player speed increases by
PLAYER_SPEED :: 60
// Max speed for the player
PLAYER_SPEED_CAP :: PLAYER_SPEED * 35
// Frames between shots
PLAYER_SHOOT_DELAY :: 15
// Size multiplication of the player spite
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
	state:       PLAYER_STATE,
}

// Forces the maximum speed of the player to be PLAYER_SPEED_CAP
clamp_speed :: proc(player: ^Player) {
	player.vel = rl.Vector2ClampValue(player.vel, 0, PLAYER_SPEED_CAP)
}

check_player_asteroid_collision :: proc(player: ^Player, asteroids: []Asteroid) {
	top :=
		rl.Vector2Rotate(rl.Vector2{0, -PLAYER_HEIGHT / 2} * PLAYER_SCALE, player.angle) +
		player.pos
	left :=
		rl.Vector2Rotate(
			rl.Vector2{PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
			player.angle,
		) +
		player.pos
	right :=
		rl.Vector2Rotate(
			rl.Vector2{-PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
			player.angle,
		) +
		player.pos

	for asteroid, i in asteroids {
		asteroid := asteroid
		for &point in asteroid.base_points {
			point =
				rl.Vector2Rotate(point * ASTEROID_SIZE_VALUE[asteroid.size], asteroid.angle) +
				asteroid.pos
		}

		if rl.CheckCollisionPointPoly(top, raw_data(asteroid.base_points[:]), 11) ||
		   rl.CheckCollisionPointPoly(left, raw_data(asteroid.base_points[:]), 11) ||
		   rl.CheckCollisionPointPoly(right, raw_data(asteroid.base_points[:]), 11) {
			player.state = .Dead
		}
	}
}

// Updates the player
update_player :: proc(player: ^Player, dt: f32, asteroids: []Asteroid) {
	clamp_speed(player)
	player.pos += player.vel * dt
	if player.shoot_timer > 0 {
		player.shoot_timer -= 1
	}

	wrap_position(player)
	wrap_angle(player)

	check_player_asteroid_collision(player, asteroids)

	if player.state == .Dead {
		player.pos = {-100, -100}
		player.vel = {0, 0}
		player.shoot_timer = 1;
	}
}

// Draws the player sprite
draw_player :: proc(player: Player) {
	// Player sprite point positions
	top :=
		rl.Vector2Rotate(rl.Vector2{0, -PLAYER_HEIGHT / 2} * PLAYER_SCALE, player.angle) +
		player.pos
	left :=
		rl.Vector2Rotate(
			rl.Vector2{PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
			player.angle,
		) +
		player.pos
	right :=
		rl.Vector2Rotate(
			rl.Vector2{-PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
			player.angle,
		) +
		player.pos
	center :=
		rl.Vector2Rotate(rl.Vector2{0, PLAYER_HEIGHT / 4} * PLAYER_SCALE, player.angle) +
		player.pos

	rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)

	draw_player_wrapping(player, top, left, right, center)
}

// Draws the player sprite wrapping around screen edges
draw_player_wrapping :: proc(player: Player, top, left, right, center: rl.Vector2) {
	// Draws player sprite wapping around x-axis
	if player.pos.x < PLAYER_SCALE * 2 {
		top := rl.Vector2{top.x + WINDOW_WIDTH, top.y}
		left := rl.Vector2{left.x + WINDOW_WIDTH, left.y}
		right := rl.Vector2{right.x + WINDOW_WIDTH, right.y}
		center := rl.Vector2{center.x + WINDOW_WIDTH, center.y}

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	} else if player.pos.x > WINDOW_WIDTH - (PLAYER_SCALE * 2) {
		top := rl.Vector2{top.x - WINDOW_WIDTH, top.y}
		left := rl.Vector2{left.x - WINDOW_WIDTH, left.y}
		right := rl.Vector2{right.x - WINDOW_WIDTH, right.y}
		center := rl.Vector2{center.x - WINDOW_WIDTH, center.y}

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	}

	// Draws player sprite wapping around y-axis
	if player.pos.y < PLAYER_SCALE * 2 {
		top := rl.Vector2{top.x, top.y + WINDOW_HEIGHT}
		left := rl.Vector2{left.x, left.y + WINDOW_HEIGHT}
		right := rl.Vector2{right.x, right.y + WINDOW_HEIGHT}
		center := rl.Vector2{center.x, center.y + WINDOW_HEIGHT}

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	} else if player.pos.y > WINDOW_HEIGHT - (PLAYER_SCALE * 2) {
		top := rl.Vector2{top.x, top.y - WINDOW_HEIGHT}
		left := rl.Vector2{left.x, left.y - WINDOW_HEIGHT}
		right := rl.Vector2{right.x, right.y - WINDOW_HEIGHT}
		center := rl.Vector2{center.x, center.y - WINDOW_HEIGHT}

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	}
}
