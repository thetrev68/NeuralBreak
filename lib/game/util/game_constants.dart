// ───────────────────────────────────────────────────────────
// 🧩 Game Configuration Constants
// ───────────────────────────────────────────────────────────

const double playerSize = 40.0;                     // Default player size (width & height)
const double initialObstacleSpeed = 150.0;          // Starting speed of falling obstacles
const double initialSpawnInterval = 2.0;            // Time between obstacle spawns (seconds)
const double obstacleSpeedIncreasePerLevel = 25.0;  // Speed boost per level
const double spawnIntervalDecreasePerLevel = 0.2;   // Spawn rate acceleration per level
const double minSpawnInterval = 0.8;                // Minimum interval between spawns
const int initialLives = 3;                         // Lives per game
const int scorePerObstacle = 10;                    // Score for each avoided obstacle
const int numLanes = 3;                             // Total number of horizontal lanes
const double levelDuration = 18.0;                  // Time per level before difficulty increases
const double gameOverDelay = 2.0;                   // Delay before showing game over screen

// ───────────────────────────────────────────────────────────
// 🎮 Player Movement Constants
// ───────────────────────────────────────────────────────────

const double playerMoveSpeed = 300.0;               // Lateral movement speed
const double playerJumpForce = 400.0;               // Initial velocity when jumping
const double gravity = 900.0;                       // Gravitational force applied during jump
const double playerSlideWidth = 60.0;               // Player width during slide
const double playerSlideHeight = 30.0;              // Player height during slide
const double slideDuration = 0.5;                   // Duration of slide (seconds)

// ───────────────────────────────────────────────────────────
// 🖐️ UI and Input Constants
// ───────────────────────────────────────────────────────────

const double jumpTapZoneWidth = 100.0;              // Tap zone width for jump (left side)
const double slideTapZoneHeight = 100.0;            // Tap zone height for slide (below player)
const String gameOverMessage = "GAME OVER!\nTap to Restart";
const String levelUpMessage = "LEVEL UP!\nTap to Continue";

// ───────────────────────────────────────────────────────────
// 🧭 Lane System
// ───────────────────────────────────────────────────────────

/// Enum representing horizontal player lanes
enum GameLane { left, center, right }

/// Calculates the X-coordinate for a given lane's center
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

/// Calculates the Y-coordinate for ground level based on screen and player size
/// Assumes the player anchor is centered, so subtracts half the height.
double getGroundY(double gameHeight, double playerHeight) {
  return gameHeight - playerHeight / 2;
}
