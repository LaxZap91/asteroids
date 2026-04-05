package asteroids

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

ASTEROID_MIN_SPEED :: 400
ASTEROID_MAX_SPEED :: 600
ASTEROID_COLOR :: rl.WHITE
ASTEROID_ROTATION_SPEED :: 5
MAX_ASTEROIDS :: 15
ASTEROID_SIZE :: enum {
	Large,
	Medium,
	Small,
}
ASTEROID_SIZE_VALUE := [ASTEROID_SIZE]f32 {
	.Large  = 60,
	.Medium = 45,
	.Small  = 30,
}

base_octogon := make_base_octogon()

Asteroid :: struct {
	using obj:      Object,
	rotation_speed: f32,
	size:           ASTEROID_SIZE,
	base_points:    [9]rl.Vector2,
}

make_asteroid_rand :: proc() -> Asteroid {
	pos := rl.Vector2{WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
	angle := rand.float32_range(0, 2 * rl.PI)
	speed := rand.float32_range(ASTEROID_MIN_SPEED, ASTEROID_MAX_SPEED)
	vel := rl.Vector2Rotate(rl.Vector2{0, -1} * speed, angle)
	rotation_speed :=
		rand.float32_range(-ASTEROID_ROTATION_SPEED, ASTEROID_ROTATION_SPEED) * rl.DEG2RAD
	size := rand.choice_enum(ASTEROID_SIZE)
	points := [9]rl.Vector2 {
		base_octogon[0],
		base_octogon[1],
		base_octogon[2],
		base_octogon[3],
		base_octogon[4],
		base_octogon[5],
		base_octogon[6],
		base_octogon[7],
		base_octogon[0],
	}

	return {{pos, vel, angle}, rotation_speed, size, points}
}

make_asteroid_child :: proc(asteroid: Asteroid) -> Asteroid {
	pos := asteroid.pos
	angle := rand.float32_range(0, 2 * rl.PI)
	speed := rand.float32_range(ASTEROID_MIN_SPEED / 2, ASTEROID_MAX_SPEED / 2)
	vel := rl.Vector2Rotate(rl.Vector2{0, -1} * speed, angle)
	rotation_speed :=
		rand.float32_range(-ASTEROID_ROTATION_SPEED, ASTEROID_ROTATION_SPEED) * rl.DEG2RAD
	size: ASTEROID_SIZE
	if asteroid.size == .Large do size = .Medium
	else if asteroid.size == .Medium do size = .Small
	else if asteroid.size == .Small do size = .Small
	points := [9]rl.Vector2 {
		base_octogon[0],
		base_octogon[1],
		base_octogon[2],
		base_octogon[3],
		base_octogon[4],
		base_octogon[5],
		base_octogon[6],
		base_octogon[7],
		base_octogon[0],
	}

	return {{pos, vel, angle}, rotation_speed, size, points}
}

draw_asteroids :: proc(asteroids: []Asteroid) {
	asteroids_clone := slice.clone(asteroids)
	defer delete(asteroids_clone)

	for &asteroid in asteroids_clone {
		for &point in asteroid.base_points {
			point =
				rl.Vector2Rotate(point * ASTEROID_SIZE_VALUE[asteroid.size], asteroid.angle) +
				asteroid.pos
		}

		rl.DrawLineStrip(raw_data(asteroid.base_points[:]), 9, ASTEROID_COLOR)
	}
}

check_asteroid_bullet_collision :: proc(
	asteroid: Asteroid,
	bullets: ^[dynamic]Bullet,
) -> (
	collision: bool,
) {
	for bullet, i in bullets {
		asteroid := asteroid
		for &point in asteroid.base_points {
			point =
				rl.Vector2Rotate(point * ASTEROID_SIZE_VALUE[asteroid.size], asteroid.angle) +
				asteroid.pos
		}

		if rl.CheckCollisionPointPoly(bullet.pos, raw_data(asteroid.base_points[:]), 9) {
			unordered_remove(bullets, i)
			collision = true
			break
		}

	}

	return collision
}

update_asteroids :: proc(
	asteroids: ^[dynamic]Asteroid,
	dt: f32,
	bullets: ^[dynamic]Bullet,
	score: ^uint,
) {
	for &asteroid, index in asteroids {
		asteroid.pos += asteroid.vel * dt
		asteroid.angle += asteroid.rotation_speed
		wrap_angle(&asteroid)
		wrap_position(&asteroid)

		if check_asteroid_bullet_collision(asteroid, bullets) {
			if asteroid.size != .Small {
				append(asteroids, make_asteroid_child(asteroid), make_asteroid_child(asteroid))
			}
			unordered_remove(asteroids, index)
			score^ += uint(ASTEROID_SIZE_VALUE[asteroid.size])
		}
	}
}

make_base_octogon :: proc "contextless" () -> (points: [8]rl.Vector2) {
	cos_angle := math.cos_f32(22 * rl.PI / 180)
	sin_angle := math.sin_f32(22 * rl.PI / 180)

	for i in 1 ..= 8 {
		inner := f32(i) * rl.PI / 4
		point_cos := math.cos_f32(inner)
		point_sin := math.sin_f32(inner)
		point := rl.Vector2 {
			point_cos * cos_angle - point_sin * sin_angle,
			point_cos * sin_angle + point_sin * cos_angle,
		}
		points[i - 1] = point
	}

	return points
}
