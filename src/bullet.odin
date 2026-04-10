package asteroids

import "core:slice"
import rl "vendor:raylib"

// Speed that the bullet moves
BULLET_SPEED :: PLAYER_SPEED_CAP + 100
// Color of the bullet sprite
BULLET_COLOR :: rl.WHITE
// Size of the bullet sprite
BULLET_SIZE :: 10
// Maximum number of bullets
BULLET_MAX :: 12

Bullet :: struct {
	using obj: Object,
}

// Creates a bullet
make_bullet :: proc(player: Player) -> Bullet {
	pos :=
		rl.Vector2Rotate(rl.Vector2{0, -PLAYER_HEIGHT / 2} * PLAYER_SCALE, player.angle) +
		player.pos
	vel := rl.Vector2Rotate({0, -1} * BULLET_SPEED, player.angle)
	return {{pos, vel, player.angle}}
}

// Updates bullets
update_bullets :: proc(state: ^State, dt: f32) {
	remove_indices := make([dynamic]int, context.temp_allocator)

	for &bullet, index in state.bullets {
		bullet.pos += bullet.vel * dt

		// Remove if off screen
		if bullet.pos.x < 0 ||
		   bullet.pos.x > WINDOW_WIDTH ||
		   bullet.pos.y < 0 ||
		   bullet.pos.y > WINDOW_HEIGHT {
			append(&remove_indices, index)
		}
	}

	slice.reverse(remove_indices[:])
	for index in remove_indices {
		unordered_remove(&state.bullets, index)
	}
}

// Draws bullet sprite
draw_bullets :: proc(bullets: []Bullet) {
	for bullet in bullets {
		rl.DrawRectangle(
			i32(bullet.pos.x - (BULLET_SIZE / 2)),
			i32(bullet.pos.y - (BULLET_SIZE / 2)),
			BULLET_SIZE,
			BULLET_SIZE,
			BULLET_COLOR,
		)
	}
}
