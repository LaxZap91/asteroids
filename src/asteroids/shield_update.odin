package asteroids

import rl "vendor:raylib"

// Checks if an asteroid is colliding with a shield
check_shield_asteroid_collision :: proc(state: ^State, sounds: Sounds) {
	remove_indices := make([dynamic]int, context.temp_allocator)

	points := base_decagon
	for &point in points {
		point = rotate_shift_point(
			point * PLAYER_SHIELD_RADIUS,
			state.player.angle,
			state.player.pos,
		)
	}
	points_slice := get_shield_points(points)

	for asteroid, index in state.asteroids {
		asteroid_points := asteroid.base_points
		for &point in asteroid_points {
			point = rotate_shift_point(
				point * ASTEROID_SIZE_VALUE[asteroid.size],
				asteroid.angle,
				asteroid.pos,
			)

			wrap_point(&point)

			collision :=
				rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) ||
				check_wrapped_shield_asteroid_collision(state.player, point, points)

			if collision {
				append(&remove_indices, index)
				break
			}
		}
	}

	#reverse for index in remove_indices {
		asteroid_destroyed(state, sounds, index)
	}
}

asteroid_destroyed :: proc(state: ^State, sounds: Sounds, index: int) {
	make_asteroid_particles(&state.particles, state.asteroids[index])
	rl.PlaySound(sounds.explosion)
	state.score += uint(ASTEROID_POINT_VALUE[state.asteroids[index].size])

	unordered_remove(&state.asteroids, index)
}


// Checks if the shield wrapped around the screen is colliding with a asteroid
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
		for &player_point in points {
			player_point.x += WINDOW_WIDTH
		}

		points_slice := get_shield_points(points)
		collision :=
			rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) ||
			check_wrapped_shield_asteroid_collision_y(player, point, points)

		if collision {
			hit = true
		}
	} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
		points := points
		for &player_point in points {
			player_point.x -= WINDOW_WIDTH
		}

		points_slice := get_shield_points(points)
		collision :=
			rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) ||
			check_wrapped_shield_asteroid_collision_y(player, point, points)

		if collision {
			hit = true
		}
	}

	// Checks if asteroid is wrapping around y-axis
	if player.pos.y < PLAYER_SHIELD_RADIUS {
		points := points
		for &player_point in points {
			player_point.y += WINDOW_HEIGHT
		}

		points_slice := get_shield_points(points)
		collision :=
			rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) ||
			check_wrapped_shield_asteroid_collision_x(player, point, points)

		if collision {
			hit = true
		}
	} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
		points := points
		for &player_point in points {
			player_point.y -= WINDOW_HEIGHT
		}

		points_slice := get_shield_points(points)
		collision :=
			rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) ||
			check_wrapped_shield_asteroid_collision_x(player, point, points)

		if collision {
			hit = true
		}
	}

	return hit
}

// Checks if the shield wrapped around y-axis is colliding with a asteroid
check_wrapped_shield_asteroid_collision_y :: proc(
	player: Player,
	point: rl.Vector2,
	points: [10]rl.Vector2,
) -> (
	hit: bool,
) {
	points := points
	if player.pos.y < PLAYER_SHIELD_RADIUS {
		for &player_point in points {
			player_point.y += WINDOW_HEIGHT
		}

		points_slice := get_shield_points(points)
		if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
			hit = true
		}
	} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
		for &player_point in points {
			player_point.y -= WINDOW_HEIGHT
		}

		points_slice := get_shield_points(points)
		if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
			hit = true
		}
	}

	return
}

// Checks if the shield wrapped around x-axis is colliding with a asteroid
check_wrapped_shield_asteroid_collision_x :: proc(
	player: Player,
	point: rl.Vector2,
	points: [10]rl.Vector2,
) -> (
	hit: bool,
) {
	points := points
	if player.pos.x < PLAYER_SHIELD_RADIUS {
		for &player_point in points {
			player_point.x += WINDOW_WIDTH
		}

		points_slice := get_shield_points(points)
		if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
			hit = true
		}
	} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
		for &player_point in points {
			player_point.x -= WINDOW_WIDTH
		}

		points_slice := get_shield_points(points)
		if rl.CheckCollisionPointPoly(point, raw_data(points_slice), 11) {
			hit = true
		}
	}

	return
}
