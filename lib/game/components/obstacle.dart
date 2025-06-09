// lib/game/components/obstacle.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart'; // NEW: Import for RectangleHitbox
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart'; // Ensure game_constants is imported

// The base class for all obstacles in the game.
// All obstacles will move towards the player (downwards).
class Obstacle extends PositionComponent with HasGameReference<NeuralBreakGame>, CollisionCallbacks { // ADDED CollisionCallbacks
  // Define a paint for drawing the obstacle (can be overridden by specific types).
  final Paint _paint = Paint()
    ..color = Colors.redAccent // A distinct color for obstacles
    ..style = PaintingStyle.fill;

  // The speed at which the obstacle moves towards the player.
  // This will now be set by the spawner.
  double obstacleSpeed; // Changed to be set via constructor

  Obstacle({
    Vector2? position,
    Vector2? size,
    Anchor? anchor,
    required this.obstacleSpeed, // REQUIRED: Obstacle speed passed in constructor
  }) : super(position: position, size: size, anchor: anchor);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // ADDED: Add a RectangleHitbox for collision detection
    add(RectangleHitbox());
    print('Obstacle: onLoad completed. Position: ${position.x.toStringAsFixed(2)}, ${position.y.toStringAsFixed(2)}'); // DIAGNOSTIC PRINT
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move the obstacle downwards (positive Y direction) towards the player.
    position.y += obstacleSpeed * dt;

    // Remove the obstacle once it moves off-screen (past the bottom edge).
    // If Anchor is center, position.y is the center, so add half the height
    // to get the bottom edge, then check if it's below game height.
    if (position.y - size.y / 2 > game.size.y) { // Correct: Use 'game'
      // Only increase score if the game is still playing, to prevent score accumulation post-game over
      if (game.gameState == GameState.playing) { // Assumes GameState is accessible via game
        game.increaseScore(scorePerObstacle); // Assumes scorePerObstacle is defined in game_constants.dart
      }
      removeFromParent();
      print('Obstacle: Removed off-screen. Score increased to: ${game.score}'); // DIAGNOSTIC PRINT
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }
}