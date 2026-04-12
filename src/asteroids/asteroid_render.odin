package asteroids

import "core:slice"
import rl "vendor:raylib"

// Draws asteroid sprites
draw_asteroids :: proc(asteroids: []Asteroid) {
	asteroids_clone := slice.clone(asteroids, context.temp_allocator)

	for &asteroid in asteroids_clone {
		for &point in asteroid.base_points {
			point =
				rl.Vector2Rotate(point * ASTEROID_SIZE_VALUE[asteroid.size], asteroid.angle) +
				asteroid.pos
		}

		rl.DrawLineStrip(raw_data(asteroid.base_points[:]), 11, ASTEROID_COLOR)

		draw_asteroids_wrapping(asteroid)
	}
}

// Draws the asteroid sprite wrapping around screen edges
draw_asteroids_wrapping :: proc(asteroid: Asteroid) {
	// Draws asteroid sprite wapping around x-axis
	if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
		points := asteroid.base_points
		for &point in points {
			point.x += WINDOW_WIDTH
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)

		if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			for &point in points {
				point.y += WINDOW_HEIGHT
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			for &point in points {
				point.y -= WINDOW_HEIGHT
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		}
	} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		points := asteroid.base_points
		for &point in points {
			point.x -= WINDOW_WIDTH
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)

		if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			for &point in points {
				point.y += WINDOW_HEIGHT
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			for &point in points {
				point.y -= WINDOW_HEIGHT
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		}
	}

	// Draws asteroid sprite wapping around y-axis
	if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
		points := asteroid.base_points
		for &point in points {
			point.y += WINDOW_HEIGHT
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)

		if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			for &point in points {
				point.x += WINDOW_WIDTH
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			for &point in points {
				point.x -= WINDOW_WIDTH
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		}
	} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
		points := asteroid.base_points
		for &point in points {
			point.y -= WINDOW_HEIGHT
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)

		if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			for &point in points {
				point.x += WINDOW_WIDTH
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			for &point in points {
				point.x -= WINDOW_WIDTH
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		}
	}
}
