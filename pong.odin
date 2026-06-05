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
  player_speed := f32(800)

  ball_pos := Vec2{f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2}
  ball_vel:= Vec2{0,0}
  ball_size := 10

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

    if ball_vel == 0 {
      rl.DrawText("Press S to Start", SCREEN_WIDTH / 2 -100 , SCREEN_HEIGHT / 2 + 40, 20, rl.WHITE)
      if rl.IsKeyDown(.S){
        ball_vel = {-800, 0}
      }
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
    if ball_pos.y <= 0 {
      ball_vel = linalg.reflect(ball_vel, Vec2{0,-1})
    }
    if ball_pos.x >= f32(SCREEN_WIDTH) {
      ball_vel = linalg.reflect(ball_vel, Vec2{-1,0})
    }

    if rl.CheckCollisionCircleRec(ball_pos, f32(ball_size) , player_rect) {
      rel_y := (ball_pos.y - (player_pos.y + player_size.y / 2)) / (player_size.y / 2)
      rel_y = clamp(rel_y, -1, 1)
      angle := rel_y * (linalg.PI / 4)
      speed := linalg.length(ball_vel)
      ball_vel = Vec2{speed * linalg.cos(angle), speed * math.sin(angle)}
    }

    if ball_pos.x < 0 {
      rl.DrawText("Game Over", SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 - 20, 40, rl.RED)
      rl.DrawText("Press R to Restart", SCREEN_WIDTH / 2 -100 , SCREEN_HEIGHT / 2 + 40, 20, rl.WHITE)
      if rl.IsKeyDown(.R) {
        ball_pos = Vec2{f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2}
        ball_vel = Vec2{-800,0}
        player_pos = Vec2{10, f32(SCREEN_HEIGHT) / 2}
      }
    }

    rl.DrawFPS(10, 10);  
    rl.DrawRectangleV(player_pos, player_size, rl.WHITE)
    rl.DrawCircleV(ball_pos, f32(ball_size), rl.WHITE)
    rl.EndDrawing()
  }

  rl.CloseWindow()
}
