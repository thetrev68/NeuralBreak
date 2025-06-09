// lib/game/neural_break_game.dart
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart'; // New import for collision detection
import 'package:flame/components.dart'; // New import for TextComponent

import 'package:neural_break/game/components/player.dart';
import 'package:neural_break/game/components/obstacle.dart'; // New import for Obstacle to remove them
import 'package:neural_break/game/components/obstacle_spawner.dart';
import 'package:neural_break/game/util/game_constants.dart';

// Define game states
enum GameState { playing, gameOver }

class NeuralBreakGame extends FlameGame with TapCallbacks, HasCollisionDetection { // Added HasCollisionDetection
  late final Player player;
  late final ObstacleSpawner obstacleSpawner;
  late TextComponent _gameOverText; // For displaying game over message

  GameState gameState = GameState.playing; // Initial game state

  @override
  Color backgroundColor() => Colors.black;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = Player();
    add(player);

    obstacleSpawner = ObstacleSpawner();
    add(obstacleSpawner);

    // Initialize game over text, but don't add it to the game yet
    _gameOverText = TextComponent(
      text: 'GAME OVER!\nTap to Restart',
      anchor: Anchor.center,
      position: size / 2,
      priority: 10, // Ensure it renders on top
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    print('NeuralBreakGame loaded and Player and ObstacleSpawner added!');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState == GameState.playing) {
      // Only update game components if the game is playing
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
        print('Jump tap detected. Player Y: ${player.position.y.toStringAsFixed(2)}');
      } else if (tapX >= jumpZoneLeft && tapX <= jumpZoneRight && tapY > slideZoneTop && tapY < slideZoneBottom) {
        player.applySlide();
        print('Slide tap detected. Player Y: ${player.position.y.toStringAsFixed(2)}');
      } else if (tapX < playerCenterX) {
        player.moveLeft();
        print('Move Left tap detected. Player X: ${player.position.x.toStringAsFixed(2)}');
      } else if (tapX > playerCenterX) {
        player.moveRight();
        print('Move Right tap detected. Player X: ${player.position.x.toStringAsFixed(2)}');
      }
    }
  }

  // New method to handle game over
  void gameOver() {
    if (gameState == GameState.playing) {
      gameState = GameState.gameOver;
      add(_gameOverText); // Add game over text to the display

      // Stop player actions
      player.stopAllActions();

      // Stop obstacle spawning
      obstacleSpawner.stopSpawning();

      // Remove all existing obstacles from the game
      children.whereType<Obstacle>().forEach((obstacle) => obstacle.removeFromParent());
      print('Game Over!');
    }
  }

  // New method to restart the game
  void _restartGame() {
    gameState = GameState.playing;
    _gameOverText.removeFromParent(); // Remove game over text

    // Reset player and spawner states
    player.reset();
    obstacleSpawner.reset();

    print('Game Restarted!');
  }
}