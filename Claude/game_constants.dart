// lib/game/util/game_constants.dart

import 'package:flutter/material.dart';

// Game mechanics
const double playerSize = 40.0;
const double playerMoveSpeed = 300.0;
const double playerJumpForce = 400.0;
const double gravity = 800.0;

// Player slide dimensions
const double playerSlideWidth = 40.0;
const double playerSlideHeight = 20.0;
const double slideDuration = 0.8; // seconds

// Lanes
enum GameLane { left, center, right }

double getLaneX(GameLane lane, double screenWidth) {
  const double laneWidth = 80.0;
  final double centerX = screenWidth / 2;
  
  switch (lane) {
    case GameLane.left:
      return centerX - laneWidth;
    case GameLane.center:
      return centerX;
    case GameLane.right:
      return centerX + laneWidth;
  }
}

const int numLanes = 3;

// Obstacles
const double initialObstacleSpeed = 200.0;
const double obstacleSpeedIncreasePerLevel = 50.0;

// Spawning
const double initialSpawnInterval = 2.0; // seconds
const double spawnIntervalDecreasePerLevel = 0.2;
const double minSpawnInterval = 0.5;

// Scoring & Lives
const int initialLives = 3;
const int scorePerObstacle = 10;
const double levelDuration = 30.0; // seconds per level

// Input zones
const double jumpTapZoneWidth = 120.0;
const double slideTapZoneHeight = 80.0;

// UI Messages
const String gameOverMessage = 'SYSTEM CRASH\nTap to Reboot';
const String levelUpMessage = 'NEURAL BREAK INTENSIFIED\nTap to Continue';