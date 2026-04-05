package asteroids

import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH :: 2000
WINDOW_HEIGHT :: 2000
TARGET_FPS :: 60

PLAYER_ROTATION_AMOUNT :: 5 * rl.DEG2RAD
PLAYER_SCALE :: 20
PLAYER_SPEED :: 300
PLAYER_SPEED_CAP :: PLAYER_SPEED * 4
PLAYER_SHOOT_DELAY :: 15

BULLET_LENGTH :: 40
BULLET_SPEED :: 1500

Player :: struct {
	pos:         rl.Vector2,
	vel:         rl.Vector2,
	angle:       f32,
	shoot_timer: uint,
}

Bullet :: struct {
	pos:   rl.Vector2,
	vel:   rl.Vector2,
	angle: f32,
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

make_bullet :: proc(player: Player) -> Bullet {
	pos := rl.Vector2Rotate(rl.Vector2{0, -2} * PLAYER_SCALE, player.angle) + player.pos
	vel := rl.Vector2Rotate({0, -1} * BULLET_SPEED, player.angle)
	return {pos, vel, player.angle}
}

draw_player :: proc(player: Player) {
	top := rl.Vector2Rotate(rl.Vector2{0, -2} * PLAYER_SCALE, player.angle) + player.pos
	left := rl.Vector2Rotate(rl.Vector2{1, 2} * PLAYER_SCALE, player.angle) + player.pos
	right := rl.Vector2Rotate(rl.Vector2{-1, 2} * PLAYER_SCALE, player.angle) + player.pos

	rl.DrawTriangle(top, right, left, rl.BLUE)
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

update_player :: proc(player: ^Player, dt: f32) {
	clamp_speed(player)
	player.pos += player.vel * dt
	if player.shoot_timer > 0 {
		player.shoot_timer -= 1
	}

	wrap_position(player)
	wrap_angle(player)
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

main :: proc() {
	player: Player
	player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}

	bullets := make([dynamic]Bullet)
	defer delete(bullets)

	rl.SetTraceLogLevel(.WARNING)
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")
	rl.SetTargetFPS(TARGET_FPS)

	vel_base := rl.Vector2{0, -1} * PLAYER_SPEED

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// Update
		if rl.IsKeyDown(.W) do player.vel += rl.Vector2Rotate(vel_base, player.angle)
		if rl.IsKeyDown(.S) do player.vel -= rl.Vector2Rotate(vel_base, player.angle)
		if rl.IsKeyDown(.A) do player.angle -= PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.D) do player.angle += PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.SPACE) && player.shoot_timer == 0 {
			append(&bullets, make_bullet(player))
			player.shoot_timer = PLAYER_SHOOT_DELAY
		}

		update_player(&player, dt)
		update_bullets(&bullets, dt)

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)

		draw_player(player)
		draw_bullets(bullets[:])

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
