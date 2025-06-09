// lib/game/components/player.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart'; // Import for RectangleHitbox

import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/components/player_movement.dart';
import 'package:neural_break/game/components/player_jump.dart';
import 'package:neural_break/game/components/player_slide.dart';
import 'package:neural_break/game/components/obstacle.dart';

class Player extends PositionComponent with HasGameReference<NeuralBreakGame>, PlayerMovement, PlayerJump, PlayerSlide, CollisionCallbacks { // ADDED CollisionCallbacks
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
    position.y = game.size.y - size.y * 2; // Correct: Use 'game'

    // Initialize jump mechanics with the current ground position
    initializeJump();
    // Initialize slide mechanics
    initializeSlide();

    // Add a RectangleHitbox for collision detection
    add(RectangleHitbox());
    print('Player: onLoad completed. Position: ${position.x.toStringAsFixed(2)}, ${position.y.toStringAsFixed(2)}'); // DIAGNOSTIC PRINT
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateMovement(dt);
    updateJump(dt);
    updateSlide(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _playerPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Collision logic for the player.
    if (other is Obstacle) {
      game.loseLife(); // Correct: Use 'game'
      other.removeFromParent(); // Immediately remove the collided obstacle
      print('Player: Collided with obstacle ${other.runtimeType}. Intersection points: $intersectionPoints'); // DIAGNOSTIC PRINT
    }
  }

  // Resets player state for a new game
  void reset() {
    resetMovement();
    resetJump();
    resetSlide();

    position.y = game.size.y - size.y * 2; // Correct: Use 'game'
    print('Player: Reset completed. Position: ${position.x.toStringAsFixed(2)}, ${position.y.toStringAsFixed(2)}'); // DIAGNOSTIC PRINT
  }

  // Method to stop all player actions (movement, jump, slide)
  void stopAllActions() {
    stopMovement();
    stopJump();
    stopSlide();
    print('Player: All actions stopped.'); // DIAGNOSTIC PRINT
  }
}