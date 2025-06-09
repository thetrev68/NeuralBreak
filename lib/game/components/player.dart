// lib/game/components/player.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart'; // For RectangleHitbox and CollisionCallbacks

import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/components/player_movement.dart';
import 'package:neural_break/game/components/player_jump.dart';
import 'package:neural_break/game/components/player_slide.dart';
import 'package:neural_break/game/components/obstacle.dart';

class Player extends PositionComponent
    with
        HasGameRef<NeuralBreakGame>, // 🔁 Fixed: `HasGameReference` → `HasGameRef` (correct mixin)
        CollisionCallbacks,          // ✅ Use this instead of `HasHitboxes`
        PlayerMovement,
        PlayerJump,
        PlayerSlide {
  static final _playerPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  Player()
      : super(
          size: Vector2(playerSize, playerSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    initializeMovement();
    position.y = gameRef.size.y - size.y * 2;

    initializeJump();
    initializeSlide();

    add(RectangleHitbox());
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
    super.onCollisionStart(intersectionPoints, other); // ✅ Call super
    if (other is Obstacle) {
      gameRef.loseLife();
    }
  }

  void reset() {
    resetMovement();
    resetJump();
    resetSlide();
    position.y = gameRef.size.y - size.y * 2;
  }

  void stopAllActions() {
    stopMovement();
    stopJump();
    stopSlide();
  }

  void applyJump() {
    jump();
  }

  void applySlide() {
    slide();
  }
}