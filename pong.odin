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
		active = false,
	}


	score := Score {
		player = 0,
		npc    = 0,
		limit  = 11,
	}
	sfx := init_audio()
	sound_events: [dynamic]SoundEvent
	defer delete(sound_events)
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
				ball.active = true
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

		if check_collision(&player, &ball, 1) {
			append(&sound_events, SoundEvent.Hit)
		}
		if check_collision(&npc, &ball, -1) {
			append(&sound_events, SoundEvent.Hit)
		}

		if ball.active && is_ball_out(ball, resolution) {
			update_score(&score, ball, resolution)
			finish_game := is_game_over(score)
			append(&sound_events, SoundEvent.BallOut)
			if finish_game == true & ball.active {
				append(&sound_events, SoundEvent.GameOver)
				ball.active = false
			}
			if finish_game == false {
				reset_round(&ball, &player, &npc, resolution)
			}
		}
		// GameOver
		if !ball.active && ball.vel != 0 {
			draw_game_over(resolution)
			if rl.IsKeyDown(.R) {
				reset_round(&ball, &player, &npc, resolution)
				reset_score(&score)
				ball.active = true
			}
		}
		process_sound_events(sound_events[:], &sfx)
		clear(&sound_events)
		draw_score(score)
		draw_fps()
		draw_paddle(player)
		draw_paddle(npc)
		draw_ball(ball)
		end_frame()
	}
	close_audio(&sfx)
	close_window()
}
