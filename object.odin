package asteroids

import rl "vendor:raylib"

Object :: struct {
	pos:   rl.Vector2,
	vel:   rl.Vector2,
	angle: f32,
}

wrap_position :: proc(object: ^Object) {
	if object.pos.x < 0 {
		object.pos.x = WINDOW_WIDTH
	} else if object.pos.x > WINDOW_WIDTH {
		object.pos.x = 0
	}

	if object.pos.y < 0 {
		object.pos.y = WINDOW_HEIGHT
	} else if object.pos.y > WINDOW_HEIGHT {
		object.pos.y = 0
	}
}

wrap_angle :: proc(object: ^Object) {
	if object.angle < -rl.PI {
		object.angle += 2 * rl.PI
	} else if object.angle > rl.PI {
		object.angle -= 2 * rl.PI
	}
}
