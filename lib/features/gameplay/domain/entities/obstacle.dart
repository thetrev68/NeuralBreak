// Suppresses print warnings (often discouraged in production code)
// Used here for simple debug output
// ignore_for_file: avoid_print

// Flame base and utility classes
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';

// Game-specific dependencies
import 'package:neural_break/features/gameplay/engine/neural_break_game.dart'; // Game reference
import 'package:neural_break/core/constants/game_constants.dart'; // Constants like score per obstacle
import 'package:neural_break/core/constants/game_states.dart'; // Game states
import 'package:neural_break/features/gameplay/engine/game_logic_helpers.dart';

// Represents a falling obstacle in the game.
// Moves downward each frame, triggers scoring when off-screen,
// and uses hitboxes for collision with the player.
class Obstacle extends PositionComponent
    with
        HasGameReference<NeuralBreakGame>, // Gives access to gameRef
        CollisionCallbacks {
  // Enables collision handling

  // Red paint used to draw the obstacle
  final Paint _paint = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.fill;

  // Vertical movement speed in pixels per second
  double speed; // Renamed from obstacleSpeed for clarity and consistency

  // Debug helper: print only a few update logs
  int _updateCount = 0;

  // Constructor for the Obstacle
  // Requires `speed` and optionally takes position, size, and anchor
  Obstacle({
    super.position,
    super.size,
    super.anchor,
    required this.speed, // Updated to 'speed' to match spawner
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

    // Only update obstacle movement if the game is in the playing state
    // This check is crucial for pausing game elements during level-up or game-over
    if (game.gameStateManager.currentGameState != GameState.playing) {
      return;
    }

    // Move the obstacle down based on its speed
    position.y += speed * dt; // Using 'speed' property

    // Print debug output only for the first few updates
    if (_updateCount < 5) {
      print(
        'Obstacle: $hashCode Update ${_updateCount++}, '
        'Y: ${position.y.toStringAsFixed(2)}, '
        'Speed: ${speed.toStringAsFixed(2)}', // Using 'speed' property
      );
    }

    // If the obstacle goes off the bottom of the screen
    // It is considered 'passed' and needs to be removed and possibly score points.
    if (position.y - size.y / 2 > game.size.y) {
      // Increase score if game is still in the playing state when obstacle leaves screen
      // This prevents scoring during game over or paused states.
      increaseScore(this as NeuralBreakGame, scorePerObstacle);

      print(
        'Obstacle: $hashCode Removed off-screen. '
        'Score increased to: ${game.scoreManager.score}',
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

    // When an obstacle is removed, return it to the obstacle pool for reuse.
    // This is important for memory management and performance.
    (game).obstaclePool.returnObstacle(this);
  }
}
