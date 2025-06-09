// lib/game/neural_break_game.dart
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart'; // Ensure HasCollisionDetection is imported
import 'package:flame/components.dart';

import 'package:neural_break/game/components/player.dart';
import 'package:neural_break/game/components/obstacle.dart';
import 'package:neural_break/game/components/obstacle_spawner.dart';
import 'package:neural_break/game/util/game_constants.dart'; // Ensure all constants are available

// Define game states
enum GameState { playing, gameOver }

class NeuralBreakGame extends FlameGame with TapCallbacks, HasCollisionDetection { // Ensure HasCollisionDetection is present
  late final Player player;
  late final ObstacleSpawner obstacleSpawner;

  // Game state variables
  int score = 0;
  int lives = initialLives;
  int currentLevel = 1;

  // UI Components for displaying game info
  late TextComponent _scoreText;
  late TextComponent _livesText;
  late TextComponent _levelText;
  late TextComponent _gameOverText;

  GameState gameState = GameState.playing;

  @override
  Color backgroundColor() => Colors.black;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = Player();
    add(player);

    obstacleSpawner = ObstacleSpawner();
    add(obstacleSpawner);

    // Initialize UI text components
    _scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(10, 10),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 20, color: Colors.white)),
    );
    add(_scoreText);

    _livesText = TextComponent(
      text: 'Lives: $lives',
      position: Vector2(10, 40),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 20, color: Colors.white)),
    );
    add(_livesText);

    _levelText = TextComponent(
      text: 'Level: $currentLevel',
      position: Vector2(10, 70),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 20, color: Colors.white)),
    );
    add(_levelText);

    _gameOverText = TextComponent(
      text: 'GAME OVER!\nTap to Restart',
      anchor: Anchor.center,
      position: size / 2,
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Initially update UI to reflect starting values
    _updateScoreText();
    _updateLivesText();
    _updateLevelText();
    print('NeuralBreakGame: onLoad completed. Initialized components and UI.'); // DIAGNOSTIC PRINT
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState == GameState.playing) {
      // Components' update methods are automatically called by Flame's engine
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState == GameState.gameOver) {
      _restartGame(); // Tap to restart if game is over
    } else {
      final tapX = event.canvasPosition.x;
      final tapY = event.canvasPosition.y;
      final playerCenterX = player.position.x;
      final playerCenterY = player.position.y;

      final jumpZoneLeft = playerCenterX - (jumpTapZoneWidth / 2);
      final jumpZoneRight = playerCenterX + (jumpTapZoneWidth / 2);

      final slideZoneTop = playerCenterY + player.size.y / 2;
      final slideZoneBottom = slideZoneTop + slideTapZoneHeight;

      if (tapX >= jumpZoneLeft && tapX <= jumpZoneRight && tapY < playerCenterY) {
        player.applyJump();
        print('Game: Jump tap detected.'); // DIAGNOSTIC PRINT
      } else if (tapX >= jumpZoneLeft && tapX <= jumpZoneRight && tapY > slideZoneTop && tapY < slideZoneBottom) {
        player.applySlide();
        print('Game: Slide tap detected.'); // DIAGNOSTIC PRINT
      } else if (tapX < playerCenterX) {
        player.moveLeft();
        print('Game: Move Left tap detected.'); // DIAGNOSTIC PRINT
      } else if (tapX > playerCenterX) {
        player.moveRight();
        print('Game: Move Right tap detected.'); // DIAGNOSTIC PRINT
      }
    }
  }

  void loseLife() {
    if (gameState == GameState.playing) {
      lives--;
      _updateLivesText();
      print('Game: Lost a life! Lives remaining: $lives'); // DIAGNOSTIC PRINT

      if (lives <= 0) {
        gameOver(); // Real game over if no lives left
      } else {
        _resetForNewLife(); // Reset game state for next life
      }
    }
  }

  void gameOver() {
    if (gameState == GameState.playing) { // Ensure it's not already in game over state
      gameState = GameState.gameOver;
      add(_gameOverText); // Add game over text to the display

      player.stopAllActions();
      obstacleSpawner.stopSpawning();
      children.whereType<Obstacle>().forEach((obstacle) => obstacle.removeFromParent());
      print('Game: GAME OVER triggered! Lives: $lives'); // DIAGNOSTIC PRINT
    }
  }

  void _resetForNewLife() {
    gameState = GameState.playing; // Resume playing
    player.reset(); // Reset player position and state

    children.whereType<Obstacle>().forEach((obstacle) => obstacle.removeFromParent());
    obstacleSpawner.reset();
    print('Game: Reset for a new life. Current lives: $lives'); // DIAGNOSTIC PRINT
  }

  void increaseScore(int amount) {
    score += amount;
    _updateScoreText();
    print('Game: Score increased to: $score'); // DIAGNOSTIC PRINT

    if (score >= currentLevel * levelUpScoreThreshold) {
      _levelUp();
    }
  }

  void _levelUp() {
    currentLevel++;
    _updateLevelText();
    obstacleSpawner.increaseDifficulty(currentLevel);
    print('Game: LEVEL UP! Current Level: $currentLevel'); // DIAGNOSTIC PRINT
  }

  // Helper methods to update UI text
  void _updateScoreText() {
    _scoreText.text = 'Score: $score';
  }

  void _updateLivesText() {
    _livesText.text = 'Lives: $lives';
  }

  void _updateLevelText() {
    _levelText.text = 'Level: $currentLevel';
  }

  // Method to restart the entire game from scratch
  void _restartGame() {
    score = 0;
    lives = initialLives;
    currentLevel = 1;

    _updateScoreText();
    _updateLivesText();
    _updateLevelText();

    _gameOverText.removeFromParent();

    player.reset();
    obstacleSpawner.reset();
    children.whereType<Obstacle>().forEach((obstacle) => obstacle.removeFromParent());

    gameState = GameState.playing;
    print('Game: Game fully restarted!'); // DIAGNOSTIC PRINT
  }
}