package asteroids

import rl "vendor:raylib"

// Checks if a bullet corners are inside of a given polygon
check_poly_bullet_collision :: proc(points: [^]rl.Vector2, bullet: Bullet) -> bool {
	top_left_hit := rl.CheckCollisionPointPoly(
		{bullet.pos.x - (BULLET_SIZE / 2), bullet.pos.y - (BULLET_SIZE / 2)},
		points,
		11,
	)
	top_right_hit := rl.CheckCollisionPointPoly(
		{bullet.pos.x + (BULLET_SIZE / 2), bullet.pos.y - (BULLET_SIZE / 2)},
		points,
		11,
	)
	bottom_left_hit := rl.CheckCollisionPointPoly(
		{bullet.pos.x - (BULLET_SIZE / 2), bullet.pos.y + (BULLET_SIZE / 2)},
		points,
		11,
	)
	bottom_right_hit := rl.CheckCollisionPointPoly(
		{bullet.pos.x + (BULLET_SIZE / 2), bullet.pos.y + (BULLET_SIZE / 2)},
		points,
		11,
	)
	return top_left_hit || top_right_hit || bottom_left_hit || bottom_right_hit
}

// Checks if an asteroid is colliding with a bullet
check_asteroid_bullet_collision :: proc(
	asteroid: Asteroid,
	bullets: []Bullet,
) -> (
	hit: bool,
	bullet_index: int,
) {
	asteroid := asteroid
	for &point in asteroid.base_points {
		point = rotate_shift_point(
			point * ASTEROID_SIZE_VALUE[asteroid.size],
			asteroid.angle,
			asteroid.pos,
		)
	}

	points := raw_data(asteroid.base_points[:])

	for bullet, index in bullets {
		if check_poly_bullet_collision(points, bullet) ||
		   check_wrapped_asteroid_bullet_collision(asteroid, bullet) {
			bullet_index = index
			hit = true
			break
		}
	}

	return hit, bullet_index
}

// Checks if a wrapped asteroid is colliding with a bullet
check_wrapped_asteroid_bullet_collision :: proc(
	asteroid: Asteroid,
	bullet: Bullet,
) -> (
	hit: bool,
) {
	// Checks if asteroid is wrapping around x-axis
	if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.x += WINDOW_WIDTH
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		collision :=
			check_poly_bullet_collision(wrapped_points_raw, bullet) ||
			check_wrapped_asteroid_bullet_collision_y(asteroid, bullet)
		if collision {
			hit = true
			return
		}
	} else if asteroid.pos.x > WINDOW_WIDTH - ASTEROID_SIZE_VALUE[asteroid.size] {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.x -= WINDOW_WIDTH
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		collision :=
			check_poly_bullet_collision(wrapped_points_raw, bullet) ||
			check_wrapped_asteroid_bullet_collision_y(asteroid, bullet)
		if collision {
			hit = true
			return
		}
	}

	// Checks if asteroid is wrapping around y-axis
	if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.y += WINDOW_HEIGHT
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		collision :=
			check_poly_bullet_collision(wrapped_points_raw, bullet) ||
			check_wrapped_asteroid_bullet_collision_x(asteroid, bullet)
		if collision {
			hit = true
			return
		}
	} else if asteroid.pos.y > WINDOW_HEIGHT - ASTEROID_SIZE_VALUE[asteroid.size] {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point.y -= WINDOW_HEIGHT
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		collision :=
			check_poly_bullet_collision(wrapped_points_raw, bullet) ||
			check_wrapped_asteroid_bullet_collision_x(asteroid, bullet)
		if collision {
			hit = true
			return
		}
	}

	return
}

// Checks if a asteroid wrapped around y-axis is colliding with a bullet
check_wrapped_asteroid_bullet_collision_y :: proc(
	asteroid: Asteroid,
	bullet: Bullet,
) -> (
	hit: bool,
) {
	if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] {
		asteroid := asteroid
		for &point in asteroid.base_points {
			point.y += WINDOW_HEIGHT
		}

		wrapped_points_raw := raw_data(asteroid.base_points[:])
		if check_poly_bullet_collision(wrapped_points_raw, bullet) {
			hit = true
		}
	} else if asteroid.pos.y > WINDOW_HEIGHT - ASTEROID_SIZE_VALUE[asteroid.size] {
		asteroid := asteroid
		for &point in asteroid.base_points {
			point.y -= WINDOW_HEIGHT
		}

		wrapped_points_raw := raw_data(asteroid.base_points[:])
		if check_poly_bullet_collision(wrapped_points_raw, bullet) {
			hit = true
		}
	}

	return
}

// Checks if a asteroid wrapped around x-axis is colliding with a bullet
check_wrapped_asteroid_bullet_collision_x :: proc(
	asteroid: Asteroid,
	bullet: Bullet,
) -> (
	hit: bool,
) {
	if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] {
		asteroid := asteroid
		for &point in asteroid.base_points {
			point.x += WINDOW_WIDTH
		}

		wrapped_points_raw := raw_data(asteroid.base_points[:])
		if check_poly_bullet_collision(wrapped_points_raw, bullet) {
			hit = true
		}
	} else if asteroid.pos.x > WINDOW_WIDTH - ASTEROID_SIZE_VALUE[asteroid.size] {
		asteroid := asteroid
		for &point in asteroid.base_points {
			point.x -= WINDOW_WIDTH
		}

		wrapped_points_raw := raw_data(asteroid.base_points[:])
		if check_poly_bullet_collision(wrapped_points_raw, bullet) {
			hit = true
		}
	}

	return
}

// Updates asteroids
update_asteroids :: proc(state: ^State, sounds: Sounds) {
	remove_indices := make([dynamic]int, context.temp_allocator)

	for &asteroid, index in state.asteroids {
		asteroid.pos += asteroid.vel * state.dt
		asteroid.angle += asteroid.rotation_speed
		wrap_angle(&asteroid)
		wrap_position(&asteroid)

		hit, bullet_index := check_asteroid_bullet_collision(asteroid, state.bullets[:])
		if hit {
			unordered_remove(&state.bullets, bullet_index)
			make_asteroid_particles(&state.particles, asteroid)
			if asteroid.size != .Small {
				append(
					&state.asteroids,
					make_asteroid_child(asteroid),
					make_asteroid_child(asteroid),
				)
			}
			rl.PlaySound(sounds.explosion)
			append(&remove_indices, index)
			state.score += uint(ASTEROID_POINT_VALUE[asteroid.size])
		}
	}

	// Removes destroyed asteroids
	#reverse for index in remove_indices {
		unordered_remove(&state.asteroids, index)
	}
}

// Updates asteroids
update_menu_asteroids :: proc(state: ^State) {
	for &asteroid in state.menu_asteroids {
		asteroid.pos += asteroid.vel * state.dt
		asteroid.angle += asteroid.rotation_speed
		wrap_angle(&asteroid)
		wrap_position(&asteroid)
	}
}
