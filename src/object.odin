package asteroids

import rl "vendor:raylib"

Object :: struct {
	pos:   rl.Vector2,
	vel:   rl.Vector2,
	angle: f32,
}

// Wraps object position around screen
wrap_position :: proc(object: ^Object) {
	// Wrap around x-axis
	if object.pos.x < 0 {
		object.pos.x = WINDOW_WIDTH
	} else if object.pos.x > WINDOW_WIDTH {
		object.pos.x = 0
	}

	// Wrap around y-axis
	if object.pos.y < 0 {
		object.pos.y = WINDOW_HEIGHT
	} else if object.pos.y > WINDOW_HEIGHT {
		object.pos.y = 0
	}
}

// Wraps object angles
wrap_angle :: proc(object: ^Object) {
	if object.angle < -rl.PI {
		object.angle += 2 * rl.PI
	} else if object.angle > rl.PI {
		object.angle -= 2 * rl.PI
	}
}
