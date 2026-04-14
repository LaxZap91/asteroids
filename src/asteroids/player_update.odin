package asteroids

import rl "vendor:raylib"

// Forces the maximum speed of the player to be PLAYER_SPEED_CAP
clamp_speed :: proc(player: ^Player) {
	player.vel = rl.Vector2ClampValue(player.vel, 0, PLAYER_SPEED_CAP)
}

// Gets the corners of the player sprite
generate_player_points :: proc(player: Player) -> [4]rl.Vector2 {
	top := rotate_shift_point(
		rl.Vector2{0, -PLAYER_HEIGHT / 2} * PLAYER_SCALE,
		player.angle,
		player.pos,
	)
	left := rotate_shift_point(
		rl.Vector2{PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
		player.angle,
		player.pos,
	)
	right := rotate_shift_point(
		rl.Vector2{-PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
		player.angle,
		player.pos,
	)
	center := rotate_shift_point(
		rl.Vector2{0, PLAYER_HEIGHT / 4} * PLAYER_SCALE,
		player.angle,
		player.pos,
	)
	return [4]rl.Vector2{top, left, right, center}
}

// Generates collision points of the player sprite
generate_player_collision_points :: proc(player: Player) -> [6]rl.Vector2 {
	main_points := generate_player_points(player)
	left_center := rotate_shift_point(
		0.5 * (main_points[0] - main_points[1]),
		player.angle,
		player.pos,
	)
	right_center := rotate_shift_point(
		0.5 * (main_points[0] - main_points[2]),
		player.angle,
		player.pos,
	)

	collision_points := [6]rl.Vector2 {
		main_points[0],
		main_points[1],
		main_points[2],
		main_points[3],
		left_center,
		right_center,
	}

	// Wraps points around the screen
	for &point in collision_points {
		wrap_point(&point)
	}

	return collision_points
}

// Checks if the player points are in an asteroid
check_point_poly_collision :: proc(player_points: [6]rl.Vector2, points: [^]rl.Vector2) -> (hit: bool) {
	for point in player_points {
		if rl.CheckCollisionPointPoly(point, points, 11) {
			hit = true
			break
		}
	}

	return
}

// Checks if the player is colliding with an asteroid
check_player_asteroid_collision :: proc(state: ^State) -> (hit: bool) {
	// Calculates player collision points
	player_points := generate_player_collision_points(state.player)

	for asteroid in state.asteroids {
		// Rotates asteroid
		asteroid := asteroid
		for &point in asteroid.base_points {
			point = rotate_shift_point(
				point * ASTEROID_SIZE_VALUE[asteroid.size],
				asteroid.angle,
				asteroid.pos,
			)
		}

		// Checks if player points are inside asteroid
		points := raw_data(asteroid.base_points[:])
		collision :=
			check_point_poly_collision(player_points, points) ||
			check_wrapped_player_asteroid_collision(player_points, asteroid)

		if collision {
			hit = true
			break
		}
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
		collision :=
			check_point_poly_collision(player_points, wrapped_points_raw) ||
			check_wrapped_player_asteroid_collision_y(asteroid, wrapped_points, player_points)

		if collision {
			hit = true
			return
		}
	} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.x -= WINDOW_WIDTH
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		collision :=
			check_point_poly_collision(player_points, wrapped_points_raw) ||
			check_wrapped_player_asteroid_collision_y(asteroid, wrapped_points, player_points)

		if collision {
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
		collision :=
			check_point_poly_collision(player_points, wrapped_points_raw) ||
			check_wrapped_player_asteroid_collision_x(asteroid, wrapped_points, player_points)

		if collision {
			hit = true
			return
		}
	} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.y -= WINDOW_HEIGHT
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		collision :=
			check_point_poly_collision(player_points, wrapped_points_raw) ||
			check_wrapped_player_asteroid_collision_x(asteroid, wrapped_points, player_points)

		if collision {
			hit = true
			return
		}
	}

	return
}

// Checks if the asteroid wrapped around y-axis is colliding with the player
check_wrapped_player_asteroid_collision_y :: proc(
	asteroid: Asteroid,
	wrapped_points: [11]rl.Vector2,
	player_points: [6]rl.Vector2,
) -> (
	hit: bool,
) {
	wrapped_points := wrapped_points
	if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
		for &point in wrapped_points {
			point.y += WINDOW_HEIGHT
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_point_poly_collision(player_points, wrapped_points_raw) {
			hit = true
		}
	} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		for &point in wrapped_points {
			point.y -= WINDOW_HEIGHT
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_point_poly_collision(player_points, wrapped_points_raw) {
			hit = true
		}
	}

	return
}

// Checks if the asteroid wrapped around x-axis is colliding with the player
check_wrapped_player_asteroid_collision_x :: proc(
	asteroid: Asteroid,
	wrapped_points: [11]rl.Vector2,
	player_points: [6]rl.Vector2,
) -> (
	hit: bool,
) {
	wrapped_points := wrapped_points
	if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
		for &point in wrapped_points {
			point.x += WINDOW_WIDTH
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_point_poly_collision(player_points, wrapped_points_raw) {
			hit = true
		}
	} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		for &point in wrapped_points {
			point.x -= WINDOW_WIDTH
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_point_poly_collision(player_points, wrapped_points_raw) {
			hit = true
		}
	}

	return
}

// Creates particles for player destruction
make_player_particles :: proc(state: ^State) {
	for _ in 0 ..< PLAYER_PARTICLE_COUNT {
		append(&state.particles, make_particle(state.player.pos, PLAYER_SCALE * 2))
	}
}

// Updates the player
update_player :: proc(state: ^State, sounds: Sounds) {
	if state.player.state == .Alive {
		// Player input
		if rl.IsKeyDown(.UP) {
			state.player.vel += rl.Vector2Rotate(rl.Vector2{0, -1} * PLAYER_SPEED, state.player.angle)
		}
		if rl.IsKeyDown(.LEFT) {
			state.player.angle -= PLAYER_ROTATION_AMOUNT
		}
		if rl.IsKeyDown(.RIGHT) {
			state.player.angle += PLAYER_ROTATION_AMOUNT
		}
		if rl.IsKeyPressed(.SPACE) && state.player.shoot_timer == 0 {
			shoot_bullet(state, sounds)
		}

		clamp_speed(&state.player)
		state.player.pos += state.player.vel * state.dt

		wrap_position(&state.player)
		wrap_angle(&state.player)

		if state.player.shoot_timer > 0 {
			state.player.shoot_timer -= 1
		}

		if state.player.shield > 0 {
			state.player.shield -= 1
			check_shield_asteroid_collision(state, sounds)
		} else if check_player_asteroid_collision(state) {
			player_hit(state, sounds)
		}
	} else if state.player.death_timer > 0 {
		state.player.death_timer -= 1
	}
}

// Logic for if player is hit by an asteroid
player_hit :: proc(state: ^State, sounds: Sounds) {
	state.player.state = .Dead
	make_player_particles(state)
	rl.PlaySound(sounds.explosion)

	state.player.pos = {-100, -100}
	state.player.vel = {0, 0}
	state.player.shoot_timer = 1
	state.player.death_timer = PLAYER_DEATH_DELAY
	if state.player.lives > 0 do state.player.lives -= 1
}

// Logic for if a player shoots a bullet
shoot_bullet :: proc(state: ^State, sounds: Sounds) {
	append(&state.bullets, make_bullet(state.player))
	state.player.shoot_timer = PLAYER_SHOOT_DELAY
	rl.PlaySound(sounds.shoot)
}
