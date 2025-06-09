// lib/game/components/obstacle.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';

class Obstacle extends PositionComponent
    with
        HasGameRef<NeuralBreakGame>, // ✅ Correct mixin for accessing gameRef
        CollisionCallbacks {         // ✅ Replaces HasHitboxes

  final Paint _paint = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.fill;

  double obstacleSpeed;
  int _updateCount = 0;

  Obstacle({
    Vector2? position,
    Vector2? size,
    Anchor? anchor,
    required this.obstacleSpeed,
  }) : super(position: position, size: size, anchor: anchor);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    print('Obstacle: onLoad completed. Position: ${position.x.toStringAsFixed(2)}, ${position.y.toStringAsFixed(2)}');
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += obstacleSpeed * dt;

    if (_updateCount < 5) {
      print('Obstacle: ${this.hashCode} Update ${_updateCount++}, Y: ${position.y.toStringAsFixed(2)}, Speed: ${obstacleSpeed.toStringAsFixed(2)}');
    }

    if (position.y - size.y / 2 > gameRef.size.y) {
      if (gameRef.gameState == GameState.playing) {
        gameRef.increaseScore(scorePerObstacle);
      }
      print('Obstacle: ${this.hashCode} Removed off-screen. Score increased to: ${gameRef.score}');
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }
}
