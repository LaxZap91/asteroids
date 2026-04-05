package asteroids

import rl "vendor:raylib"

BULLET_LENGTH :: 40
BULLET_SPEED :: 1500

Bullet :: struct {
	pos:   rl.Vector2,
	vel:   rl.Vector2,
	angle: f32,
}

make_bullet :: proc(player: Player) -> Bullet {
	pos := rl.Vector2Rotate(rl.Vector2{0, -2} * PLAYER_SCALE, player.angle) + player.pos
	vel := rl.Vector2Rotate({0, -1} * BULLET_SPEED, player.angle)
	return {pos, vel, player.angle}
}

update_bullets :: proc(bullets: ^[dynamic]Bullet, dt: f32) {
	for &bullet, index in bullets {
		bullet.pos += bullet.vel * dt

		if bullet.pos.x < 0 ||
		   bullet.pos.x > WINDOW_WIDTH ||
		   bullet.pos.y < 0 ||
		   bullet.pos.y > WINDOW_HEIGHT {
			unordered_remove(bullets, index)
		}
	}
}

draw_bullets :: proc(bullets: []Bullet) {
	for bullet in bullets {
		rl.DrawLineEx(
			bullet.pos,
			bullet.pos + (rl.Vector2Normalize(bullet.vel) * BULLET_LENGTH),
			10,
			rl.RED,
		)
	}
}
