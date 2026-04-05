package asteroids

import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH :: 2000
WINDOW_HEIGHT :: 2000
TARGET_FPS :: 60

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
