package logo

import rl "vendor:raylib"

// Size multiplication of the player spite
PLAYER_SCALE :: 20
// Height of the player sprite
PLAYER_HEIGHT :: 4
// Width of the player sprite
PLAYER_WIDTH :: 2
// Color of the player sprite
PLAYER_COLOR :: rl.WHITE

WINDOW_WIDTH :: 100
WINDOW_HEIGHT :: 100

draw_player :: proc(pos: rl.Vector2, angle: f32) {
	// Player sprite point positions
	top := rl.Vector2Rotate(rl.Vector2{0, -PLAYER_HEIGHT / 2} * PLAYER_SCALE, angle) + pos
	left :=
		rl.Vector2Rotate(rl.Vector2{PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE, angle) +
		pos
	right :=
		rl.Vector2Rotate(rl.Vector2{-PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE, angle) +
		pos
	center := rl.Vector2Rotate(rl.Vector2{0, PLAYER_HEIGHT / 4} * PLAYER_SCALE, angle) + pos

	rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
}

main :: proc() {
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_UNDECORATED})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")
	rl.HideCursor()
	defer rl.CloseWindow()

	texture := rl.LoadRenderTexture(WINDOW_WIDTH, WINDOW_HEIGHT)
	defer rl.UnloadRenderTexture(texture)

	rl.BeginTextureMode(texture)
	rl.ClearBackground(rl.BLACK)

	draw_player({f32(rl.GetScreenWidth()) / 2, f32(rl.GetScreenHeight()) / 2}, rl.DEG2RAD * -135)

	rl.EndTextureMode()

	image := rl.LoadImageFromTexture(texture.texture)
	defer rl.UnloadImage(image)
	rl.ExportImage(image, "assets/logo.png")
}
