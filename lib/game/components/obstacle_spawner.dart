// lib/game/components/obstacle_spawner.dart
// Dart standard random number generator
import 'dart:math';

// Flame base components
import 'package:flame/components.dart';

// Reference to main game class and necessary game elements
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/managers/obstacle_pool.dart';
import 'package:neural_break/game/components/obstacle.dart';

/// Spawns obstacles into the game world at regular intervals.
/// Adjusts speed and timing dynamically to scale game difficulty.
class ObstacleSpawner extends Component with HasGameReference<NeuralBreakGame> {
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
    _initializeSpawnTimer();
    add(_spawnTimerComponent);
  }

  void _initializeSpawnTimer() {
    _spawnTimerComponent = TimerComponent(
      period: _currentSpawnInterval,
      repeat: true,
      onTick: _spawnObstacle,
    );
  }

  void _spawnObstacle() {
    if (game.gameStateManager.currentGameState != GameState.playing) return;

    final laneIndex = _random.nextInt(numLanes);
    final lane = GameLane.values[laneIndex];
    final spawnX = getLaneX(lane, game.size.x);
    final spawnY = -playerSize;

    final obstacle = obstaclePool.get(); // This line might still be an issue if get() is not the method
    if (obstacle != null) {
      obstacle.position = Vector2(spawnX, spawnY);
      obstacle.size = Vector2.all(playerSize);
      obstacle.speed = _currentObstacleSpeed; // Assuming Obstacle has a 'speed' property
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
    _currentSpawnInterval = (initialSpawnInterval - (level - 1) * spawnIntervalDecreasePerLevel)
        .clamp(minSpawnInterval, initialSpawnInterval);
    _currentObstacleSpeed = initialObstacleSpeed + (level - 1) * obstacleSpeedIncreasePerLevel;

    // FIX: Access 'period' directly on the TimerComponent, not its internal timer.
    _spawnTimerComponent.period = _currentSpawnInterval;
  }

  void reset() {
    _currentObstacleSpeed = initialObstacleSpeed;
    _currentSpawnInterval = initialSpawnInterval;

    // FIX: Access 'period' directly on the TimerComponent, not its internal timer.
    _spawnTimerComponent.period = _currentSpawnInterval;
    _spawnTimerComponent.timer.start();
  }
}