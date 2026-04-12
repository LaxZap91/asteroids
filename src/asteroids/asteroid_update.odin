package asteroids

import "core:slice"
import rl "vendor:raylib"

// Checks if a bullets corners are inside of a given polygon
check_poly_bullet_collision :: proc(points: [^]rl.Vector2, bullet: Bullet) -> bool {
	return(
		rl.CheckCollisionPointPoly(
			{bullet.pos.x - (BULLET_SIZE / 2), bullet.pos.y - (BULLET_SIZE / 2)},
			points,
			11,
		) ||
		rl.CheckCollisionPointPoly(
			{bullet.pos.x + (BULLET_SIZE / 2), bullet.pos.y - (BULLET_SIZE / 2)},
			points,
			11,
		) ||
		rl.CheckCollisionPointPoly(
			{bullet.pos.x - (BULLET_SIZE / 2), bullet.pos.y + (BULLET_SIZE / 2)},
			points,
			11,
		) ||
		rl.CheckCollisionPointPoly(
			{bullet.pos.x + (BULLET_SIZE / 2), bullet.pos.y + (BULLET_SIZE / 2)},
			points,
			11,
		) \
	)
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
		point =
			rl.Vector2Rotate(point * ASTEROID_SIZE_VALUE[asteroid.size], asteroid.angle) +
			asteroid.pos
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
	if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point = rl.Vector2{point.x + WINDOW_WIDTH, point.y}
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_poly_bullet_collision(wrapped_points_raw, bullet) {
			hit = true
			return
		}

		if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			wrapped_points := asteroid.base_points
			for &point in wrapped_points {
				point = rl.Vector2{point.x, point.y + WINDOW_HEIGHT}
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_poly_bullet_collision(wrapped_points_raw, bullet) {
				hit = true
				return
			}
		} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			wrapped_points := asteroid.base_points
			for &point in wrapped_points {
				point = rl.Vector2{point.x, point.y - WINDOW_HEIGHT}
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_poly_bullet_collision(wrapped_points_raw, bullet) {
				hit = true
				return
			}
		}
	} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point = rl.Vector2{point.x - WINDOW_WIDTH, point.y}
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_poly_bullet_collision(wrapped_points_raw, bullet) {
			hit = true
			return
		}

		if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			wrapped_points := asteroid.base_points
			for &point in wrapped_points {
				point = rl.Vector2{point.x, point.y + WINDOW_HEIGHT}
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_poly_bullet_collision(wrapped_points_raw, bullet) {
				hit = true
				return
			}
		} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			wrapped_points := asteroid.base_points
			for &point in wrapped_points {
				point = rl.Vector2{point.x, point.y - WINDOW_HEIGHT}
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_poly_bullet_collision(wrapped_points_raw, bullet) {
				hit = true
				return
			}
		}
	}

	// Checks if asteroid is wrapping around y-axis
	if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point = rl.Vector2{point.x, point.y + WINDOW_HEIGHT}
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_poly_bullet_collision(wrapped_points_raw, bullet) {
			hit = true
			return
		}

		if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			for &point in wrapped_points {
				point = rl.Vector2{point.x + WINDOW_WIDTH, point.y}
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_poly_bullet_collision(wrapped_points_raw, bullet) {
				hit = true
				return
			}
		} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			for &point in wrapped_points {
				point = rl.Vector2{point.x - WINDOW_WIDTH, point.y}
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_poly_bullet_collision(wrapped_points_raw, bullet) {
				hit = true
				return
			}
		}
	} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		wrapped_points := asteroid.base_points
		for &point in wrapped_points {
			point = rl.Vector2{point.x, point.y - WINDOW_HEIGHT}
		}

		wrapped_points_raw := raw_data(wrapped_points[:])
		if check_poly_bullet_collision(wrapped_points_raw, bullet) {
			hit = true
			return
		}

		if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			for &point in wrapped_points {
				point = rl.Vector2{point.x + WINDOW_WIDTH, point.y}
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_poly_bullet_collision(wrapped_points_raw, bullet) {
				hit = true
				return
			}
		} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			for &point in wrapped_points {
				point = rl.Vector2{point.x - WINDOW_WIDTH, point.y}
			}

			wrapped_points_raw := raw_data(wrapped_points[:])
			if check_poly_bullet_collision(wrapped_points_raw, bullet) {
				hit = true
				return
			}
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

		if hit, bullet_index := check_asteroid_bullet_collision(asteroid, state.bullets[:]); hit {
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

	slice.reverse(remove_indices[:])
	for index in remove_indices {
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
