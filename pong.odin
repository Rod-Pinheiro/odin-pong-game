package game

import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"
import "core:fmt"

Vec2 :: rl.Vector2

Paddle :: struct {
  pos : Vec2,
  vel : Vec2, 
  size : Vec2,
  speed : f32
}

Ball :: struct { 
  pos : Vec2, 
  vel : Vec2,
  radius : f32,
  speed : f32
}

Score :: struct {
  player : int, 
  npc : int,
  limit : int
}

Resolution :: struct {
  width : i32,
  height : i32
}

main :: proc() {
  resolution := Resolution {
    width = 1280,
    height = 720
  }
  rl.SetTargetFPS(60)
  rl.InitWindow(1280, 720, "Pong")
  handle_resolution(&resolution)


  player := Paddle { 
    pos = { 10,  (f32(resolution.height) - 128) / 2},
    speed = 800,
    size = {32, f32(resolution.height) * 0.2}
  }

  npc := Paddle { 
    pos = {f32(resolution.width) - (32 + 10), (f32(resolution.height) - 128) / 2},
    speed = 600,
    size = {32, f32(resolution.height) * 0.2}
  }

  ball := Ball { 
    pos = {f32(resolution.width) / 2, f32(resolution.height) / 2},
    radius = 10,
    speed = 800
  }


  score := Score {
    player = 0,
    npc = 0,
    limit = 11
  }

  for !rl.WindowShouldClose() {

    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
 
    if rl.IsKeyDown(.UP) {
      player.vel.y = -player.speed
    } else if rl.IsKeyDown(.DOWN){
      player.vel.y = player.speed
    } else {
      player.vel.y = 0
    }

    // Menu Start
    if ball.vel == 0 {
      rl.DrawText("Press S to Start", resolution.width / 2 -100 , resolution.height / 2 + 40, 20, rl.WHITE)
      if rl.IsKeyDown(.S){
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
    if ball.vel != 0{
      diff := ball.pos.y - (npc.pos.y + npc.size.y / 2)
      if abs(diff) > 5 { // deadzone para não tremer
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
        reset_round(&ball,&score,&player, &npc, resolution)
        score.player = 0
        score.npc = 0
      } 
      if finish_game == false {
        reset_round(&ball,&score,&player, &npc, resolution)
      }
    }

    score_text := fmt.ctprintf("%d : %d", clamp(score.player, 0 ,score.limit), clamp(score.npc, 0 ,score.limit)) // limita os pontos exibidos na tela a score.limit
    rl.DrawText("SCORE", resolution.width / 2 - 50 , 20, 30, rl.WHITE)
    rl.DrawText(score_text, resolution.width / 2 - 30, 60, 30, rl.WHITE)

    rl.DrawFPS(10, 10);  
    rl.DrawRectangleV(player.pos, player.size, rl.WHITE)
    rl.DrawRectangleV(npc.pos, npc.size, rl.WHITE)
    rl.DrawCircleV(ball.pos, f32(ball.radius), rl.WHITE)
    rl.EndDrawing()
  }

  rl.CloseWindow()
}

handle_resolution :: proc(res: ^Resolution) {
  monitor:= rl.GetCurrentMonitor()
  res^ = {
    width = rl.GetMonitorWidth(monitor),
    height = rl.GetMonitorHeight(monitor),
  }
  rl.SetWindowSize(res.width, res.height)
  rl.ToggleFullscreen()
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
    b.vel = {b.vel.x, b.vel.y * -1 }
  }
  if b.pos.y < b.radius {
    b.pos = {b.pos.x, b.radius}
    b.vel = {b.vel.x, b.vel.y * -1}
  }
}

check_collision :: proc(p: ^Paddle, b: ^Ball, dir: f32) {
  rect := rl.Rectangle{p.pos.x, p.pos.y, p.size.x, p.size.y}
  if rl.CheckCollisionCircleRec(b.pos, b.radius, rect){
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

update_score :: proc (sc: ^Score, b: Ball, res: Resolution) { 
  if b.pos.x < 0 { sc.npc += 1}
  if b.pos.x > f32(res.width) { sc.player += 1}
}


is_game_over :: proc (sc: Score, res: Resolution) -> Maybe(bool) {
  if sc.player >= sc.limit || sc.npc >= sc.limit {
    rl.DrawText("Game Over", res.width / 2 - 100, res.height / 2 - 20, 40, rl.RED)
    rl.DrawText("Press R to Restart", res.width / 2 -100 , res.height / 2 + 40, 20, rl.WHITE)
    return true
  }
  return false
}

reset_round :: proc(b: ^Ball, sc: ^Score, player: ^Paddle, npc: ^Paddle, res : Resolution) {
  // sc.player = 0
  // sc.npc = 0
  b.pos = {f32(res.width) / 2, f32(res.height) / 2}
  b.speed = 800
  b.vel = {-b.speed,0}
  player.pos = { 10,  (f32(res.height) - player.size.y) / 2}
  npc.pos = Vec2{npc.pos.x, f32(res.height) / 2}
}
