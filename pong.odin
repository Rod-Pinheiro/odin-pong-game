package pong

import rl "vendor:raylib"

Vec2 :: rl.Vector2


main :: proc() {
	resolution := init_window()
	player := Paddle {
		pos   = {10, (f32(resolution.height) - 128) / 2},
		speed = f32(800 * (resolution.height / 720)),
		size  = {32, f32(resolution.height) * 0.2},
	}

	npc := Paddle {
		pos   = {f32(resolution.width) - (32 + 10), (f32(resolution.height) - 128) / 2},
		speed = f32(600 * (resolution.height / 720)),
		size  = {32, f32(resolution.height) * 0.2},
	}

	ball := Ball {
		pos    = {f32(resolution.width) / 2, f32(resolution.height) / 2},
		radius = f32(10 * (resolution.width / 1280)),
		speed  = f32(800 * (resolution.width / 1280)),
	}


	score := Score {
		player = 0,
		npc    = 0,
		limit  = 11,
	}

	state := GameState.Menu

	sfx := init_audio()
	sound_events: [dynamic]SoundEvent
	defer delete(sound_events)

	for !rl.WindowShouldClose() {
		begin_frame()

		switch state {
		case .Menu:
			draw_menu()
			if rl.IsKeyDown(.S) {
				state = .Playing
				ball.vel = {-ball.speed, 0}
			}
		case .Playing:
			handle_player_input(&player)
			npc_move(&npc, ball)
			update_position(&player, &npc, &ball)
			clamp_paddle(&player)
			clamp_paddle(&npc)
			clamp_ball(&ball)
			if check_collision(&player, &ball, 1) {
				append(&sound_events, SoundEvent.Hit)
			}
			if check_collision(&npc, &ball, -1) {
				append(&sound_events, SoundEvent.Hit)
			}
			if is_ball_out(ball, resolution) {
				update_score(&score, ball, resolution)
				finish_game := is_game_over(score)
				append(&sound_events, SoundEvent.BallOut)
				if finish_game == true {
					append(&sound_events, SoundEvent.GameOver)
					state = .GameOver
				}
				if finish_game == false {
					reset_round(&ball, &player, &npc, resolution)
				}
			}
		case .GameOver:
			draw_game_over(resolution)
			if rl.IsKeyDown(.R) {
				reset_round(&ball, &player, &npc, resolution)
				reset_score(&score)
				state = .Playing
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
