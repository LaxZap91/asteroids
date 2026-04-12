package asteroids

import rl "vendor:raylib"

// Draws the player sprite
draw_player :: proc(player: Player) {
	if player.state == .Alive {
		// Player sprite point positions
		points := generate_player_points(player)

		rl.DrawLineStrip(
			raw_data([]rl.Vector2{points[0], points[1], points[3], points[2], points[0]}),
			5,
			PLAYER_COLOR,
		)

		draw_player_wrapping(player, points)
		if (player.shield > 0) {
			draw_shield(player)
			draw_shield_wrapping(player)
		}
	}
}

// Draws the player shield
draw_shield :: proc(player: Player) {
	points := base_decagon
	for &point in points {
		point = rl.Vector2Rotate(point * PLAYER_SHIELD_RADIUS, player.angle) + player.pos
	}

	rl.DrawLineStrip(
		raw_data(
			[]rl.Vector2 {
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
			},
		),
		11,
		PLAYER_SHIELD_COLOR,
	)
}

// Draws the player shield if the player is wrapping around screen
draw_shield_wrapping :: proc(player: Player) {
	// Draws player sprite wapping around x-axis
	if player.pos.x < PLAYER_SHIELD_RADIUS {
		points := base_decagon
		for &point in points {
			point =
				rl.Vector2Rotate(point * PLAYER_SHIELD_RADIUS, player.angle) +
				{player.pos.x + WINDOW_WIDTH, player.pos.y}
		}

		rl.DrawLineStrip(
			raw_data(
				[]rl.Vector2 {
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
				},
			),
			11,
			PLAYER_SHIELD_COLOR,
		)

		if player.pos.y < PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.y += WINDOW_HEIGHT
			}

			rl.DrawLineStrip(
				raw_data(
					[]rl.Vector2 {
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
					},
				),
				11,
				PLAYER_SHIELD_COLOR,
			)
		} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.y -= WINDOW_HEIGHT
			}

			rl.DrawLineStrip(
				raw_data(
					[]rl.Vector2 {
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
					},
				),
				11,
				PLAYER_SHIELD_COLOR,
			)
		}
	} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
		points := base_decagon
		for &point in points {
			point =
				rl.Vector2Rotate(point * PLAYER_SHIELD_RADIUS, player.angle) +
				{player.pos.x - WINDOW_WIDTH, player.pos.y}
		}

		rl.DrawLineStrip(
			raw_data(
				[]rl.Vector2 {
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
				},
			),
			11,
			PLAYER_SHIELD_COLOR,
		)

		if player.pos.y < PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.y += WINDOW_HEIGHT
			}

			rl.DrawLineStrip(
				raw_data(
					[]rl.Vector2 {
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
					},
				),
				11,
				PLAYER_SHIELD_COLOR,
			)
		} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.y -= WINDOW_HEIGHT
			}

			rl.DrawLineStrip(
				raw_data(
					[]rl.Vector2 {
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
					},
				),
				11,
				PLAYER_SHIELD_COLOR,
			)
		}
	}

	// Draws player sprite wapping around y-axis
	if player.pos.y < PLAYER_SHIELD_RADIUS {
		points := base_decagon
		for &point in points {
			point =
				rl.Vector2Rotate(point * PLAYER_SHIELD_RADIUS, player.angle) +
				{player.pos.x, player.pos.y + WINDOW_HEIGHT}
		}

		rl.DrawLineStrip(
			raw_data(
				[]rl.Vector2 {
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
				},
			),
			11,
			PLAYER_SHIELD_COLOR,
		)

		if player.pos.x < PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.x += WINDOW_WIDTH
			}

			rl.DrawLineStrip(
				raw_data(
					[]rl.Vector2 {
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
					},
				),
				11,
				PLAYER_SHIELD_COLOR,
			)
		} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.x -= WINDOW_WIDTH
			}

			rl.DrawLineStrip(
				raw_data(
					[]rl.Vector2 {
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
					},
				),
				11,
				PLAYER_SHIELD_COLOR,
			)
		}
	} else if player.pos.y > WINDOW_HEIGHT - PLAYER_SHIELD_RADIUS {
		points := base_decagon
		for &point in points {
			point =
				rl.Vector2Rotate(point * PLAYER_SHIELD_RADIUS, player.angle) +
				{player.pos.x, player.pos.y - WINDOW_HEIGHT}
		}

		rl.DrawLineStrip(
			raw_data(
				[]rl.Vector2 {
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
				},
			),
			11,
			PLAYER_SHIELD_COLOR,
		)

		if player.pos.x < PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.x += WINDOW_WIDTH
			}

			rl.DrawLineStrip(
				raw_data(
					[]rl.Vector2 {
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
					},
				),
				11,
				PLAYER_SHIELD_COLOR,
			)
		} else if player.pos.x > WINDOW_WIDTH - PLAYER_SHIELD_RADIUS {
			for &point in points {
				point.x -= WINDOW_WIDTH
			}

			rl.DrawLineStrip(
				raw_data(
					[]rl.Vector2 {
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
					},
				),
				11,
				PLAYER_SHIELD_COLOR,
			)
		}
	}
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

		if player.pos.y < PLAYER_SCALE * 2 {
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

		if player.pos.y < PLAYER_SCALE * 2 {
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

		if player.pos.x < PLAYER_SCALE * 2 {
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

		if player.pos.x < PLAYER_SCALE * 2 {
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
