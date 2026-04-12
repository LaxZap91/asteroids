package asteroids

import rl "vendor:raylib"

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
		if point.x < 0 {
			point.x += WINDOW_WIDTH
		} else if point.x > WINDOW_WIDTH {
			point.x -= WINDOW_WIDTH
		}

		if point.y < 0 {
			point.y += WINDOW_HEIGHT
		} else if point.y > WINDOW_HEIGHT {
			point.y -= WINDOW_HEIGHT
		}
	}

	return collision_points
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
		if check_point_poly_collision(player_points, wrapped_points_raw) {
			hit = true
			return
		}


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

		if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			for &point in wrapped_points {
				point.x += WINDOW_WIDTH
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_point_poly_collision(player_points, wrapped_points_raw) {
				hit = true
				return
			}
		} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			for &point in wrapped_points {
				point.x -= WINDOW_WIDTH
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_point_poly_collision(player_points, wrapped_points_raw) {
				hit = true
				return
			}
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

		if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			for &point in wrapped_points {
				point.x += WINDOW_WIDTH
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_point_poly_collision(player_points, wrapped_points_raw) {
				hit = true
				return
			}
		} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			for &point in wrapped_points {
				point.x -= WINDOW_WIDTH
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_point_poly_collision(player_points, wrapped_points_raw) {
				hit = true
				return
			}
		}
	}

	return
}

check_shield_asteroid_collision :: proc(state: ^State, sounds: Sounds) {
	remove_indices := make([dynamic]int, context.temp_allocator)

	points := base_decagon
	for &point in points {
		point =
			rl.Vector2Rotate(point * PLAYER_SHIELD_RADIUS, state.player.angle) + state.player.pos
	}
	points_slice := []rl.Vector2 {
		points[0],
		points[1],
		points[2],
		points[3],
		points[4],
		points[5],
		points[6],
		points[7],
		points[8],
		points[9],
		points[0],
	}

	for asteroid, index in state.asteroids {
		asteroid_points := asteroid.base_points
		for &point in asteroid_points {
			point =
				rl.Vector2Rotate(point * ASTEROID_SIZE_VALUE[asteroid.size], asteroid.angle) +
				asteroid.pos

			// Wrap points around the x-axis
			if point.x < 0 {
				point.x += WINDOW_WIDTH
			} else if point.x > WINDOW_WIDTH {
				point.x -= WINDOW_WIDTH
			}

			// Wrap points around the y-axis
			if point.y < 0 {
				point.y += WINDOW_HEIGHT
			} else if point.y > WINDOW_HEIGHT {
				point.y -= WINDOW_HEIGHT
			}

			collision :=
				rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) ||
				check_wrapped_shield_asteroid_collision(state.player, point, points)

			if collision {
				append(&remove_indices, index)
				break
			}
		}
	}

	slice.reverse(remove_indices[:])
	for index in remove_indices {
		make_asteroid_particles(&state.particles, state.asteroids[index])
		rl.PlaySound(sounds.explosion)
		state.score += uint(ASTEROID_POINT_VALUE[state.asteroids[index].size])

		unordered_remove(&state.asteroids, index)
	}
}

