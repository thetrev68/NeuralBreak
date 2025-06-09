// lib/game/components/player.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart'; // New import for CollisionCallbacks

import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/components/player_movement.dart';
import 'package:neural_break/game/components/player_jump.dart';
import 'package:neural_break/game/components/player_slide.dart';
import 'package:neural_break/game/components/obstacle.dart'; // New import to detect collision with obstacles

// Add CollisionCallbacks mixin
class Player extends PositionComponent with HasGameRef<NeuralBreakGame>, PlayerMovement, PlayerJump, PlayerSlide, CollisionCallbacks { // Added CollisionCallbacks
  static final _playerPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  Player() : super(
    size: Vector2(playerSize, playerSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize horizontal movement
    initializeMovement();
    // Set initial Y position. X is handled by initializeMovement
    position.y = gameRef.size.y - size.y * 2;

    // Initialize jump mechanics with the current ground position
    initializeJump();
    // Initialize slide mechanics
    initializeSlide();

    add(RectangleHitbox()); // Add a hitbox for collision detection

    print('Player loaded. Initial X: ${position.x.toStringAsFixed(2)}, Target X: ${targetX.toStringAsFixed(2)}, Initial Y: ${position.y.toStringAsFixed(2)}');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.gameState == GameState.playing) { // Only update if game is playing
      updateMovement(dt);
      updateJump(dt);
      updateSlide(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _playerPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstacle) {
      gameRef.gameOver(); // Trigger game over when player collides with an obstacle
      print('Player collided with Obstacle!');
    }
  }

  // New method to reset player state for a new game
  void reset() {
    // Reset position to initial state
    position.setValues(getLaneX(GameLane.center, gameRef.size.x), gameRef.size.y - size.y * 2);

    // Re-initialize mixins to reset their internal states
    initializeMovement();
    initializeJump();
    initializeSlide();

    // Stop any ongoing actions
    stopAllActions();
    print('Player reset to initial state.');
  }

  // New method to stop all player actions
  void stopAllActions() {
    stopMovement();
    stopJump();
    stopSlide();
    print('All player actions stopped.');
  }
}