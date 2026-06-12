package pong


update_score :: proc(sc: ^Score, b: Ball, res: Resolution) {
	if b.pos.x < 0 {sc.npc += 1}
	if b.pos.x > f32(res.width) {sc.player += 1}
}


is_game_over :: proc(sc: Score) -> bool {
	if sc.player >= sc.limit || sc.npc >= sc.limit {
		return true
	}
	return false
}

reset_round :: proc(b: ^Ball, player: ^Paddle, npc: ^Paddle, res: Resolution) {
	b.pos = {f32(res.width) / 2, f32(res.height) / 2}
	b.speed = 800
	b.vel = {-b.speed, 0}
	player.pos = {10, (f32(res.height) - player.size.y) / 2}
	npc.pos = Vec2{npc.pos.x, f32(res.height) / 2}
}

reset_score :: proc(sc: ^Score) {
	sc.player = 0
	sc.npc = 0
}

is_ball_out :: proc(b: Ball, res: Resolution) -> bool {
	if b.pos.x < 0 || b.pos.x >= f32(res.width) {
		return true
	}
	return false
}
