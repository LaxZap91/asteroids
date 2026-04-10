package asteroids

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

// Width of the game window
WINDOW_WIDTH :: 2000
// Height of the game window
WINDOW_HEIGHT :: 2000
// Target fps of the game
TARGET_FPS :: 60

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	// Initialize raylib window
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_UNDECORATED})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Asteroids")
	defer rl.CloseWindow()
	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()
	rl.SetTargetFPS(TARGET_FPS)

	// Initialize game state
	state := make_state()
	defer delete_state(&state)

	// Initialize audio
	sounds := make_sounds()
	defer delete_sounds(&sounds)

	// Game loop
	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// Update game
		if state.game_screen == .GAME {
			update_game(&state, sounds, dt)
		} else if state.game_screen == .MENU {
			update_menu(&state, sounds, dt)
		} else if state.game_screen == .HELP {
			update_help(&state, sounds, dt)
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
