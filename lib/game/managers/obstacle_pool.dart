// lib/game/managers/obstacle_pool.dart

// Required for managing reusable components efficiently
import 'dart:collection';
import 'package:flame/components.dart';

// Import your obstacle and firewall definitions
import 'package:neural_break/game/components/obstacle.dart';
import 'package:neural_break/game/components/firewall.dart';
import 'package:neural_break/game/util/game_constants.dart';

/// Object pool for obstacles to reduce garbage collection overhead
class ObstaclePool {
  // Queue of inactive obstacles waiting to be reused
  final Queue<Obstacle> _availableObstacles = Queue<Obstacle>();

  // Set of obstacles currently in use
  final Set<Obstacle> _activeObstacles = <Obstacle>{};

  // Initial and maximum size of the pool
  static const int _initialPoolSize = 10;
  static const int _maxPoolSize = 20;

  // Constructor pre-fills the pool
  ObstaclePool() {
    _initializePool();
  }

  // Fill the pool with pre-created obstacles
  void _initializePool() {
    for (int i = 0; i < _initialPoolSize; i++) {
      final obstacle = _createNewObstacle();
      _availableObstacles.add(obstacle);
    }
  }

  // How to create a default obstacle (used in initialization and fallback)
  Obstacle _createNewObstacle() {
    return Firewall(
      position: Vector2.zero(),                     // Will be reset later
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

      // Reset the obstacle for reuse
      obstacle.position = position;
      obstacle.size = size;
      obstacle.obstacleSpeed = speed;
    } else {
      // If pool is empty, create a new one on demand
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

  /// Return an obstacle to the pool after it goes off-screen or is removed
  void returnObstacle(Obstacle obstacle) {
    if (_activeObstacles.remove(obstacle)) {
      if (_availableObstacles.length < _maxPoolSize) {
        _availableObstacles.add(obstacle);
      }
      // Else: do nothing — the object can be collected by the GC
    }
  }

  /// Clear and re-initialize the pool (useful for full game reset)
  void clear() {
    _activeObstacles.clear();
    _availableObstacles.clear();
    _initializePool();
  }

  // Optional: for debugging or dev tooling
  int get activeCount => _activeObstacles.length;
  int get availableCount => _availableObstacles.length;
}
