package asteroids

import rl "vendor:raylib"

// Gets the player rendering points in rendering order
get_player_points :: proc(points: [4]rl.Vector2) -> []rl.Vector2 {
	points_slice := make([]rl.Vector2, 5, context.temp_allocator)

	points_slice[0] = points[0]
	points_slice[1] = points[1]
	points_slice[2] = points[3]
	points_slice[3] = points[2]
	points_slice[4] = points[0]

	return points_slice
}

// Draws the player sprite
draw_player :: proc(player: Player) {
	if player.state == .Alive {
		// Player sprite point positions
		points := generate_player_points(player)

		points_slice := get_player_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)

		draw_player_wrapping(player)

		if (player.shield > 0) {
			draw_shield(player)
		}
	}
}

// Draws the player sprite wrapping around screen edges
draw_player_wrapping :: proc(player: Player) {
	// Draws player sprite wapping around x-axis
	if player.pos.x < PLAYER_SCALE * 2 {
		points := generate_player_points(player)
		for &point in points {
			point.x += WINDOW_WIDTH
		}

		points_slice := get_player_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)

		draw_player_wrapping_y(player, points)
	} else if player.pos.x > WINDOW_WIDTH - (PLAYER_SCALE * 2) {
		points := generate_player_points(player)
		for &point in points {
			point.x -= WINDOW_WIDTH
		}

		points_slice := get_player_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)

		draw_player_wrapping_y(player, points)
	}

	// Draws player sprite wapping around y-axis
	if player.pos.y < PLAYER_SCALE * 2 {
		points := generate_player_points(player)
		for &point in points {
			point.y += WINDOW_HEIGHT
		}

		points_slice := get_player_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)

		draw_player_wrapping_x(player, points)
	} else if player.pos.y > WINDOW_HEIGHT - (PLAYER_SCALE * 2) {
		points := generate_player_points(player)
		for &point in points {
			point.y -= WINDOW_HEIGHT
		}

		points_slice := get_player_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)

		draw_player_wrapping_x(player, points)
	}
}

// Draws player sprite wrapping around the y-axis
draw_player_wrapping_y :: proc(player: Player, points: [4]rl.Vector2) {points := points
	if player.pos.y < PLAYER_SCALE * 2 {
		points := points
		for &point in points {
			point.y += WINDOW_HEIGHT
		}

		points_slice := get_player_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)
	} else if player.pos.y > WINDOW_HEIGHT - (PLAYER_SCALE * 2) {
		points := points
		for &point in points {
			point.y -= WINDOW_HEIGHT
		}

		points_slice := get_player_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)
	}
}

// Draws player sprite wrapping around the x-axis
draw_player_wrapping_x :: proc(player: Player, points: [4]rl.Vector2) {
	if player.pos.x < PLAYER_SCALE * 2 {
		points := points
		for &point in points {
			point.x += WINDOW_WIDTH
		}

		points_slice := get_player_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)
	} else if player.pos.x > WINDOW_WIDTH - (PLAYER_SCALE * 2) {
		points := points
		for &point in points {
			point.x -= WINDOW_WIDTH
		}

		points_slice := get_player_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)
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

		points_slice := []rl.Vector2{top, left, center, right, top}

		rl.DrawLineStrip(raw_data(points_slice), 5, PLAYER_COLOR)
	}
}
