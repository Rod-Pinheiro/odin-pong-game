package pong

import rl "vendor:raylib"

init_audio :: proc() -> SoundFx {
	rl.InitAudioDevice()
	return SoundFx {
		sounds = {
			.Hit = rl.LoadSound("resources/hit.wav"),
			.BallOut = rl.LoadSound("resources/out.wav"),
			.GameOver = rl.LoadSound("resources/game_over.wav"),
		},
	}
}

close_audio :: proc(sfx: ^SoundFx) {
	for sound in sfx.sounds {
		rl.UnloadSound(sound)
	}
	rl.CloseAudioDevice()
}

process_sound_events :: proc(events: []SoundEvent, sfx: ^SoundFx) {
	for event in events {
		rl.PlaySound(sfx.sounds[event])
	}
}
