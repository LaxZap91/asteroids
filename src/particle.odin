package asteroids

import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

// Minimum frames that particles last for
PARTICLE_MIN_TIME :: 60
// Maximum frames that particles last for
PARTICLE_MAX_TIME :: 120
// Minimum offset that particles spawn around radius
PARTICLE_OFFSET_MIN :: -10
// Maximum offset that particles spawn around radius
PARTICLE_OFFSET_MAX :: 10
// Minimum particle speed
PARTICLE_SPEED_MIN :: 20
// Maximum particle speed
PARTICLE_SPEED_MAX :: 60
// Size of particle sprite
PARTICLE_SIZE :: 5
// Color of particle sprite
PARTICLE_COLOR :: rl.WHITE

Particle :: struct {
	using obj: Object,
	timer:     uint,
}

// Creates a destruction particle near and object
make_particle :: proc(obj_pos: rl.Vector2, radius: f32) -> Particle {
	angle := rand.float32_range(0, 2 * rl.PI)
	radius_offset := rand.float32_range(PARTICLE_OFFSET_MIN, PARTICLE_OFFSET_MAX)
	speed := rand.float32_range(PARTICLE_SPEED_MIN, PARTICLE_SPEED_MAX)
	pos := rl.Vector2Rotate(rl.Vector2{0, -1} * (radius + radius_offset), angle) + obj_pos
	vel := rl.Vector2Rotate(rl.Vector2{0, -1} * speed, angle)
	time := rand.uint_range(PARTICLE_MIN_TIME, PARTICLE_MAX_TIME)

	return {{pos, vel, 0}, time}
}

// Draws particles
draw_particles :: proc(particles: []Particle) {
	for particle in particles {
		rl.DrawRectangle(
			i32(particle.pos.x) - PARTICLE_SIZE,
			i32(particle.pos.y) - PARTICLE_SIZE,
			PARTICLE_SIZE,
			PARTICLE_SIZE,
			PARTICLE_COLOR,
		)
	}
}

// Updates particles
update_particles :: proc(particles: ^[dynamic]Particle, dt: f32) {
	remove_indices := make([dynamic]uint, context.temp_allocator)

	for &particle, index in particles {
		particle.pos += particle.vel * dt
		particle.timer -= 1

		if particle.timer == 0 {
			append(&remove_indices, uint(index))
		}
	}

	slice.reverse(remove_indices[:])
	for index in remove_indices {
		unordered_remove(particles, index)
	}

	shrink(particles)
}