check_wrapped_shield_asteroid_collision :: proc(
	player: Player,
	point: rl.Vector2,
	points: [10]rl.Vector2,
) -> (
	hit: bool,
) {
	// Checks if asteroid is wrapping around x-axis
	if player.pos.x < PLAYER_SHIELD_RADIUS {
		points := points
		for &point in points {
			point.x += WINDOW_WIDTH
		}

		points_slice := []rl.Vector2 {
			points[0],
			points[1],
			points[2],
			points[3],
			points[4],
			points[5],
			points[6],
			points[7],
			points[8],
			points[9],
			points[0],
		}
		if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
			hit = true
		}

		if player.pos.y < PLAYER_SHIELD_RADIUS {
			points := points
			for &point in points {
				point.y += WINDOW_HEIGHT
			}

			points_slice := []rl.Vector2 {
				points[0],
				points[1],
				points[2],
				points[3],
				points[4],
				points[5],
				points[6],
				points[7],
				points[8],
				points[9],
				points[0],
			}
			if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
				hit = true
			}
		} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
			points := points
			for &point in points {
				point.y -= WINDOW_HEIGHT
			}

			points_slice := []rl.Vector2 {
				points[0],
				points[1],
				points[2],
				points[3],
				points[4],
				points[5],
				points[6],
				points[7],
				points[8],
				points[9],
				points[0],
			}
			if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
				hit = true
			}
		}
	} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
		points := points
		for &point in points {
			point.x -= WINDOW_WIDTH
		}

		points_slice := []rl.Vector2 {
			points[0],
			points[1],
			points[2],
			points[3],
			points[4],
			points[5],
			points[6],
			points[7],
			points[8],
			points[9],
			points[0],
		}
		if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
			hit = true
		}

		if player.pos.y < PLAYER_SHIELD_RADIUS {
			points := points
			for &point in points {
				point.y += WINDOW_HEIGHT
			}

			points_slice := []rl.Vector2 {
				points[0],
				points[1],
				points[2],
				points[3],
				points[4],
				points[5],
				points[6],
				points[7],
				points[8],
				points[9],
				points[0],
			}
			if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
				hit = true
			}
		} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
			points := points
			for &point in points {
				point.y -= WINDOW_HEIGHT
			}

			points_slice := []rl.Vector2 {
				points[0],
				points[1],
				points[2],
				points[3],
				points[4],
				points[5],
				points[6],
				points[7],
				points[8],
				points[9],
				points[0],
			}
			if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
				hit = true
			}
		}
	}

	// Checks if asteroid is wrapping around y-axis
	if player.pos.y < PLAYER_SHIELD_RADIUS {
		points := points
		for &point in points {
			point.y += WINDOW_HEIGHT
		}

		points_slice := []rl.Vector2 {
			points[0],
			points[1],
			points[2],
			points[3],
			points[4],
			points[5],
			points[6],
			points[7],
			points[8],
			points[9],
			points[0],
		}
		if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
			hit = true
		}

		if player.pos.x < PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.x += WINDOW_WIDTH
			}

			points_slice := []rl.Vector2 {
				points[0],
				points[1],
				points[2],
				points[3],
				points[4],
				points[5],
				points[6],
				points[7],
				points[8],
				points[9],
				points[0],
			}
			if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
				hit = true
			}
		} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.x -= WINDOW_WIDTH
			}

			points_slice := []rl.Vector2 {
				points[0],
				points[1],
				points[2],
				points[3],
				points[4],
				points[5],
				points[6],
				points[7],
				points[8],
				points[9],
				points[0],
			}
			if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
				hit = true
			}
		}
	} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
		points := points
		for &point in points {
			point.y -= WINDOW_HEIGHT
		}

		points_slice := []rl.Vector2 {
			points[0],
			points[1],
			points[2],
			points[3],
			points[4],
			points[5],
			points[6],
			points[7],
			points[8],
			points[9],
			points[0],
		}
		if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
			hit = true
		}

		if player.pos.x < PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.x += WINDOW_WIDTH
			}

			points_slice := []rl.Vector2 {
				points[0],
				points[1],
				points[2],
				points[3],
				points[4],
				points[5],
				points[6],
				points[7],
				points[8],
				points[9],
				points[0],
			}
			if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
				hit = true
			}
		} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.x -= WINDOW_WIDTH
			}

			points_slice := []rl.Vector2 {
				points[0],
				points[1],
				points[2],
				points[3],
				points[4],
				points[5],
				points[6],
				points[7],
				points[8],
				points[9],
				points[0],
			}
			if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
				hit = true
			}
		}
	}

	return hit
}

// Creates particles for player destructoin
make_player_particles :: proc(state: ^State) {
	for _ in 0 ..< PLAYER_PARTICLE_COUNT {
		append(&state.particles, make_particle(state.player.pos, PLAYER_SCALE * 2))
	}
}

// Updates the player
update_player :: proc(state: ^State, sounds: Sounds) {
	if state.player.state == .Alive {
		// Player input
		if rl.IsKeyDown(.UP) do state.player.vel += rl.Vector2Rotate(rl.Vector2{0, -1} * PLAYER_SPEED, state.player.angle)
		if rl.IsKeyDown(.LEFT) do state.player.angle -= PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.RIGHT) do state.player.angle += PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.DOWN) do state.player.vel = {0, 0}
		if rl.IsKeyPressed(.SPACE) && state.player.shoot_timer == 0 {
			append(&state.bullets, make_bullet(state.player))
			state.player.shoot_timer = PLAYER_SHOOT_DELAY
			rl.PlaySound(sounds.shoot)
		}

		clamp_speed(&state.player)
		state.player.pos += state.player.vel * state.dt
		if state.player.shoot_timer > 0 do state.player.shoot_timer -= 1

		wrap_position(&state.player)
		wrap_angle(&state.player)

		if state.player.shield > 0 {
			state.player.shield -= 1
			check_shield_asteroid_collision(state, sounds)
		} else if check_player_asteroid_collision(state) {
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
