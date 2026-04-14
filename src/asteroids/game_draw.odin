package asteroids

import "core:fmt"
import rl "vendor:raylib"

// Draws the menu
draw_menu :: proc(state: ^State) {
	draw_asteroids(state.menu_asteroids[:])

	rl.DrawText(
		"Asteroids",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Asteroids", FONT_LARGE) / 2)),
		i32(WINDOW_HEIGHT / 3),
		FONT_LARGE,
		rl.WHITE,
	)

	high_score_text := fmt.ctprintf("High Score: %v", state.high_score)
	rl.DrawText(
		high_score_text,
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText(high_score_text, FONT_MEDIUM) / 2)),
		i32(WINDOW_HEIGHT / 2),
		FONT_MEDIUM,
		rl.WHITE,
	)

	rl.DrawText(
		"PRESS SPACE TO PLAY",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("PRESS SPACE TO PLAY", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2) + FONT_SMALL + FONT_MEDIUM,
		FONT_SMALL,
		rl.WHITE,
	)

	help_text_height := i32(
		rl.MeasureTextEx(rl.GetFontDefault(), "PRESS H FOR HELP", FONT_SMALL, 0).y,
	)
	rl.DrawText(
		"PRESS H FOR HELP",
		50,
		WINDOW_HEIGHT - 50 - help_text_height / 2,
		FONT_TINY,
		rl.WHITE,
	)
}
// Draws the help menu
draw_help :: proc(state: ^State) {
	draw_asteroids(state.menu_asteroids[:])

	rl.DrawText(
		"Help",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Help", FONT_LARGE) / 2)),
		i32(WINDOW_HEIGHT / 3),
		FONT_LARGE,
		rl.WHITE,
	)

	rl.DrawText(
		"Movement: Arrow Keys",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Movement: Arrow Keys", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2),
		FONT_SMALL,
		rl.WHITE,
	)

	rl.DrawText(
		"Shoot: Space",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Shoot: Space", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2) + (2 * FONT_SMALL),
		FONT_SMALL,
		rl.WHITE,
	)

	rl.DrawText(
		"Menu: Backspace",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Menu: Backspace", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2) + (4 * FONT_SMALL),
		FONT_SMALL,
		rl.WHITE,
	)

	rl.DrawText(
		"Quit: Escape",
		i32((WINDOW_WIDTH / 2) - (rl.MeasureText("Quit: Escape", FONT_SMALL) / 2)),
		i32(WINDOW_HEIGHT / 2) + (6 * FONT_SMALL),
		FONT_SMALL,
		rl.WHITE,
	)
}

// Draws the game
draw_game :: proc(state: ^State) {
	draw_player(state.player)
	draw_player_lives(state.player)
	draw_bullets(state.bullets[:])
	draw_asteroids(state.asteroids[:])
	draw_particles(state.particles[:])

	// Draws score
	score_text := fmt.ctprintf("Score: %v", state.score)
	rl.DrawText(score_text, (PLAYER_WIDTH / 2) * PLAYER_SCALE + 15, 50, FONT_SMALL, rl.WHITE)
}
