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
// maximum number of lives player can have
PLAYER_MAX_LIVES :: 6
// Number of particles spawned on player death
PLAYER_PARTICLE_COUNT :: 30
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
	death_timer: uint,
	lives:       uint,
	state:       PLAYER_STATE,
}

// Forces the maximum speed of the player to be PLAYER_SPEED_CAP
clamp_speed :: proc(player: ^Player) {
	player.vel = rl.Vector2ClampValue(player.vel, 0, PLAYER_SPEED_CAP)
}

check_point_poly_collision :: proc(player_points: [6]rl.Vector2, points: [^]rl.Vector2) -> bool {
	return(
		rl.CheckCollisionPointPoly(player_points[0], points, 11) ||
		rl.CheckCollisionPointPoly(player_points[1], points, 11) ||
		rl.CheckCollisionPointPoly(player_points[2], points, 11) ||
		rl.CheckCollisionPointPoly(player_points[3], points, 11) ||
		rl.CheckCollisionPointPoly(player_points[4], points, 11) ||
		rl.CheckCollisionPointPoly(player_points[5], points, 11) \
	)
}

generate_player_points :: proc(player: Player) -> [4]rl.Vector2 {
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
	return [4]rl.Vector2{top, left, right, center}
}

// Generates collision points on the player sprite
generate_player_collision_points :: proc(player: Player) -> [6]rl.Vector2 {
	main_points := generate_player_points(player)
	left_center :=
		rl.Vector2Rotate(0.5 * (main_points[0] - main_points[1]), player.angle) + player.pos
	right_center :=
		rl.Vector2Rotate(0.5 * (main_points[0] - main_points[2]), player.angle) + player.pos
	return [6]rl.Vector2 {
		main_points[0],
		main_points[1],
		main_points[2],
		main_points[3],
		left_center,
		right_center,
	}
}

// Checks if the player is colliding with an asteroid
check_player_asteroid_collision :: proc(state: ^State) -> (hit: bool) {
	// Calculates player collision points
	player_points := generate_player_collision_points(state.player)

	for asteroid in state.asteroids {
		// Rotates asteroid
		asteroid := asteroid
		for &point in asteroid.base_points {
			point =
				rl.Vector2Rotate(point * ASTEROID_SIZE_VALUE[asteroid.size], asteroid.angle) +
				asteroid.pos
		}


		// Checks if player points are inside asteroid
		points := raw_data(asteroid.base_points[:])
		collision := check_point_poly_collision(player_points, points)

		if collision {
			hit = true
			break
		}

		check_wrapped_player_asteroid_collision(player_points, asteroid)
	}

	return hit
}

// Checks player collision if player is wrapped around the screen
check_wrapped_player_asteroid_collision :: proc(
	player_points: [6]rl.Vector2,
	asteroid: Asteroid,
) -> (
	hit: bool,
) {
	// Checks if asteroid is wrapping around x-axis
	if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.x += WINDOW_WIDTH

		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_point_poly_collision(player_points, wrapped_points_raw) {
			hit = true
			return
		}
	} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.x -= WINDOW_WIDTH
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_point_poly_collision(player_points, wrapped_points_raw) {
			hit = true
			return
		}
	}

	// Checks if asteroid is wrapping around y-axis
	if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.y += WINDOW_HEIGHT
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_point_poly_collision(player_points, wrapped_points_raw) {
			hit = true
			return
		}
	} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.y -= WINDOW_HEIGHT
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_point_poly_collision(player_points, wrapped_points_raw) {
			hit = true
			return
		}
	}

	return
}

// Creates particles for player destructoin
make_player_particles :: proc(state: ^State) {
	for _ in 0 ..< PLAYER_PARTICLE_COUNT {
		append(&state.particles, make_particle(state.player.pos, PLAYER_SCALE * 2))
	}
}

