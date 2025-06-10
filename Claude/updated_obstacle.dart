// lib/game/components/obstacle.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';

class Obstacle extends PositionComponent
    with
        HasGameRef<NeuralBreakGame>,
        CollisionCallbacks {

  final Paint _paint = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.fill;

  double obstacleSpeed;
  int _updateCount = 0;
  bool _isPooled = false; // Track if this obstacle is from a pool

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
      
      // Return to pool if this obstacle came from a pool
      _returnToPool();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }

  // Method to reset obstacle properties when reusing from pool
  void resetForReuse({
    required Vector2 newPosition,
    required Vector2 newSize,
    required double newSpeed,
  }) {
    position = newPosition;
    size = newSize;
    obstacleSpeed = newSpeed;
    _updateCount = 0;
    _isPooled = true;
  }

  // Helper method to return obstacle to pool
  void _returnToPool() {
    if (_isPooled && gameRef.children.contains(gameRef.children.whereType<ObstacleSpawner>().first)) {
      // Find the obstacle spawner and return this obstacle to its pool
      final spawner = gameRef.children.whereType<ObstacleSpawner>().first;
      spawner.returnObstacle(this);
    }
  }

  // Mark as pooled when retrieved from pool
  void markAsPooled() {
    _isPooled = true;
  }
}