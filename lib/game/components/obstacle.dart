// Suppresses print warnings (often discouraged in production code)
// Used here for simple debug output
// ignore_for_file: avoid_print

// Flame base and utility classes
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';

// Game-specific dependencies
import 'package:neural_break/game/neural_break_game.dart';     // Game reference
import 'package:neural_break/game/util/game_constants.dart';   // Constants like score per obstacle

// Represents a falling obstacle in the game.
// Moves downward each frame, triggers scoring when off-screen,
// and uses hitboxes for collision with the player.
class Obstacle extends PositionComponent
    with
        HasGameRef<NeuralBreakGame>, // Gives access to gameRef
        CollisionCallbacks {         // Enables collision handling

  // Red paint used to draw the obstacle
  final Paint _paint = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.fill;

  // Vertical movement speed in pixels per second
  double obstacleSpeed;

  // Debug helper: print only a few update logs
  int _updateCount = 0;

  // Constructor for the Obstacle
  // Requires `obstacleSpeed` and optionally takes position, size, and anchor
  Obstacle({
    super.position,
    super.size,
    super.anchor,
    required this.obstacleSpeed,
  });

  // Called when the obstacle is added to the game
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox()); // Adds collision detection box
    print(
      'Obstacle: onLoad completed. Position: '
      '${position.x.toStringAsFixed(2)}, ${position.y.toStringAsFixed(2)}',
    );
  }

  // Called every frame to update position and check bounds
  @override
  void update(double dt) {
    super.update(dt);

    // Move the obstacle down based on its speed
    position.y += obstacleSpeed * dt;

    // Print debug output only for the first 5 updates
    if (_updateCount < 5) {
      print(
        'Obstacle: $hashCode Update ${_updateCount++}, '
        'Y: ${position.y.toStringAsFixed(2)}, '
        'Speed: ${obstacleSpeed.toStringAsFixed(2)}',
      );
    }

    // If the obstacle goes off the bottom of the screen
    if (position.y - size.y / 2 > gameRef.size.y) {
      if (gameRef.gameState == GameState.playing) {
        // Increase score if game is still in play
        gameRef.increaseScore(scorePerObstacle);
      }

      print(
        'Obstacle: $hashCode Removed off-screen. '
        'Score increased to: ${gameRef.score}',
      );

      removeFromParent(); // Remove this obstacle from the game
    }
  }

  // Renders the obstacle visually as a red rectangle
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void onRemove() {
    super.onRemove();

    // Return to pool if we're in the main game context
    if (gameRef is NeuralBreakGame) {
      (gameRef as NeuralBreakGame).obstaclePool.returnObstacle(this);
    }
  }
}