// Updates the player
update_player :: proc(state: ^State, sounds: Sounds, dt: f32) {
	if state.player.state == .Alive {
		// Player input
		if rl.IsKeyDown(.UP) do state.player.vel += rl.Vector2Rotate(rl.Vector2{0, -1} * PLAYER_SPEED, state.player.angle)
		if rl.IsKeyDown(.LEFT) do state.player.angle -= PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.RIGHT) do state.player.angle += PLAYER_ROTATION_AMOUNT
		if rl.IsKeyPressed(.SPACE) && state.player.shoot_timer == 0 {
			append(&state.bullets, make_bullet(state.player))
			state.player.shoot_timer = PLAYER_SHOOT_DELAY
			rl.PlaySound(sounds.shoot)
		}

		clamp_speed(&state.player)
		state.player.pos += state.player.vel * dt
		if state.player.shoot_timer > 0 do state.player.shoot_timer -= 1

		wrap_position(&state.player)
		wrap_angle(&state.player)

		if check_player_asteroid_collision(state) {
			state.player.state = .Dead
			make_player_particles(state)
			rl.PlaySound(sounds.explosion)

			state.player.pos = {-100, -100}
			state.player.vel = {0, 0}
			state.player.shoot_timer = 1
			state.player.death_timer = PLAYER_DEATH_DELAY
			if state.player.lives > 0 do state.player.lives -= 1
		}
	} else if state.player.death_timer > 0 {
		state.player.death_timer -= 1
	}
}

// Draws the player sprite
draw_player :: proc(player: Player) {
	// Player sprite point positions
	points := generate_player_points(player)

	rl.DrawLineStrip(
		raw_data([]rl.Vector2{points[0], points[1], points[3], points[2], points[0]}),
		5,
		PLAYER_COLOR,
	)

	draw_player_wrapping(player, points)
}

// Draws the player sprite wrapping around screen edges
draw_player_wrapping :: proc(player: Player, points: [4]rl.Vector2) {
	// Draws player sprite wapping around x-axis
	if player.pos.x < PLAYER_SCALE * 2 {
		points := points
		points[0].x += WINDOW_WIDTH
		points[1].x += WINDOW_WIDTH
		points[2].x += WINDOW_WIDTH
		points[3].x += WINDOW_WIDTH

		rl.DrawLineStrip(
			raw_data([]rl.Vector2{points[0], points[1], points[3], points[2], points[0]}),
			5,
			PLAYER_COLOR,
		)
	} else if player.pos.x > WINDOW_WIDTH - (PLAYER_SCALE * 2) {
		points := points
		points[0].x -= WINDOW_WIDTH
		points[1].x -= WINDOW_WIDTH
		points[2].x -= WINDOW_WIDTH
		points[3].x -= WINDOW_WIDTH

		rl.DrawLineStrip(
			raw_data([]rl.Vector2{points[0], points[1], points[3], points[2], points[0]}),
			5,
			PLAYER_COLOR,
		)
	}

	// Draws player sprite wapping around y-axis
	if player.pos.y < PLAYER_SCALE * 2 {
		points := points
		points[0].y += WINDOW_HEIGHT
		points[1].y += WINDOW_HEIGHT
		points[2].y += WINDOW_HEIGHT
		points[3].y += WINDOW_HEIGHT

		rl.DrawLineStrip(
			raw_data([]rl.Vector2{points[0], points[1], points[3], points[2], points[0]}),
			5,
			PLAYER_COLOR,
		)
	} else if player.pos.y > WINDOW_HEIGHT - (PLAYER_SCALE * 2) {
		points := points
		points[0].y -= WINDOW_HEIGHT
		points[1].y -= WINDOW_HEIGHT
		points[2].y -= WINDOW_HEIGHT
		points[3].y -= WINDOW_HEIGHT

		rl.DrawLineStrip(
			raw_data([]rl.Vector2{points[0], points[1], points[3], points[2], points[0]}),
			5,
			PLAYER_COLOR,
		)
	}
}

// Draws number of lives that player has remaining
draw_player_lives :: proc(player: Player) {
	// Player sprite point positions
	top := (rl.Vector2{0, -PLAYER_HEIGHT / 2} * PLAYER_SCALE) + {0, 175}
	left := (rl.Vector2{PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE) + {0, 175}
	right := (rl.Vector2{-PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE) + {0, 175}
	center := (rl.Vector2{0, PLAYER_HEIGHT / 4} * PLAYER_SCALE) + {0, 175}

	for _ in 0 ..< player.lives {
		// Shifts sprite over
		top.x += (PLAYER_WIDTH * PLAYER_SCALE) + 15
		left.x += (PLAYER_WIDTH * PLAYER_SCALE) + 15
		right.x += (PLAYER_WIDTH * PLAYER_SCALE) + 15
		center.x += (PLAYER_WIDTH * PLAYER_SCALE) + 15

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	}
}
