package asteroids

import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH :: 2000
WINDOW_HEIGHT :: 2000

main :: proc() {
	rl.SetTraceLogLevel(.WARNING)
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)

		rl.DrawCircle(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 100, rl.RED)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
