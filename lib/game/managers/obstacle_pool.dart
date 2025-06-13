// lib/game/managers/obstacle_pool.dart

// Required for managing reusable components efficiently
import 'dart:collection';
import 'package:flame/components.dart';

// Import your obstacle and firewall definitions
import 'package:neural_break/game/components/obstacle.dart';
import 'package:neural_break/game/components/firewall.dart'; // Assuming Firewall is the type you primarily pool
import 'package:neural_break/core/constants/game_constants.dart';

/// Object pool for obstacles to reduce garbage collection overhead
class ObstaclePool {
  // Queue of inactive obstacles waiting to be reused
  final Queue<Obstacle> _availableObstacles = Queue<Obstacle>();

  // Set of obstacles currently in use (actively in the game world)
  final Set<Obstacle> _activeObstacles = <Obstacle>{};

  // Initial and maximum size of the pool to control memory usage
  static const int _initialPoolSize = 10;
  static const int _maxPoolSize = 20;

  // Constructor: Initializes the pool with a set number of obstacles.
  ObstaclePool() {
    _initializePool();
  }

  // Fill the pool with pre-created obstacles to avoid runtime instantiation overhead.
  void _initializePool() {
    for (int i = 0; i < _initialPoolSize; i++) {
      final obstacle = _createNewObstacle();
      _availableObstacles.add(obstacle);
    }
  }

  // Creates a new default obstacle instance.
  // This is used for initial pool filling and when the pool needs to expand.
  // Note: position, size, and speed will be set by the spawner later.
  Obstacle _createNewObstacle() {
    // Changed 'obstacleSpeed' to 'speed' to match Obstacle's constructor
    return Firewall(
      position: Vector2.zero(), // Initial position (will be overridden)
      size: Vector2(playerSize, playerSize), // Default size
      anchor: Anchor.center,
      speed: initialObstacleSpeed, // Changed from obstacleSpeed to speed
    );
  }

  /// Get an obstacle from the pool for immediate reuse.
  /// If no obstacles are available and the pool hasn't reached its max size, a new one is created.
  /// Returns null if the pool is empty and at max capacity.
  Obstacle? get() {
    // Changed method name from getObstacle to get, and no longer takes parameters
    Obstacle? obstacle;

    if (_availableObstacles.isNotEmpty) {
      obstacle = _availableObstacles.removeFirst();
      // Properties like position, size, and speed are now set by the ObstacleSpawner
      // after it retrieves the obstacle from the pool.
    } else if (_activeObstacles.length < _maxPoolSize) {
      // If pool is empty but we haven't hit the max pool size, create a new obstacle.
      obstacle = _createNewObstacle();
    } else {
      // If pool is empty and at max size, we cannot provide an obstacle.
      return null;
    }

    // Removed unnecessary null comparison as 'obstacle' is guaranteed to be non-null here,
    // or the method would have already returned null.
    _activeObstacles.add(obstacle); // Mark as active
    return obstacle;
  }

  /// Returns an obstacle to the pool, marking it as inactive.
  /// The obstacle is added back to the available queue if the pool is not full.
  void returnObstacle(Obstacle obstacle) {
    if (_activeObstacles.remove(obstacle)) {
      // Remove from active set
      // Optionally, reset obstacle's internal state here if it has one
      // obstacle.reset(); // Uncomment if your Obstacle class has a reset method

      if (_availableObstacles.length < _maxPoolSize) {
        _availableObstacles.add(obstacle); // Add back to available queue
      }
      // If the pool is full, the obstacle is simply removed from active set
      // and will be garbage collected (if no other references exist).
    }
  }

  /// Clears both active and available obstacles, then re-initializes the pool.
  /// Useful for a complete game reset.
  void clear() {
    _activeObstacles.clear();
    _availableObstacles.clear();
    _initializePool();
  }

  // Optional getters for debugging or monitoring pool status.
  int get activeCount => _activeObstacles.length;
  int get availableCount => _availableObstacles.length;
}
