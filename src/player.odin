package asteroids

import rl "vendor:raylib"

// Increment that the player angle rotates by
PLAYER_ROTATION_AMOUNT :: 5 * rl.DEG2RAD
// Increment that the player speed increases by
PLAYER_SPEED :: 25
// Max speed for the player
PLAYER_SPEED_CAP :: PLAYER_SPEED * 45
// Frames before returning to menu after death
PLAYER_DEATH_DELAY :: 150
// Frames before player can shoot again
PLAYER_SHOOT_DELAY :: 15
// maximum number of lives player can have
PLAYER_MAX_LIVES :: 6
// Number of particles spawned on player death
PLAYER_PARTICLE_COUNT :: 30
// Size multiplication of the player spite
PLAYER_SCALE :: 20
// Height of the player sprite
PLAYER_HEIGHT :: 4
// Width of the player sprite
PLAYER_WIDTH :: 2
// Color of the player sprite
PLAYER_COLOR :: rl.WHITE
// State of the player
PLAYER_STATE :: enum {
	Alive,
	Dead,
}

Player :: struct {
	using obj:   Object,
	shoot_timer: uint,
	death_timer: uint,
	lives:       uint,
	state:       PLAYER_STATE,
}

// Forces the maximum speed of the player to be PLAYER_SPEED_CAP
clamp_speed :: proc(player: ^Player) {
	player.vel = rl.Vector2ClampValue(player.vel, 0, PLAYER_SPEED_CAP)
}

