package pong

import "core:fmt"
import rl "vendor:raylib"

init_window :: proc() -> Resolution {
	resolution := Resolution {
		width  = 1280,
		height = 720,
	}
	rl.SetTargetFPS(60)
	rl.InitWindow(1280, 720, "Pong")
	monitor := rl.GetCurrentMonitor()
	resolution = {
		width  = rl.GetMonitorWidth(monitor),
		height = rl.GetMonitorHeight(monitor),
	}
	rl.SetWindowSize(resolution.width, resolution.height)
	rl.ToggleFullscreen()
	return resolution
}

close_window :: proc() {
	rl.CloseWindow()
}

begin_frame :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
}

end_frame :: proc() {
	rl.EndDrawing()
}

draw_paddle :: proc(p: Paddle) {
	rl.DrawRectangleV(p.pos, p.size, rl.WHITE)
}

draw_ball :: proc(b: Ball) {
	rl.DrawCircleV(b.pos, f32(b.radius), rl.WHITE)
}
draw_score :: proc(sc: Score) {
	score_text := fmt.ctprintf(
		"%d : %d",
		clamp(sc.player, 0, sc.limit),
		clamp(sc.npc, 0, sc.limit),
	) // limita os pontos exibidos na tela a score.limit
	rl.DrawText("SCORE", rl.GetScreenWidth() / 2 - 50, 20, 30, rl.WHITE)
	rl.DrawText(score_text, rl.GetScreenWidth() / 2 - 30, 60, 30, rl.WHITE)
}

draw_menu :: proc() {
	rl.DrawText(
		"Press S to Start",
		rl.GetScreenWidth() / 2 - 100,
		rl.GetScreenHeight() / 2 + 40,
		20,
		rl.WHITE,
	)
}

draw_game_over :: proc(res: Resolution) {
	rl.DrawText("Game Over", res.width / 2 - 100, res.height / 2 - 20, 40, rl.RED)
	rl.DrawText("Press R to Restart", res.width / 2 - 100, res.height / 2 + 40, 20, rl.WHITE)
}

draw_fps :: proc() {
	rl.DrawFPS(10, 10)
}
