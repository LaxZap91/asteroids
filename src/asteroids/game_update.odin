package asteroids

import "core:math/rand"
import rl "vendor:raylib"

// Updates the state of the menu
update_menu :: proc(state: ^State, sounds: Sounds) {
	if rl.IsKeyPressed(.H) {
		state.game_screen = .HELP
		rl.PlaySound(sounds.select)
	} else if state.restart_delay == 0 && rl.IsKeyPressed(.SPACE) {
		reset_game_full(state)
		rl.PlaySound(sounds.select)
	} else if state.restart_delay > 0 {
		state.restart_delay -= 1
	}

	update_menu_asteroids(state)
}

// Updates the state the the help menu
update_help :: proc(state: ^State, sounds: Sounds) {
	if rl.IsKeyPressed(.BACKSPACE) {
		state.game_screen = .MENU
		rl.PlaySound(sounds.select)
	}

	update_menu_asteroids(state)
}

// Updates the state of the game
update_game :: proc(state: ^State, sounds: Sounds) {
	if rl.IsKeyPressed(.BACKSPACE) {
		state.game_screen = .MENU
		state.score = 0
		state.restart_delay = RESTART_DELAY
		rl.PlaySound(sounds.select)
	}

	// Respawns or moves to menu if player is dead
	if state.player.state == .Dead && state.player.death_timer == 0 {
		player_respawn(state)
	}

	// Decrements stage change timer if alive
	if state.player.state == .Alive {
		player_update_stage(state)
	}

	spawn_asteroids(state)

	// Update game objects
	update_player(state, sounds)
	update_bullets(state)
	update_asteroids(state, sounds)
	update_particles(state)
}

// Updates the player stage
player_update_stage :: proc(state: ^State) {
	if state.stage_timer > 0 {
		state.stage_timer -= 1
	} else {
		switch state.stage {
		case .EASY:
			state.stage = .MEDIUM
		case .MEDIUM, .HARD:
			state.stage = .HARD
		}

		state.score += STAGE_NEXT_POINTS
		state.stage_timer = STAGE_TIME
		state.player.shield = PLAYER_SHIELD_TIME
	}
}

// Spawns asteroids if room
spawn_asteroids :: proc(state: ^State) {
	asteroid_increment := ASTEROID_MAX_INCREMENT * int(state.stage)
	room_for_spawn := len(state.asteroids) < (ASTEROID_SOFT_MAX + asteroid_increment)

	if state.asteroid_spawn_counter == 0 && room_for_spawn {
		append(&state.asteroids, make_asteroid_rand())
		state.asteroid_spawn_counter = uint(rand.int_range(ASTEROID_MIN_DELAY, ASTEROID_MAX_DELAY))
	} else if state.asteroid_spawn_counter > 0 && room_for_spawn {
		state.asteroid_spawn_counter -= 1
	}
}

// Respawns player or goes to menu
player_respawn :: proc(state: ^State) {
	if state.player.lives == 0 {
		state.game_screen = .MENU
		if state.score > state.high_score {
			state.high_score = state.score
		}
		state.score = 0
		state.restart_delay = RESTART_DELAY
	} else {
		reset_game_respawn(state)
	}
}
