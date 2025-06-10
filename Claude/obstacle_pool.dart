// lib/game/managers/obstacle_pool.dart
import 'dart:collection';
import 'package:flame/components.dart';
import 'package:neural_break/game/components/obstacle.dart';
import 'package:neural_break/game/components/firewall.dart';
import 'package:neural_break/game/util/game_constants.dart';

/// Object pool for obstacles to reduce garbage collection overhead
class ObstaclePool {
  final Queue<Obstacle> _availableObstacles = Queue<Obstacle>();
  final Set<Obstacle> _activeObstacles = <Obstacle>{};
  
  static const int _initialPoolSize = 10;
  static const int _maxPoolSize = 20;

  ObstaclePool() {
    _initializePool();
  }

  void _initializePool() {
    for (int i = 0; i < _initialPoolSize; i++) {
      final obstacle = _createNewObstacle();
      _availableObstacles.add(obstacle);
    }
  }

  Obstacle _createNewObstacle() {
    return Firewall(
      position: Vector2.zero(),
      size: Vector2(playerSize, playerSize),
      anchor: Anchor.center,
      obstacleSpeed: initialObstacleSpeed,
    );
  }

  /// Get an obstacle from the pool or create a new one
  Obstacle getObstacle({
    required Vector2 position,
    required Vector2 size,
    required double speed,
  }) {
    Obstacle obstacle;
    
    if (_availableObstacles.isNotEmpty) {
      obstacle = _availableObstacles.removeFirst();
      // Reset the obstacle properties
      obstacle.position = position;
      obstacle.size = size;
      obstacle.obstacleSpeed = speed;
    } else {
      // Create new obstacle if pool is empty
      obstacle = Firewall(
        position: position,
        size: size,
        anchor: Anchor.center,
        obstacleSpeed: speed,
      );
    }
    
    _activeObstacles.add(obstacle);
    return obstacle;
  }

  /// Return an obstacle to the pool
  void returnObstacle(Obstacle obstacle) {
    if (_activeObstacles.remove(obstacle)) {
      if (_availableObstacles.length < _maxPoolSize) {
        _availableObstacles.add(obstacle);
      }
      // If pool is full, let the obstacle be garbage collected
    }
  }

  /// Clear all obstacles (useful for game reset)
  void clear() {
    _activeObstacles.clear();
    _availableObstacles.clear();
    _initializePool();
  }

  int get activeCount => _activeObstacles.length;
  int get availableCount => _availableObstacles.length;
}