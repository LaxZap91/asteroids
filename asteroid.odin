package asteroids

import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

ASTEROID_MIN_SPEED :: 400
ASTEROID_MAX_SPEED :: 600
ASTEROID_COLOR :: rl.WHITE
ASTEROID_ROTATION_SPEED :: 5
ASTEROID_MIN_DELAY :: 90
ASTEROID_MAX_DELAY :: 150
MAX_ASTEROIDS :: 15
ASTEROID_CORNER_SIZE :: 75
ASTEROID_POINT_EDGE_MOVE_MAX :: 0.45
ASTEROID_POINT_EDGE_MOVE_MIN :: 0.2
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
SIDES :: enum {
	Top,
	Bottom,
	Left,
	Right,
}

base_decagon := make_base_decagon()

Asteroid :: struct {
	using obj:      Object,
	rotation_speed: f32,
	size:           ASTEROID_SIZE,
	base_points:    [11]rl.Vector2,
}

make_points :: proc() -> [11]rl.Vector2 {
	points := [11]rl.Vector2 {
		base_decagon[0],
		base_decagon[1],
		base_decagon[2],
		base_decagon[3],
		base_decagon[4],
		base_decagon[5],
		base_decagon[6],
		base_decagon[7],
		base_decagon[8],
		base_decagon[9],
		base_decagon[0],
	}
	change_point_one := rand.uint32_range(0, 10)
	change_point_one_move := rand.float32_range(ASTEROID_POINT_EDGE_MOVE_MIN, ASTEROID_POINT_EDGE_MOVE_MAX)
	offset_two := rand.uint32_range(2, 4)
	change_point_two := (change_point_one + offset_two) % 10
	change_point_two_move := rand.float32_range(ASTEROID_POINT_EDGE_MOVE_MIN, ASTEROID_POINT_EDGE_MOVE_MAX)
	offset_three := rand.uint32_range(4, 7)
	change_point_three := (change_point_one + offset_three) % 10
	change_point_three_move := rand.float32_range(ASTEROID_POINT_EDGE_MOVE_MIN, ASTEROID_POINT_EDGE_MOVE_MAX)

	if change_point_one == 0 do points[10] = rl.Vector2MoveTowards(points[10], {0, 0}, change_point_one_move)
	points[change_point_one] = rl.Vector2MoveTowards(points[change_point_one], {0, 0}, change_point_one_move)
	if change_point_two == 0 do points[10] = rl.Vector2MoveTowards(points[10], {0, 0}, change_point_two_move)
	points[change_point_two] = rl.Vector2MoveTowards(points[change_point_two], {0, 0}, change_point_two_move)
	if change_point_three == 0 do points[10] = rl.Vector2MoveTowards(points[10], {0, 0}, change_point_three_move)
	points[change_point_three] = rl.Vector2MoveTowards(points[change_point_three], {0, 0}, change_point_three_move)

	return points
}

make_asteroid_rand :: proc() -> Asteroid {
	pos: rl.Vector2
	angle: f32
	speed := rand.float32_range(ASTEROID_MIN_SPEED, ASTEROID_MAX_SPEED)
	size := rand.choice_enum(ASTEROID_SIZE)

	if side := rand.choice_enum(SIDES); side == .Top {
		x := rand.float32_range(ASTEROID_CORNER_SIZE, WINDOW_WIDTH - ASTEROID_CORNER_SIZE)
		y := -ASTEROID_SIZE_VALUE[size]
		pos = {x, y}
		angle = rand.float32_range(-135 * rl.DEG2RAD, 135 * rl.DEG2RAD)
	} else if side == .Bottom {
		x := rand.float32_range(ASTEROID_CORNER_SIZE, WINDOW_WIDTH - ASTEROID_CORNER_SIZE)
		y := WINDOW_HEIGHT + ASTEROID_SIZE_VALUE[size]
		pos = {x, y}
		angle = rand.float32_range(-45 * rl.DEG2RAD, 45 * rl.DEG2RAD)
	} else if side == .Left {
		x := -ASTEROID_SIZE_VALUE[size]
		y := rand.float32_range(ASTEROID_CORNER_SIZE, WINDOW_HEIGHT - ASTEROID_CORNER_SIZE)
		pos = {x, y}
		angle = rand.float32_range(45 * rl.DEG2RAD, 135 * rl.DEG2RAD)
	} else if side == .Right {
		x := WINDOW_HEIGHT + ASTEROID_SIZE_VALUE[size]
		y := rand.float32_range(ASTEROID_CORNER_SIZE, WINDOW_HEIGHT - ASTEROID_CORNER_SIZE)
		pos = {x, y}
		angle = rand.float32_range(-135 * rl.DEG2RAD, -45 * rl.DEG2RAD)
	}

	vel := rl.Vector2Rotate(rl.Vector2{0, -1} * speed, angle)
	rotation_speed :=
		rand.float32_range(-ASTEROID_ROTATION_SPEED, ASTEROID_ROTATION_SPEED) * rl.DEG2RAD
	points := make_points()

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
	points := make_points()

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

		rl.DrawLineStrip(raw_data(asteroid.base_points[:]),11, ASTEROID_COLOR)

		if asteroid.pos.x < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			points := asteroid.base_points
			for &point in points {
				point = rl.Vector2{point.x + WINDOW_WIDTH, point.y}
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		} else if asteroid.pos.x > WINDOW_WIDTH - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			points := asteroid.base_points
			for &point in points {
				point = rl.Vector2{point.x + WINDOW_WIDTH, point.y}
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		}

		if asteroid.pos.y < ASTEROID_SIZE_VALUE[asteroid.size] * 2 {
			points := asteroid.base_points
			for &point in points {
				point = rl.Vector2{point.x, point.y + WINDOW_HEIGHT}
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		} else if asteroid.pos.y > WINDOW_HEIGHT - (ASTEROID_SIZE_VALUE[asteroid.size] * 2) {
			points := asteroid.base_points
			for &point in points {
				point = rl.Vector2{point.x, point.y - WINDOW_HEIGHT}
			}

			rl.DrawLineStrip(raw_data(points[:]), 11, PLAYER_COLOR)
		}
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

		if rl.CheckCollisionPointPoly(bullet.pos, raw_data(asteroid.base_points[:]), 11) {
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

make_base_decagon :: proc "contextless" () -> (points: [10]rl.Vector2) {
	for i in 1 ..= 10 {
		inner := f32(i) * rl.PI / 5
		point_cos := math.cos_f32(inner)
		point_sin := math.sin_f32(inner)
		point := rl.Vector2{point_cos, point_sin}
		points[i - 1] = point
	}

	return points
}
