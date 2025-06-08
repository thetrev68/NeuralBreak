// lib/game/util/game_constants.dart
import 'package:flame/components.dart';

// This file defines constants used throughout the game.

// Player and game dimensions
const double playerSize = 40.0;
const double playerMoveSpeed = 300.0;
const double playerJumpForce = 500.0;
const double gravity = 980.0;
const double jumpTapZoneWidth = 100.0; // Define a tap zone around the player for jumping


// Lane definitions
enum GameLane { left, center, right }

// Function to calculate the center X position for a given lane
double getLaneX(GameLane lane, double gameWidth) {
  final laneWidth = gameWidth / 3;

  switch (lane) {
    case GameLane.left:
      return laneWidth / 2;
    case GameLane.center:
      return laneWidth + laneWidth / 2;
    case GameLane.right:
      return (laneWidth * 2) + laneWidth / 2;
  }
}