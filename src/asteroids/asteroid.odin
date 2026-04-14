package asteroids

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

// Minimum delay between asteroids spawning
ASTEROID_MIN_DELAY :: 1.5 * TARGET_FPS
// Maximum delay between asteroids spawning
ASTEROID_MAX_DELAY :: 2.5 * TARGET_FPS
// Maximum number of asteroids on screen before asteroids stop spawning
ASTEROID_SOFT_MAX :: 15
// Increment that ASTEROID_SOFT_MAX increases by for every level of difficulty
ASTEROID_MAX_INCREMENT :: 5
// Maximum number of asteroids able to be spawned
ASTEROID_MAX :: (ASTEROID_SOFT_MAX + (ASTEROID_MAX_INCREMENT * 2)) * 4
// Pixel gap from corners that stop asteroid spawning
ASTEROID_CORNER_SIZE :: 75
// Minimum speed that an asteroid can move at
ASTEROID_MIN_SPEED :: 400
// Maximum speed that an asteroid can move at
ASTEROID_MAX_SPEED :: 600
// Number of particles to spawn on destruction
ASTEROID_PARTICLE_COUNT :: 30
// Absolute value of range of values that an asteroid can
// rotate at
ASTEROID_ROTATION_SPEED :: 5
// Asteroid sizes
ASTEROID_SIZE :: enum {
	Large,
	Medium,
	Small,
}
// Asteroid scale factor based on size
ASTEROID_SIZE_VALUE := [ASTEROID_SIZE]f32 {
	.Large  = 60,
	.Medium = 45,
	.Small  = 30,
}
// Asteroid point values based on size
ASTEROID_POINT_VALUE := [ASTEROID_SIZE]f32 {
	.Large  = 30,
	.Medium = 45,
	.Small  = 60,
}
// Maximum distance points will move if they are
// chosen to change
ASTEROID_POINT_EDGE_MOVE_MAX :: 0.45
// Minimum distance points will move if they are
// chosen to change
ASTEROID_POINT_EDGE_MOVE_MIN :: 0.2
// Minimum offset of asteroid points chosen to shift
ASTEROID_OFFSET_MIN :: 2
// Central offset of asteroid points chosen to shift
ASTEROID_OFFSET_CENTER :: 4
// Maximum offset of asteroid points chosen to shift
ASTEROID_OFFSET_MAX :: 8
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
		angle = rand.float32_range(-165 * rl.DEG2RAD, 165 * rl.DEG2RAD)
	} else if side == .Bottom {
		x := rand.float32_range(ASTEROID_CORNER_SIZE, WINDOW_WIDTH - ASTEROID_CORNER_SIZE)
		y := WINDOW_HEIGHT + ASTEROID_SIZE_VALUE[size]
		pos = {x, y}
		angle = rand.float32_range(-15 * rl.DEG2RAD, 15 * rl.DEG2RAD)
	} else if side == .Left {
		x := -ASTEROID_SIZE_VALUE[size]
		y := rand.float32_range(ASTEROID_CORNER_SIZE, WINDOW_HEIGHT - ASTEROID_CORNER_SIZE)
		pos = {x, y}
		angle = rand.float32_range(15 * rl.DEG2RAD, 165 * rl.DEG2RAD)
	} else if side == .Right {
		x := WINDOW_HEIGHT + ASTEROID_SIZE_VALUE[size]
		y := rand.float32_range(ASTEROID_CORNER_SIZE, WINDOW_HEIGHT - ASTEROID_CORNER_SIZE)
		pos = {x, y}
		angle = rand.float32_range(-165 * rl.DEG2RAD, -15 * rl.DEG2RAD)
	}

	vel := rl.Vector2Rotate(rl.Vector2{0, -1} * speed, angle)
	rotation_speed :=
		rand.float32_range(-ASTEROID_ROTATION_SPEED, ASTEROID_ROTATION_SPEED) * rl.DEG2RAD
	points := make_points()

	return {{pos, vel, angle}, rotation_speed, size, points}
}

// Makes an asteroid that spawns from the edge of the screen
make_asteroid_menu :: proc() -> Asteroid {
	x := rand.float32_range(0, WINDOW_WIDTH)
	y := rand.float32_range(0, WINDOW_HEIGHT)
	pos := rl.Vector2{x, y}
	angle := rand.float32_range(0, 2 * rl.PI)
	speed := rand.float32_range(ASTEROID_MIN_SPEED / 2, ASTEROID_MAX_SPEED / 2)
	vel := rl.Vector2Rotate(rl.Vector2{0, -1} * speed, angle)
	size := rand.choice_enum(ASTEROID_SIZE)
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

	// Reduces the size of the asteroid
	size: ASTEROID_SIZE
	switch asteroid.size {
	case .Large:
		size = .Medium
	case .Medium, .Small:
		size = .Small
	}

	rotation_speed :=
		rand.float32_range(-ASTEROID_ROTATION_SPEED, ASTEROID_ROTATION_SPEED) * rl.DEG2RAD
	points := make_points()

	return {{pos, vel, angle}, rotation_speed, size, points}
}

// Creates particles for asteroid destruction
make_asteroid_particles :: proc(particles: ^[dynamic]Particle, asteroid: Asteroid) {
	for _ in 0 ..< ASTEROID_PARTICLE_COUNT {
		append(particles, make_particle(asteroid.pos, ASTEROID_SIZE_VALUE[asteroid.size]))
	}
}

// Creates a normal decagon
make_base_decagon :: proc "contextless" () -> (points: [10]rl.Vector2) {
	for index in 1 ..= 10 {
		inner := f32(index) * rl.PI / 5
		point_cos := math.cos_f32(inner)
		point_sin := math.sin_f32(inner)
		point := rl.Vector2{point_cos, point_sin}
		points[index - 1] = point
	}

	return points
}

// Makes rendering points for an asteroid
make_points :: proc() -> [11]rl.Vector2 {
	points := base_decagon

	change_point_one := rand.uint32_range(0, 10)
	change_point_one_move := rand.float32_range(
		ASTEROID_POINT_EDGE_MOVE_MIN,
		ASTEROID_POINT_EDGE_MOVE_MAX,
	)

	offset_two := rand.uint32_range(ASTEROID_OFFSET_MIN, ASTEROID_OFFSET_CENTER)
	change_point_two := (change_point_one + offset_two) % 10
	change_point_two_move := rand.float32_range(
		ASTEROID_POINT_EDGE_MOVE_MIN,
		ASTEROID_POINT_EDGE_MOVE_MAX,
	)

	offset_three := rand.uint32_range(ASTEROID_OFFSET_CENTER, ASTEROID_OFFSET_MAX)
	change_point_three := (change_point_one + offset_three) % 10
	change_point_three_move := rand.float32_range(
		ASTEROID_POINT_EDGE_MOVE_MIN,
		ASTEROID_POINT_EDGE_MOVE_MAX,
	)

	points[change_point_one] = rl.Vector2MoveTowards(
		points[change_point_one],
		{0, 0},
		change_point_one_move,
	)

	points[change_point_two] = rl.Vector2MoveTowards(
		points[change_point_two],
		{0, 0},
		change_point_two_move,
	)

	points[change_point_three] = rl.Vector2MoveTowards(
		points[change_point_three],
		{0, 0},
		change_point_three_move,
	)

	points_wrapped: [11]rl.Vector2
	for &point, index in points_wrapped {
		point = points[index % 10]
	}

	return points_wrapped
}
