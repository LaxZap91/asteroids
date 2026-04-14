package asteroids

import rl "vendor:raylib"

import "../assets"

// Width of the game window
WINDOW_WIDTH :: 2000
// Height of the game window
WINDOW_HEIGHT :: 2000
// Target fps of the game
TARGET_FPS :: 60

main :: proc() {
	// Initialize raylib window
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_UNDECORATED, .WINDOW_HIDDEN})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")
	defer rl.CloseWindow()
	rl.HideCursor()
	rl.SetTargetFPS(TARGET_FPS)

	// Sets icon
	icon := rl.LoadImageFromMemory(assets.LOGO_EXT, assets.LOGO_PTR, assets.LOGO_SIZE)
	rl.SetWindowIcon(icon)
	rl.UnloadImage(icon)

	// Initializes raylib audio
	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	// Initialize game state
	state := make_state()
	defer delete_state(&state)

	// Initialize audio
	sounds := make_sounds()
	defer delete_sounds(&sounds)

	// Shows window after loading data
	rl.ClearWindowState({.WINDOW_HIDDEN})

	// Game loop
	for !rl.WindowShouldClose() {
		state.dt = rl.GetFrameTime()

		// Update game
		if state.game_screen == .GAME {
			update_game(&state, sounds)
		} else if state.game_screen == .MENU {
			update_menu(&state, sounds)
		} else if state.game_screen == .HELP {
			update_help(&state, sounds)
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		// Draw game
		if state.game_screen == .GAME {
			draw_game(&state)
		} else if state.game_screen == .MENU {
			draw_menu(&state)
		} else if state.game_screen == .HELP {
			draw_help(&state)
		}

		rl.EndDrawing()

		free_all(context.temp_allocator)
	}
}
