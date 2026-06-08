package pong

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

clamp_paddle :: proc(p: ^Paddle) {
	max_y := f32(rl.GetScreenHeight()) - p.size.y
	if p.pos.y > max_y {p.pos.y = max_y}
	if p.pos.y < 0 {p.pos.y = 0}
}

clamp_ball :: proc(b: ^Ball) {
	max_y := f32(rl.GetScreenHeight()) - b.radius
	if b.pos.y > max_y {
		b.pos = {b.pos.x, max_y}
		b.vel = {b.vel.x, b.vel.y * -1}
	}
	if b.pos.y < b.radius {
		b.pos = {b.pos.x, b.radius}
		b.vel = {b.vel.x, b.vel.y * -1}
	}
}

check_collision :: proc(p: ^Paddle, b: ^Ball, dir: f32) {
	rect := rl.Rectangle{p.pos.x, p.pos.y, p.size.x, p.size.y}
	if rl.CheckCollisionCircleRec(b.pos, b.radius, rect) {
		rel_y := (b.pos.y - (p.pos.y + p.size.y / 2)) / (p.size.y / 2)
		rel_y = clamp(rel_y, -1, 1)
		angle := rel_y * (linalg.PI / 4)
		speed := linalg.length(b.vel * 1.05) // aumenta velocidade da bola em 5% a cada hit
		if b.radius <= 5 {
			b.radius -= 1
		}
		b.vel = {dir * speed * math.cos(angle), speed * math.sin(angle)}
	}
}

npc_move :: proc(p: ^Paddle, b: Ball) {
	diff := b.pos.y - (p.pos.y + p.size.y / 2)
	if abs(diff) > 5 { 	// deadzone para não tremer
		p.vel.y = clamp(diff * 10, -p.speed, p.speed) // proporcional + limitado
	} else {
		p.vel.y = 0
	}
}
