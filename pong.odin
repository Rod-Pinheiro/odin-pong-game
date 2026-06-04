package game

import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"

Vec2 :: rl.Vector2
main :: proc() {
  SCREEN_WIDTH := i32(1280)
  SCREEN_HEIGHT := i32(720)
  rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Pong")
  player_pos := Vec2{ 10, f32(SCREEN_HEIGHT) / 2}
  player_vel: Vec2
  player_size := Vec2{32,128}

  ball_pos := Vec2{f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2}
  ball_vel:= Vec2{-200,0}
  ball_size := 32

  for !rl.WindowShouldClose() {

    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
 
    if rl.IsKeyDown(.UP) {
      player_vel.y = -400
    } else if rl.IsKeyDown(.DOWN){
      player_vel.y = 400
    } else {
      player_vel.y = 0
    }

    player_pos += player_vel * rl.GetFrameTime()
    ball_pos += ball_vel * rl.GetFrameTime()

    if player_pos.y > f32(rl.GetScreenHeight()) - 128 {
    player_pos.y = f32(rl.GetScreenHeight()) - 128
    }
    if player_pos.y < 0 {
    player_pos.y = f32(0)
    }

    player_rect := rl.Rectangle {
      player_pos.x, player_pos.y,
      player_size.x, player_size.y
    }
    
    if ball_pos.y > f32(SCREEN_HEIGHT) {
      ball_vel = linalg.reflect(ball_vel, Vec2{0,-1})
    } 
    if ball_pos.y < 0 {
      ball_vel = linalg.reflect(ball_vel, Vec2{0,-1})
    } 

    if rl.CheckCollisionCircleRec(ball_pos, f32(ball_size) , player_rect) {
      if ball_pos.y > player_pos.y + player_size.y / 2 {
      ball_vel = linalg.reflect(ball_vel, Vec2{-1,-1})
      }

      if ball_pos.y < player_pos.y + player_size.y / 2 {
      ball_vel = linalg.reflect(ball_vel, Vec2{-1,1})
      }
    }

    rl.DrawRectangleV(player_pos, player_size, rl.WHITE)
    rl.DrawCircleV(ball_pos, f32(ball_size), rl.WHITE)
    rl.EndDrawing()
  }

  rl.CloseWindow()
}
