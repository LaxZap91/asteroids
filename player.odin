package asteroids

import rl "vendor:raylib"

PLAYER_ROTATION_AMOUNT :: 5 * rl.DEG2RAD
PLAYER_SCALE :: 20
PLAYER_SPEED :: 300
PLAYER_SPEED_CAP :: PLAYER_SPEED * 4
PLAYER_SHOOT_DELAY :: 15

Player :: struct {
	pos:         rl.Vector2,
	vel:         rl.Vector2,
	angle:       f32,
	shoot_timer: uint,
}

wrap_position :: proc(player: ^Player) {
	if player.pos.x < 0 {
		player.pos.x = WINDOW_WIDTH
	} else if player.pos.x > WINDOW_WIDTH {
		player.pos.x = 0
	}

	if player.pos.y < 0 {
		player.pos.y = WINDOW_HEIGHT
	} else if player.pos.y > WINDOW_HEIGHT {
		player.pos.y = 0
	}
}

wrap_angle :: proc(player: ^Player) {
	if player.angle < -rl.PI {
		player.angle += 2 * rl.PI
	} else if player.angle > rl.PI {
		player.angle -= 2 * rl.PI
	}
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

	rl.DrawTriangle(top, right, left, rl.BLUE)
}
