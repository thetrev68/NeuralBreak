// file: lib/features/gameplay/domain/usecases/obstacle_spawner.dart

// Dart standard random number generator
import 'dart:math';

// Flame and Flutter packages
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

// Project imports
import 'package:neural_break/core/constants/game_constants.dart';
import 'package:neural_break/core/constants/game_states.dart';
import 'package:neural_break/features/gameplay/data/datasources/obstacle_pool.dart';
import 'package:neural_break/features/gameplay/engine/neural_break_game.dart';

/// Spawns obstacles into the game world at regular intervals.
/// Adjusts speed and timing dynamically to scale game difficulty.
class ObstacleSpawner extends Component with HasGameReference<NeuralBreakGame> {
  // Use 'late' because it will be initialized in the constructor (indirectly via _initializeSpawnTimer)
  late TimerComponent _spawnTimerComponent;
  final ObstaclePool obstaclePool;
  double _currentSpawnInterval;
  double _currentObstacleSpeed;
  final Random _random = Random();

  ObstacleSpawner({required this.obstaclePool})
      : _currentSpawnInterval = initialSpawnInterval,
        _currentObstacleSpeed = initialObstacleSpeed,
        super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Initialize and add the timer component
    _initializeAndAddSpawnTimer(_currentSpawnInterval);
  }

  // Helper method to create and add the timer component
  void _initializeAndAddSpawnTimer(double period) {
    _spawnTimerComponent = TimerComponent(
      period: period,
      repeat: true,
      onTick: _spawnObstacle,
    );
    add(_spawnTimerComponent);
  }

  void _spawnObstacle() {
    // Ensure game is in playing state before spawning
    if (game.gameStateManager.currentGameState != GameState.playing) return;

    final laneIndex = _random.nextInt(numLanes);
    final lane = GameLane.values[laneIndex];
    final spawnX = getLaneX(lane, game.size.x);
    final spawnY =
        -playerSize; // Assuming playerSize is appropriate for spawn Y

    final obstacle = obstaclePool.get(); // Get obstacle from pool
    if (obstacle != null) {
      obstacle.position = Vector2(spawnX, spawnY);
      obstacle.size = Vector2.all(playerSize);
      obstacle.speed =
          _currentObstacleSpeed; // Assuming Obstacle has a 'speed' property
      game.add(obstacle);
    }
  }

  void stopSpawning() {
    _spawnTimerComponent.timer.stop();
  }

  void startSpawning() {
    _spawnTimerComponent.timer.start();
  }

  void increaseDifficulty(int level) {
    // Calculate new intervals and speed
    _currentSpawnInterval =
        (initialSpawnInterval - (level - 1) * spawnIntervalDecreasePerLevel)
            .clamp(minSpawnInterval, initialSpawnInterval);
    _currentObstacleSpeed =
        initialObstacleSpeed + (level - 1) * obstacleSpeedIncreasePerLevel;

    // FIX: Remove old timer and add a new one with the updated period
    _spawnTimerComponent
        .removeFromParent(); // This stops and removes the old timer
    _initializeAndAddSpawnTimer(
        _currentSpawnInterval); // Create and add new timer
    if (kDebugMode) {
      debugPrint(
          'Difficulty increased. New spawn interval: $_currentSpawnInterval, obstacle speed: $_currentObstacleSpeed');
    }
  }

  void reset() {
    _currentObstacleSpeed = initialObstacleSpeed;
    _currentSpawnInterval = initialSpawnInterval;

    // FIX: Remove old timer and add a new one with the reset period
    _spawnTimerComponent.removeFromParent(); // Stop and remove old timer
    _initializeAndAddSpawnTimer(
        _currentSpawnInterval); // Create and add new timer
    if (kDebugMode) {
      debugPrint(
          'Spawner reset. Spawn interval: $_currentSpawnInterval, obstacle speed: $_currentObstacleSpeed');
    }
  }
}
