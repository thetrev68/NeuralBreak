// lib/game/util/game_constants.dart
import 'package:flame/components.dart';

// This file defines constants used throughout the game.

// Player and game dimensions
const double playerSize = 40.0;
const double playerMoveSpeed = 300.0;
const double playerJumpForce = 500.0;
const double gravity = 980.0;
const double jumpTapZoneWidth = 100.0; // Define a tap zone around the player for jumping
const double slideTapZoneHeight = 100.0; // Define a tap zone below the player for sliding

// Slide properties
const double slideDuration = 0.5; // How long the slide animation lasts in seconds
const double playerSlideHeight = 20.0; // Player height when sliding
const double playerSlideWidth = 60.0; // Player width when sliding

// Game mechanics constants (NEW)
const int initialLives = 3;
const int scorePerObstacle = 10;
const int levelUpScoreThreshold = 50; // Score required to advance to the next level
const double initialObstacleSpeed = 200.0; // Starting speed for obstacles
const double obstacleSpeedIncreasePerLevel = 50.0; // How much speed increases per level
const double initialSpawnInterval = 2.0; // Initial time between obstacle spawns
const double spawnIntervalDecreasePerLevel = 0.2; // How much spawn interval decreases per level
const double minSpawnInterval = 0.5; // Minimum possible spawn interval

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