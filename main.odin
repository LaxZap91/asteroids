package asteroids

import "core:math"
import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH :: 2000
WINDOW_HEIGHT :: 2000
TARGET_FPS :: 60

PLAYER_ROTATION_AMOUNT :: 5 * rl.DEG2RAD
PLAYER_SCALE :: 20
PLAYER_SPEED :: 5
PLAYER_SPEED_CAP :: PLAYER_SPEED * 4

Player :: struct {
	pos: rl.Vector2,
	vel: rl.Vector2,
	angle: f32,
}

main :: proc() {
	player: Player
	player.pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}

	rl.SetTraceLogLevel(.WARNING)
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")
	rl.SetTargetFPS(TARGET_FPS)

	top_base := rl.Vector2{0, -2} * PLAYER_SCALE
	left_base := rl.Vector2{1, 2} * PLAYER_SCALE
	right_base := rl.Vector2{-1, 2} * PLAYER_SCALE
	vel_base := rl.Vector2{0, 1} * PLAYER_SPEED

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// Update
		if rl.IsKeyDown(.W) do player.vel -= rl.Vector2Rotate(vel_base, player.angle)
		if rl.IsKeyDown(.S) do player.vel += rl.Vector2Rotate(vel_base, player.angle)
		if rl.IsKeyDown(.A) do player.angle -= PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.D) do player.angle += PLAYER_ROTATION_AMOUNT

		player.vel = rl.Vector2ClampValue(player.vel, 0, PLAYER_SPEED_CAP)
		player.pos += player.vel

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)

		top := rl.Vector2Rotate(top_base, player.angle) + player.pos
		left := rl.Vector2Rotate(left_base, player.angle) + player.pos
		right := rl.Vector2Rotate(right_base, player.angle) + player.pos
		rl.DrawTriangle(top, right, left, rl.BLUE)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
