package asteroids

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
}
