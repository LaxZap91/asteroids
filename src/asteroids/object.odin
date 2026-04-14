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
		object.pos.x += WINDOW_WIDTH
	} else if object.pos.x > WINDOW_WIDTH {
		object.pos.x -= WINDOW_WIDTH
	}

	// Wrap around y-axis
	if object.pos.y < 0 {
		object.pos.y += WINDOW_HEIGHT
	} else if object.pos.y > WINDOW_HEIGHT {
		object.pos.y -= WINDOW_HEIGHT
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

// Rotates and shifts a point based on given angle and position
rotate_shift_point :: proc(point: rl.Vector2, angle: f32, shift: rl.Vector2) -> rl.Vector2 {
	return rl.Vector2Rotate(point, angle) + shift
}

// Wrap points around the screen
wrap_point :: proc(point: ^rl.Vector2) {
	if point.x < 0 {
		point.x += WINDOW_WIDTH
	} else if point.x > WINDOW_WIDTH {
		point.x -= WINDOW_WIDTH
	}

	if point.y < 0 {
		point.y += WINDOW_HEIGHT
	} else if point.y > WINDOW_HEIGHT {
		point.y -= WINDOW_HEIGHT
	}
}
