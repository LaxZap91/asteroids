package asteroids

import "core:fmt"
import rl "vendor:raylib"

PLAYER_ROTATION_AMOUNT :: 5 * rl.DEG2RAD
PLAYER_SCALE :: 20
PLAYER_SPEED :: 60
PLAYER_SPEED_CAP :: PLAYER_SPEED * 35
PLAYER_SHOOT_DELAY :: 15
PLAYER_COLOR :: rl.WHITE

Player :: struct {
	using obj:   Object,
	shoot_timer: uint,
}

clamp_speed :: proc(player: ^Player) {
	player.vel = rl.Vector2ClampValue(player.vel, 0, PLAYER_SPEED_CAP)
}

update_player :: proc(player: ^Player, dt: f32) {
	clamp_speed(player)
	player.pos += player.vel * dt
	if player.shoot_timer > 0 {
		player.shoot_timer -= 1
	}

	wrap_position(player)
	wrap_angle(player)
}

draw_player :: proc(player: Player) {
	top := rl.Vector2Rotate(rl.Vector2{0, -2} * PLAYER_SCALE, player.angle) + player.pos
	left := rl.Vector2Rotate(rl.Vector2{1, 2} * PLAYER_SCALE, player.angle) + player.pos
	right := rl.Vector2Rotate(rl.Vector2{-1, 2} * PLAYER_SCALE, player.angle) + player.pos
	center := rl.Vector2Rotate(rl.Vector2{0, 1} * PLAYER_SCALE, player.angle) + player.pos

	points := raw_data([]rl.Vector2{top, left, center, right, top})

	rl.DrawLineStrip(points, 5, PLAYER_COLOR)

	if player.pos.x < PLAYER_SCALE * 2 {
		top_right := rl.Vector2{top.x + WINDOW_WIDTH, top.y}
		left_right := rl.Vector2{left.x + WINDOW_WIDTH, left.y}
		right_right := rl.Vector2{right.x + WINDOW_WIDTH, right.y}
		center_right := rl.Vector2{center.x + WINDOW_WIDTH, center.y}

		points_right := raw_data([]rl.Vector2{top_right, left_right, center_right, right_right, top_right})
		rl.DrawLineStrip(points_right, 5, PLAYER_COLOR)
	}
	else if player.pos.x > WINDOW_WIDTH - (PLAYER_SCALE * 2) {
		top_left := rl.Vector2{top.x - WINDOW_WIDTH, top.y}
		left_left := rl.Vector2{left.x - WINDOW_WIDTH, left.y}
		right_left := rl.Vector2{right.x - WINDOW_WIDTH, right.y}
		center_left := rl.Vector2{center.x - WINDOW_WIDTH, center.y}

		points_left := raw_data([]rl.Vector2{top_left, left_left, center_left, right_left, top_left})
		rl.DrawLineStrip(points_left, 5, PLAYER_COLOR)
	}

	if player.pos.y < PLAYER_SCALE * 2 {
		top_bottom := rl.Vector2{top.x, top.y + WINDOW_HEIGHT}
		left_bottom := rl.Vector2{left.x, left.y + WINDOW_HEIGHT}
		right_bottom := rl.Vector2{right.x, right.y + WINDOW_HEIGHT}
		center_bottom := rl.Vector2{center.x, center.y + WINDOW_HEIGHT}

		points_bottom := raw_data([]rl.Vector2{top_bottom, left_bottom, center_bottom, right_bottom, top_bottom})
		rl.DrawLineStrip(points_bottom, 5, PLAYER_COLOR)
	}
	else if player.pos.y > WINDOW_HEIGHT - (PLAYER_SCALE * 2) {
		top_top := rl.Vector2{top.x, top.y - WINDOW_HEIGHT}
		left_top := rl.Vector2{left.x, left.y - WINDOW_HEIGHT}
		right_top := rl.Vector2{right.x, right.y - WINDOW_HEIGHT}
		center_top := rl.Vector2{center.x, center.y - WINDOW_HEIGHT}

		points_top := raw_data([]rl.Vector2{top_top, left_top, center_top, right_top, top_top})
		rl.DrawLineStrip(points_top, 5, PLAYER_COLOR)
	}
}
