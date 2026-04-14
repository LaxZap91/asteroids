package asteroids

import rl "vendor:raylib"

// Draws asteroid sprites
draw_asteroids :: proc(asteroids: []Asteroid) {
	for asteroid in asteroids {
		points := asteroid.base_points
		for &point in points {
			point = rotate_shift_point(
				point * ASTEROID_SIZE_VALUE[asteroid.size],
				asteroid.angle,
				asteroid.pos,
			)
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, ASTEROID_COLOR)

		draw_asteroids_wrapping(asteroid, points)
	}
}

// Draws the asteroid sprite wrapping around screen edges
draw_asteroids_wrapping :: proc(asteroid: Asteroid, points: [11]rl.Vector2) {
	// Draws asteroid sprite wapping around x-axis
	if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] {
		points := points
		for &point in points {
			point.x += WINDOW_WIDTH
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)

		draw_asteroids_wrapping_y(asteroid, points)
	} else if asteroid.pos.x > WINDOW_WIDTH - ASTEROID_SIZE_VALUE[asteroid.size] {
		points := points
		for &point in points {
			point.x -= WINDOW_WIDTH
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)

		draw_asteroids_wrapping_y(asteroid, points)
	}

	// Draws asteroid sprite wapping around y-axis
	if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] {
		points := points
		for &point in points {
			point.y += WINDOW_HEIGHT
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)

		draw_asteroids_wrapping_x(asteroid, points)
	} else if asteroid.pos.y > WINDOW_HEIGHT - ASTEROID_SIZE_VALUE[asteroid.size] {
		points := points
		for &point in points {
			point.y -= WINDOW_HEIGHT
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)

		draw_asteroids_wrapping_x(asteroid, points)
	}
}

// Draws asteroids wrapping around the y-axis
draw_asteroids_wrapping_y :: proc(asteroid: Asteroid, points: [11]rl.Vector2) {
	if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] {
		points := points
		for &point in points {
			point.y += WINDOW_HEIGHT
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
	} else if asteroid.pos.y > WINDOW_HEIGHT - ASTEROID_SIZE_VALUE[asteroid.size] {
		points := points
		for &point in points {
			point.y -= WINDOW_HEIGHT
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
	}
}

// Draws asteroids wrapping around the x-axis
draw_asteroids_wrapping_x :: proc(asteroid: Asteroid, points: [11]rl.Vector2) {
	if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] {
		points := points
		for &point in points {
			point.x += WINDOW_WIDTH
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
	} else if asteroid.pos.x > WINDOW_WIDTH - ASTEROID_SIZE_VALUE[asteroid.size] {
		points := points
		for &point in points {
			point.x -= WINDOW_WIDTH
		}

		rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
	}
}
