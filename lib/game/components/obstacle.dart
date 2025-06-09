// lib/game/components/obstacle.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';

// The base class for all obstacles in the game.
// All obstacles will move towards the player (downwards).
class Obstacle extends PositionComponent with HasGameRef<NeuralBreakGame> {
  // Define a paint for drawing the obstacle (can be overridden by specific types).
  final Paint _paint = Paint()
    ..color = Colors.redAccent // A distinct color for obstacles
    ..style = PaintingStyle.fill;

  // The speed at which the obstacle moves towards the player.
  // This will initially be a constant, but will increase over time.
  double obstacleSpeed = 200.0; // Initial obstacle speed

  Obstacle({
    Vector2? position,
    Vector2? size,
    Anchor? anchor,
  }) : super(position: position, size: size, anchor: anchor);

  @override
  void update(double dt) {
    super.update(dt);
    // Only update if game is playing
    if (gameRef.gameState == GameState.playing) {
      // Move the obstacle downwards (positive Y direction) towards the player.
      position.y += obstacleSpeed * dt;

      // Remove the obstacle once it moves off-screen (past the bottom edge).
      // If Anchor is center, position.y is the center, so add half the height
      // to get the bottom edge, then check if it's below game height.
      if (position.y - size.y / 2 > gameRef.size.y) {
        removeFromParent();
        print('Obstacle removed: $this');
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }
}