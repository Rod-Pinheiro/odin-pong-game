package pong

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
		npc_move(&npc, ball)
		// if ball.vel != 0 {
		// 	// diff := ball.pos.y - (npc.pos.y + npc.size.y / 2)
		// 	// if abs(diff) > 5 { 	// deadzone para não tremer
		// 	// 	npc.vel.y = clamp(diff * 10, -npc.speed, npc.speed) // proporcional + limitado
		// 	// } else {
		// 	// 	npc.vel.y = 0
		// 	// }
		// }

		check_collision(&player, &ball, 1)
		check_collision(&npc, &ball, -1)

		if ball.pos.x < 0 || ball.pos.x >= f32(resolution.width) {
			update_score(&score, ball, resolution)
			finish_game := is_game_over(score)

			if finish_game == true && rl.IsKeyDown(.R) {
				draw_game_over(resolution)
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
