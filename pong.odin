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
  npc : int
}

main :: proc() {
  SCREEN_WIDTH := i32(1280)
  SCREEN_HEIGHT := i32(720)
  rl.SetTargetFPS(60)
  rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Pong")

  player := Paddle { 
    pos = { 10,  (f32(SCREEN_HEIGHT) - 128) / 2},
    speed = 800,
    size = {32,128}
  }

  npc := Paddle { 
    pos = {f32(SCREEN_WIDTH) - (32 + 10), f32(SCREEN_HEIGHT) / 2},
    speed = 600,
    size = {32,128}
  }

  ball := Ball { 
    pos = {f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2},
    radius = 10,
    speed = 800
  }


  score := Score {
    player = 0,
    npc = 0
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
      rl.DrawText("Press S to Start", SCREEN_WIDTH / 2 -100 , SCREEN_HEIGHT / 2 + 40, 20, rl.WHITE)
      if rl.IsKeyDown(.S){
        ball.vel = {-ball.speed, 0}
      }
    }

    // Position controllers
    player.pos += player.vel * rl.GetFrameTime()
    ball.pos += ball.vel * rl.GetFrameTime()
    npc.pos += npc.vel * rl.GetFrameTime()

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

    if ball.pos.x < 0 || ball.pos.x >= f32(SCREEN_WIDTH) {
      finish_game := false

      if ball.pos.x > 0 {
        score.player += 1
      } else {
        score.npc += 1
      }
      
      if score.player >= 11 || score.npc >= 11 {
        finish_game = true
        rl.DrawText("Game Over", SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 - 20, 40, rl.RED)
        rl.DrawText("Press R to Restart", SCREEN_WIDTH / 2 -100 , SCREEN_HEIGHT / 2 + 40, 20, rl.WHITE)
      }
      
      if finish_game == true && rl.IsKeyDown(.R) {
        score.player = 0
        score.npc = 0
        ball.pos = {f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2}
        ball.speed = 800
        ball.vel = {-ball.speed,0}
        player.pos = { 10,  (f32(SCREEN_HEIGHT) - player.size.y) / 2}
        npc.pos = Vec2{npc.pos.x, f32(SCREEN_HEIGHT) / 2}
      } 
      if finish_game == false {
        ball.pos = {f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2}
        ball.speed = 800
        ball.vel = {-ball.speed,0}
        player.pos = { 10,  (f32(SCREEN_HEIGHT) - player.size.y) / 2}
        npc.pos = {npc.pos.x, f32(SCREEN_HEIGHT) / 2}
      }
    }

    score_text := fmt.ctprintf("%d : %d", clamp(score.player, 0 ,11), clamp(score.npc, 0 ,11)) // limita os pontos exibidos na tela a 11
    rl.DrawText("SCORE", SCREEN_WIDTH / 2 - 50 , 20, 30, rl.WHITE)
    rl.DrawText(score_text, SCREEN_WIDTH / 2 - 30, 60, 30, rl.WHITE)

    rl.DrawFPS(10, 10);  
    rl.DrawRectangleV(player.pos, player.size, rl.WHITE)
    rl.DrawRectangleV(npc.pos, npc.size, rl.WHITE)
    rl.DrawCircleV(ball.pos, f32(ball.radius), rl.WHITE)
    rl.EndDrawing()
  }

  rl.CloseWindow()
}

clamp_paddle :: proc(p: ^Paddle) {
  max_y := f32(rl.GetScreenHeight()) - p.size.y
  if p.pos.y > max_y {p.pos.y = max_y}
  if p.pos.y < 0 {p.pos.y = 0}
}

clamp_ball :: proc(b: ^Ball) {
  max_y := f32(rl.GetScreenHeight()) - b.radius
  if b.pos.y > max_y {b.vel = {b.vel.x, b.vel.y * -1 }}
  if b.pos.y < 0 {b.vel = {b.vel.x, b.vel.y * -1}}
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
