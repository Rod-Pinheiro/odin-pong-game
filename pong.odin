package pong

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

Vec2 :: rl.Vector2


main :: proc() {
	resolution := init_window()
	player := Paddle {
		pos   = {10, (f32(resolution.height) - 128) / 2},
		speed = 800,
		size  = {32, f32(resolution.height) * 0.2},
	}

	npc := Paddle {
		pos   = {f32(resolution.width) - (32 + 10), (f32(resolution.height) - 128) / 2},
		speed = 600,
		size  = {32, f32(resolution.height) * 0.2},
	}

	ball := Ball {
		pos    = {f32(resolution.width) / 2, f32(resolution.height) / 2},
		radius = 10,
		speed  = 800,
	}


	score := Score {
		player = 0,
		npc    = 0,
		limit  = 11,
	}

	for !rl.WindowShouldClose() {
		begin_frame()

		if rl.IsKeyDown(.UP) {
			player.vel.y = -player.speed
		} else if rl.IsKeyDown(.DOWN) {
			player.vel.y = player.speed
		} else {
			player.vel.y = 0
		}

		// Menu Start
		if ball.vel == 0 {
			draw_menu()
			if rl.IsKeyDown(.S) {
				ball.vel = {-ball.speed, 0}
			}
		}

		// Position controllers
		dt := rl.GetFrameTime()
		player.pos += player.vel * dt
		ball.pos += ball.vel * dt
		npc.pos += npc.vel * dt

		// Arena
		clamp_paddle(&player)
		clamp_paddle(&npc)
		clamp_ball(&ball)

		//NPC logic
		if ball.vel != 0 {
			diff := ball.pos.y - (npc.pos.y + npc.size.y / 2)
			if abs(diff) > 5 { 	// deadzone para não tremer
				npc.vel.y = clamp(diff * 10, -npc.speed, npc.speed) // proporcional + limitado
			} else {
				npc.vel.y = 0
			}
		}

		check_collision(&player, &ball, 1)
		check_collision(&npc, &ball, -1)

		if ball.pos.x < 0 || ball.pos.x >= f32(resolution.width) {
			update_score(&score, ball, resolution)
			finish_game := is_game_over(score, resolution)

			if finish_game == true && rl.IsKeyDown(.R) {
				reset_round(&ball, &score, &player, &npc, resolution)
				score.player = 0
				score.npc = 0
			}
			if finish_game == false {
				reset_round(&ball, &score, &player, &npc, resolution)
			}
		}
		draw_score(score)
		draw_fps()
		draw_paddle(player)
		draw_paddle(npc)
		draw_ball(ball)
		end_frame()
	}
	close_window()
}

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

update_score :: proc(sc: ^Score, b: Ball, res: Resolution) {
	if b.pos.x < 0 {sc.npc += 1}
	if b.pos.x > f32(res.width) {sc.player += 1}
}


is_game_over :: proc(sc: Score, res: Resolution) -> Maybe(bool) {
	if sc.player >= sc.limit || sc.npc >= sc.limit {
		draw_game_over(res)
		return true
	}
	return false
}

reset_round :: proc(b: ^Ball, sc: ^Score, player: ^Paddle, npc: ^Paddle, res: Resolution) {
	// sc.player = 0
	// sc.npc = 0
	b.pos = {f32(res.width) / 2, f32(res.height) / 2}
	b.speed = 800
	b.vel = {-b.speed, 0}
	player.pos = {10, (f32(res.height) - player.size.y) / 2}
	npc.pos = Vec2{npc.pos.x, f32(res.height) / 2}
}