// Checks if the player is colliding with an asteroid
check_player_asteroid_collision :: proc(
	player: ^Player,
	asteroids: []Asteroid,
	particles: ^[dynamic]Particle,
) -> (
	hit: bool,
) {
	// Calculates player collision points
	top :=
		rl.Vector2Rotate(rl.Vector2{0, -PLAYER_HEIGHT / 2} * PLAYER_SCALE, player.angle) +
		player.pos
	left :=
		rl.Vector2Rotate(
			rl.Vector2{PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
			player.angle,
		) +
		player.pos
	right :=
		rl.Vector2Rotate(
			rl.Vector2{-PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
			player.angle,
		) +
		player.pos
	center :=
		rl.Vector2Rotate(rl.Vector2{0, PLAYER_HEIGHT / 4} * PLAYER_SCALE, player.angle) +
		player.pos
	left_center := rl.Vector2Rotate(0.5 * (top - left), player.angle) + player.pos
	right_center := rl.Vector2Rotate(0.5 * (top - right), player.angle) + player.pos

	for asteroid in asteroids {
		// Rotates asteroid
		asteroid := asteroid
		for &point in asteroid.base_points {
			point =
				rl.Vector2Rotate(point * ASTEROID_SIZE_VALUE[asteroid.size], asteroid.angle) +
				asteroid.pos
		}

		points := raw_data(asteroid.base_points[:])

		// Checks if player points are inside asteroid
		collision :=
			rl.CheckCollisionPointPoly(top, points, 11) ||
			rl.CheckCollisionPointPoly(left, points, 11) ||
			rl.CheckCollisionPointPoly(right, points, 11) ||
			rl.CheckCollisionPointPoly(center, points, 11) ||
			rl.CheckCollisionPointPoly(left_center, points, 11) ||
			rl.CheckCollisionPointPoly(right_center, points, 11)

		if collision {
			hit = true
			break
		}
	}

	return hit
}

// Creates particles for player destructoin
make_player_particles :: proc(particles: ^[dynamic]Particle, player: Player) {
	for _ in 0 ..< PLAYER_PARTICLE_COUNT {
		append(particles, make_particle(player.pos, PLAYER_SCALE * 2))
	}
}

// Updates the player
update_player :: proc(
	player: ^Player,
	asteroids: []Asteroid,
	bullets: ^[dynamic; BULLET_MAX]Bullet,
	particles: ^[dynamic]Particle,
	dt: f32,
) {
	if player.state == .Alive {
		// Player input
		if rl.IsKeyDown(.UP) do player.vel += rl.Vector2Rotate(rl.Vector2{0, -1} * PLAYER_SPEED, player.angle)
		if rl.IsKeyDown(.LEFT) do player.angle -= PLAYER_ROTATION_AMOUNT
		if rl.IsKeyDown(.RIGHT) do player.angle += PLAYER_ROTATION_AMOUNT
		if rl.IsKeyPressed(.SPACE) && player.shoot_timer == 0 {
			append(bullets, make_bullet(player^))
			player.shoot_timer = PLAYER_SHOOT_DELAY
		}

		clamp_speed(player)
		player.pos += player.vel * dt
		if player.shoot_timer > 0 do player.shoot_timer -= 1

		wrap_position(player)
		wrap_angle(player)

		if check_player_asteroid_collision(player, asteroids, particles) {
			player.state = .Dead
			make_player_particles(particles, player^)

			player.pos = {-100, -100}
			player.vel = {0, 0}
			player.shoot_timer = 1
			player.death_timer = PLAYER_DEATH_DELAY
			if player.lives > 0 do player.lives -= 1
		}
	} else if player.death_timer > 0 {
		player.death_timer -= 1
	}
}

// Draws the player sprite
draw_player :: proc(player: Player) {
	// Player sprite point positions
	top :=
		rl.Vector2Rotate(rl.Vector2{0, -PLAYER_HEIGHT / 2} * PLAYER_SCALE, player.angle) +
		player.pos
	left :=
		rl.Vector2Rotate(
			rl.Vector2{PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
			player.angle,
		) +
		player.pos
	right :=
		rl.Vector2Rotate(
			rl.Vector2{-PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE,
			player.angle,
		) +
		player.pos
	center :=
		rl.Vector2Rotate(rl.Vector2{0, PLAYER_HEIGHT / 4} * PLAYER_SCALE, player.angle) +
		player.pos

	rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)

	draw_player_wrapping(player, top, left, right, center)
}

// Draws the player sprite wrapping around screen edges
draw_player_wrapping :: proc(player: Player, top, left, right, center: rl.Vector2) {
	// Draws player sprite wapping around x-axis
	if player.pos.x < PLAYER_SCALE * 2 {
		top := rl.Vector2{top.x + WINDOW_WIDTH, top.y}
		left := rl.Vector2{left.x + WINDOW_WIDTH, left.y}
		right := rl.Vector2{right.x + WINDOW_WIDTH, right.y}
		center := rl.Vector2{center.x + WINDOW_WIDTH, center.y}

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	} else if player.pos.x > WINDOW_WIDTH - (PLAYER_SCALE * 2) {
		top := rl.Vector2{top.x - WINDOW_WIDTH, top.y}
		left := rl.Vector2{left.x - WINDOW_WIDTH, left.y}
		right := rl.Vector2{right.x - WINDOW_WIDTH, right.y}
		center := rl.Vector2{center.x - WINDOW_WIDTH, center.y}

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	}

	// Draws player sprite wapping around y-axis
	if player.pos.y < PLAYER_SCALE * 2 {
		top := rl.Vector2{top.x, top.y + WINDOW_HEIGHT}
		left := rl.Vector2{left.x, left.y + WINDOW_HEIGHT}
		right := rl.Vector2{right.x, right.y + WINDOW_HEIGHT}
		center := rl.Vector2{center.x, center.y + WINDOW_HEIGHT}

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	} else if player.pos.y > WINDOW_HEIGHT - (PLAYER_SCALE * 2) {
		top := rl.Vector2{top.x, top.y - WINDOW_HEIGHT}
		left := rl.Vector2{left.x, left.y - WINDOW_HEIGHT}
		right := rl.Vector2{right.x, right.y - WINDOW_HEIGHT}
		center := rl.Vector2{center.x, center.y - WINDOW_HEIGHT}

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	}
}

// Draws number of lives that player has remaining
draw_player_lives :: proc(player: Player) {
	// Player sprite point positions
	top := (rl.Vector2{0, -PLAYER_HEIGHT / 2} * PLAYER_SCALE) + {0, 175}
	left := (rl.Vector2{PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE) + {0, 175}
	right := (rl.Vector2{-PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2} * PLAYER_SCALE) + {0, 175}
	center := (rl.Vector2{0, PLAYER_HEIGHT / 4} * PLAYER_SCALE) + {0, 175}

	for _ in 0 ..< player.lives {
		// Shifts sprite over
		top.x += (PLAYER_WIDTH * PLAYER_SCALE) + 15
		left.x += (PLAYER_WIDTH * PLAYER_SCALE) + 15
		right.x += (PLAYER_WIDTH * PLAYER_SCALE) + 15
		center.x += (PLAYER_WIDTH * PLAYER_SCALE) + 15

		rl.DrawLineStrip(raw_data([]rl.Vector2{top, left, center, right, top}), 5, PLAYER_COLOR)
	}
}
