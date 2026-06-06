package game

import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"

Vec2 :: rl.Vector2
main :: proc() {
  SCREEN_WIDTH := i32(1280)
  SCREEN_HEIGHT := i32(720)
  rl.SetTargetFPS(60)
  rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Pong")
  player_vel : Vec2
  player_size := Vec2{32,128}
  player_pos := Vec2{ 10,  (f32(SCREEN_HEIGHT) - player_size.y) / 2}
  player_speed := f32(800)

  npc_size := Vec2{32,128}
  npc_pos := Vec2{f32(SCREEN_WIDTH) - (npc_size.x + 10), f32(SCREEN_HEIGHT) / 2}
  npc_vel : Vec2
  npc_speed := f32(800)

  ball_pos := Vec2{f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2}
  ball_vel:= Vec2{0,0}
  ball_size := 10
  ball_speed := f32(800)

  for !rl.WindowShouldClose() {

    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
 
    if rl.IsKeyDown(.UP) {
      player_vel.y = -player_speed
    } else if rl.IsKeyDown(.DOWN){
      player_vel.y = player_speed
    } else {
      player_vel.y = 0
    }

    // Menu Start
    if ball_vel == 0 {
      rl.DrawText("Press S to Start", SCREEN_WIDTH / 2 -100 , SCREEN_HEIGHT / 2 + 40, 20, rl.WHITE)
      if rl.IsKeyDown(.S){
        ball_vel = {-ball_speed, 0}
      }
    }

    // Position controllers
    player_pos += player_vel * rl.GetFrameTime()
    ball_pos += ball_vel * rl.GetFrameTime()
    npc_pos += npc_vel * rl.GetFrameTime()

    // Arena
    if player_pos.y > f32(rl.GetScreenHeight()) - 128 {
    player_pos.y = f32(rl.GetScreenHeight()) - 128
    }
    if player_pos.y < 0 {
    player_pos.y = f32(0)
    }

    if npc_pos.y > f32(rl.GetScreenHeight()) - 128 {
    npc_pos.y = f32(rl.GetScreenHeight()) - 128
    }
    if npc_pos.y < 0 {
    npc_pos.y = f32(0)
    }

    if ball_pos.y + f32(ball_size) >= f32(SCREEN_HEIGHT) {
      ball_vel = {ball_vel.x, ball_vel.y * -1}
    } 
    if ball_pos.y - f32(ball_size) <= 0 {
      ball_vel = {ball_vel.x, ball_vel.y * -1}
    }
    // hitbox fundo DEBUG
    // if ball_pos.x >= f32(SCREEN_WIDTH) {
    //   ball_vel = {ball_vel.x * -1, ball_vel.y}
    // }


    //NPC logic
    if ball_vel != 0{
      diff := ball_pos.y - (npc_pos.y + npc_size.y / 2)
    if abs(diff) > 5 { // deadzone para não tremer
        npc_vel.y = clamp(diff * 10, -npc_speed, npc_speed) // proporcional + limitado
    } else {
      npc_vel.y = 0
    }
    }
    
    //Hitboxes
    player_rect := rl.Rectangle {
      player_pos.x, player_pos.y,
      player_size.x, player_size.y
    }
    npc_rect := rl.Rectangle {
      npc_pos.x, npc_pos.y,
      npc_size.x, npc_size.y
    }
    
    if rl.CheckCollisionCircleRec(ball_pos, f32(ball_size) , player_rect) {
      rel_y := (ball_pos.y - (player_pos.y + player_size.y / 2)) / (player_size.y / 2)
      rel_y = clamp(rel_y, -1, 1)
      angle := rel_y * (linalg.PI / 4)
      speed := linalg.length(ball_vel)
      ball_speed += 50
      if ball_size <= 5 {
        ball_size -= 1
      }
      ball_vel = Vec2{speed * math.cos(angle), speed * math.sin(angle)}
    }

    if rl.CheckCollisionCircleRec(ball_pos, f32(ball_size) , npc_rect) {
      rel_y := (ball_pos.y - (player_pos.y + player_size.y / 2)) / (player_size.y / 2)
      rel_y = clamp(rel_y, -1, 1)
      angle := rel_y * (linalg.PI / 4)
      speed := linalg.length(ball_vel)
      ball_speed += 50
      if ball_size <= 5 {
        ball_size -= 1
      }
      ball_vel = Vec2{ball_speed * -math.cos(angle), ball_speed * math.sin(angle)}
    }

    if ball_pos.x < 0 || ball_pos.x >= f32(SCREEN_WIDTH) {
      rl.DrawText("Game Over", SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 - 20, 40, rl.RED)
      rl.DrawText("Press R to Restart", SCREEN_WIDTH / 2 -100 , SCREEN_HEIGHT / 2 + 40, 20, rl.WHITE)
      if rl.IsKeyDown(.R) {
        ball_pos = Vec2{f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2}
        ball_speed = 800
        ball_vel = Vec2{-ball_speed,0}
        player_pos = Vec2{ 10,  (f32(SCREEN_HEIGHT) - player_size.y) / 2}
        npc_pos = Vec2{npc_pos.x, f32(SCREEN_HEIGHT) / 2}
      }
    }

    rl.DrawFPS(10, 10);  
    rl.DrawRectangleV(player_pos, player_size, rl.WHITE)
    rl.DrawRectangleV(npc_pos, npc_size, rl.WHITE)
    rl.DrawCircleV(ball_pos, f32(ball_size), rl.WHITE)
    rl.EndDrawing()
  }

  rl.CloseWindow()
}
