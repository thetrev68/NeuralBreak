// lib/game/util/game_constants.dart

import 'package:flame/components.dart'; // For Vector2

// Game configuration constants
const double playerSize = 40.0; // Player size
const double initialObstacleSpeed = 150.0; // Initial speed of obstacles
const double initialSpawnInterval = 2.0; // Initial interval between obstacle spawns (seconds)
const double obstacleSpeedIncreasePerLevel = 25.0; // How much obstacle speed increases each level
const double spawnIntervalDecreasePerLevel = 0.2; // How much spawn interval decreases each level
const double minSpawnInterval = 0.8; // Minimum possible spawn interval
const int initialLives = 3; // Starting number of player lives
const int scorePerObstacle = 10; // Score gained per obstacle dodged
const int numLanes = 3; // Number of horizontal lanes in the game
const double levelDuration = 18.0; // Approximate time (in seconds) for each level before difficulty increases
const double gameOverDelay = 2.0; // Delay before game over screen appears

// Player movement constants
const double playerMoveSpeed = 300.0; // Speed at which player moves horizontally between lanes
const double playerJumpForce = 400.0; // Initial upward velocity for jump
const double gravity = 900.0; // Gravity affecting player's jump
const double playerSlideWidth = 60.0; // Player width when sliding
const double playerSlideHeight = 30.0; // Player height when sliding
const double slideDuration = 0.5; // Duration of the slide action (seconds)

// UI and Interaction Constants
const double jumpTapZoneWidth = 100.0; // Width of the tap zone for jumping
const double slideTapZoneHeight = 100.0; // Height of the tap zone for sliding (below player)
const String gameOverMessage = "GAME OVER!\nTap to Restart";
const String levelUpMessage = "LEVEL UP!\nTap to Continue";

// Enum for game lanes
enum GameLane { left, center, right }

// Helper function to get the X coordinate for the center of a given lane
double getLaneX(GameLane lane, double gameWidth) {
  final double laneWidth = gameWidth / numLanes;
  switch (lane) {
    case GameLane.left:
      return laneWidth / 2;
    case GameLane.center:
      return gameWidth / 2;
    case GameLane.right:
      return gameWidth - laneWidth / 2;
  }
}

// Helper function to get the Y coordinate for the ground level
// This assumes the player's anchor is Anchor.center
double getGroundY(double gameHeight, double playerHeight) {
  // The player's anchor is center. To place its base at the ground,
  // we need to offset by half its height from the ground.
  return gameHeight - playerHeight / 2;
}