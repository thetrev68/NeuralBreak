// lib/game/components/player.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/components/player_movement.dart';
import 'package:neural_break/game/components/player_jump.dart'; // IMPORT the new jump mixin

// Add PlayerJump mixin
class Player extends PositionComponent with HasGameRef<NeuralBreakGame>, PlayerMovement, PlayerJump { // ADDED PlayerJump
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
    initializeJump(); // Call the jump mixin's initialization

    print('Player loaded. Initial X: ${position.x.toStringAsFixed(2)}, Target X: ${targetX.toStringAsFixed(2)}, Initial Y: ${position.y.toStringAsFixed(2)}');
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateMovement(dt); // Delegate movement updates to the movement mixin
    updateJump(dt);     // Delegate jump updates to the jump mixin
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _playerPaint);
  }
}