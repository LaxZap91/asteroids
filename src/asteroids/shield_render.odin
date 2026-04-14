package asteroids

import rl "vendor:raylib"

// Gets points loop for shield
get_shield_points :: proc(points: [10]rl.Vector2) -> []rl.Vector2 {
	points_slice := make([]rl.Vector2, 11, context.temp_allocator)

	for &point, index in points_slice {
		point = points[index % 10]
	}

	return points_slice
}

// Gets the points of the shield shifted and rotated to match player
get_shield_initial_points :: proc(player: Player) -> (points: [10]rl.Vector2) {
	points = base_decagon
	for &point in points {
		point = rotate_shift_point(point * PLAYER_SHIELD_RADIUS, player.angle, player.pos)
	}

	return
}

// Draws the player shield
draw_shield :: proc(player: Player) {
	points := get_shield_initial_points(player)

	points_slice := get_shield_points(points)
	rl.DrawLineStrip(raw_data(points_slice), 11, PLAYER_SHIELD_COLOR)

	draw_shield_wrapping(player)
}

// Draws the shield if the player is wrapping around screen
draw_shield_wrapping :: proc(player: Player) {
	// Draws shield sprite wapping around x-axis
	if player.pos.x < PLAYER_SHIELD_RADIUS {
		points := get_shield_initial_points(player)
		for &point in points {
			point.x += WINDOW_WIDTH
		}

		points_slice := get_shield_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 11, PLAYER_SHIELD_COLOR)

		draw_shield_wrapping_y(player, points)
	} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
		points := get_shield_initial_points(player)
		for &point in points {
			point.x -= WINDOW_WIDTH
		}

		points_slice := get_shield_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 11, PLAYER_SHIELD_COLOR)

		draw_shield_wrapping_y(player, points)
	}

	// Draws shield sprite wapping around y-axis
	if player.pos.y < PLAYER_SHIELD_RADIUS {
		points := get_shield_initial_points(player)
		for &point in points {
			point.y += WINDOW_HEIGHT
		}

		points_slice := get_shield_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 11, PLAYER_SHIELD_COLOR)

		draw_shield_wrapping_x(player, points)
	} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
		points := get_shield_initial_points(player)
		for &point in points {
			point.y -= WINDOW_HEIGHT
		}

		points_slice := get_shield_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 11, PLAYER_SHIELD_COLOR)

		draw_shield_wrapping_x(player, points)
	}
}

// Draws shield sprite wapping around y-axis
draw_shield_wrapping_y :: proc(player: Player, points: [10]rl.Vector2) {
	if player.pos.y < PLAYER_SHIELD_RADIUS {
		points := points
		for &point in points {
			point.y += WINDOW_HEIGHT
		}

		points_slice := get_shield_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 11, PLAYER_SHIELD_COLOR)
	} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
		points := points
		for &point in points {
			point.y -= WINDOW_HEIGHT
		}

		points_slice := get_shield_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 11, PLAYER_SHIELD_COLOR)
	}
}

// Draws shield sprite wapping around x-axis
draw_shield_wrapping_x :: proc(player: Player, points: [10]rl.Vector2) {
	if player.pos.x < PLAYER_SHIELD_RADIUS {
		points := points
		for &point in points {
			point.x += WINDOW_WIDTH
		}

		points_slice := get_shield_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 11, PLAYER_SHIELD_COLOR)
	} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
		points := points
		for &point in points {
			point.x -= WINDOW_WIDTH
		}

		points_slice := get_shield_points(points)
		rl.DrawLineStrip(raw_data(points_slice), 11, PLAYER_SHIELD_COLOR)
	}
}
