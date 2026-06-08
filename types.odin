package pong


Paddle :: struct {
	pos:   Vec2,
	vel:   Vec2,
	size:  Vec2,
	speed: f32,
}

Ball :: struct {
	pos:    Vec2,
	vel:    Vec2,
	radius: f32,
	speed:  f32,
}

Score :: struct {
	player: int,
	npc:    int,
	limit:  int,
}

Resolution :: struct {
	width:  i32,
	height: i32,
}
