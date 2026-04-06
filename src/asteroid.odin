package asteroids

import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

// Starting deley before first asteroid
ASTEROID_DEFAULT_SPAWN_COUNTER :: 100
// Minimum delay between asteroids
ASTEROID_MIN_DELAY :: 90
// Maximum delay between asteroids
ASTEROID_MAX_DELAY :: 150
// Maximum number of asteroids on screen
MAX_ASTEROIDS :: 15
// Border between corner that asteroids spawn in
ASTEROID_CORNER_SIZE :: 75
// Minimum speed that an asteroid can move at
ASTEROID_MIN_SPEED :: 400
// Maximum speed that an asteroid can move at
ASTEROID_MAX_SPEED :: 600
// Absolute value of range of values that an asteroid can
// rotate at
ASTEROID_ROTATION_SPEED :: 5
// Asteroid sizes
ASTEROID_SIZE :: enum {
	Large,
	Medium,
	Small,
}
// Asteroid scale sizes
ASTEROID_SIZE_VALUE := [ASTEROID_SIZE]f32 {
	.Large  = 60,
	.Medium = 45,
	.Small  = 30,
}
// Maximum distance points will move if they are
// chosen to change
ASTEROID_POINT_EDGE_MOVE_MAX :: 0.45
// Minimum distance points will move if they are
// chosen to change
ASTEROID_POINT_EDGE_MOVE_MIN :: 0.2
// Minimum offset of asteroid choise position
OFFSET_MIN :: 2
// Central offset of asteroid choise position
OFFSET_CENTER :: 4
// Maximum offset of asteroid choise position
OFFSET_MAX :: 8
// Color of asteroid sprite
ASTEROID_COLOR :: rl.WHITE

// Normal decagon
base_decagon := make_base_decagon()

Asteroid :: struct {
	using obj:      Object,
	rotation_speed: f32,
	size:           ASTEROID_SIZE,
	base_points:    [11]rl.Vector2,
}

// Makes points for an asteroid
make_points :: proc() -> [11]rl.Vector2 {
	// Initial positions
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
	change_point_one_move := rand.float32_range(
		ASTEROID_POINT_EDGE_MOVE_MIN,
		ASTEROID_POINT_EDGE_MOVE_MAX,
	)

	offset_two := rand.uint32_range(OFFSET_MIN, OFFSET_CENTER)
	change_point_two := (change_point_one + offset_two) % 10
	change_point_two_move := rand.float32_range(
		ASTEROID_POINT_EDGE_MOVE_MIN,
		ASTEROID_POINT_EDGE_MOVE_MAX,
	)

	offset_three := rand.uint32_range(OFFSET_CENTER, OFFSET_MAX)
	change_point_three := (change_point_one + offset_three) % 10
	change_point_three_move := rand.float32_range(
		ASTEROID_POINT_EDGE_MOVE_MIN,
		ASTEROID_POINT_EDGE_MOVE_MAX,
	)

	if change_point_one == 0 do points[10] = rl.Vector2MoveTowards(points[10], {0, 0}, change_point_one_move)
	points[change_point_one] = rl.Vector2MoveTowards(
		points[change_point_one],
		{0, 0},
		change_point_one_move,
	)

	if change_point_two == 0 do points[10] = rl.Vector2MoveTowards(points[10], {0, 0}, change_point_two_move)
	points[change_point_two] = rl.Vector2MoveTowards(
		points[change_point_two],
		{0, 0},
		change_point_two_move,
	)

	if change_point_three == 0 do points[10] = rl.Vector2MoveTowards(points[10], {0, 0}, change_point_three_move)
	points[change_point_three] = rl.Vector2MoveTowards(
		points[change_point_three],
		{0, 0},
		change_point_three_move,
	)

	return points
}

// Makes an asteroid that spawns from the edge of the screen
make_asteroid_rand :: proc() -> Asteroid {
	SIDES :: enum {
		Top,
		Bottom,
		Left,
		Right,
	}

	pos: rl.Vector2
	angle: f32
	speed := rand.float32_range(ASTEROID_MIN_SPEED, ASTEROID_MAX_SPEED)
	size := rand.choice_enum(ASTEROID_SIZE)

	// Generates position based on which side the asteroid spawns on
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

// Generates an smaller asteroid based on an existing asteroid
make_asteroid_child :: proc(asteroid: Asteroid) -> Asteroid {
	pos := asteroid.pos
	angle := rand.float32_range(0, 2 * rl.PI)
	speed := rand.float32_range(ASTEROID_MIN_SPEED / 2, ASTEROID_MAX_SPEED / 2)
	vel := rl.Vector2Rotate(rl.Vector2{0, -1} * speed, angle)

	size: ASTEROID_SIZE
	if asteroid.size == .Large do size = .Medium
	else if asteroid.size == .Medium do size = .Small
	else if asteroid.size == .Small do size = .Small

	rotation_speed :=
		rand.float32_range(-ASTEROID_ROTATION_SPEED, ASTEROID_ROTATION_SPEED) * rl.DEG2RAD
	points := make_points()

	return {{pos, vel, angle}, rotation_speed, size, points}
}

// Draws asteroid sprites
draw_asteroids :: proc(asteroids: []Asteroid) {
	asteroids_clone := slice.clone(asteroids, context.temp_allocator)

	for &asteroid in asteroids_clone {
		for &point in asteroid.base_points {
			point =
				rl.Vector2Rotate(point * ASTEROID_SIZE_VALUE[asteroid.size], asteroid.angle) +
				asteroid.pos
		}

		rl.DrawLineStrip(raw_data(asteroid.base_points[:]), 11, ASTEROID_COLOR)

		draw_asteroids_wrapping(asteroid)
	}
}

// Draws the asteroid sprite wrapping around screen edges
draw_asteroids_wrapping :: proc(asteroid: Asteroid) {
	// Draws asteroid sprite wapping around x-axis
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

	// Draws asteroid sprite wapping around x-axis
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

// Checks if an asteroid is colliding with a bullet
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

// Updates bullets
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

	shrink(asteroids)
}

// Creates a normal decagon
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
