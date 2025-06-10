// lib/game/components/obstacle_spawner.dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/managers/obstacle_pool.dart'; // Add this import
import 'package:neural_break/game/util/game_constants.dart';

class ObstacleSpawner extends Component with HasGameRef<NeuralBreakGame> {
  late TimerComponent _spawnTimer;
  final Random _random = Random();
  late ObstaclePool _obstaclePool; // Add obstacle pool

  double _currentObstacleSpeed = initialObstacleSpeed;
  double _currentSpawnInterval = initialSpawnInterval;

  ObstacleSpawner();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _obstaclePool = ObstaclePool(); // Initialize the pool
    _initializeSpawnTimer();
    add(_spawnTimer);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // TimerComponent updates itself
  }

  void _initializeSpawnTimer() {
    _spawnTimer = TimerComponent(
      period: _currentSpawnInterval,
      repeat: true,
      onTick: _spawnObstacle,
    );
  }

  void _spawnObstacle() {
    if (gameRef.gameState != GameState.playing) return;

    final laneIndex = _random.nextInt(numLanes);
    final lane = GameLane.values[laneIndex];
    final spawnX = getLaneX(lane, gameRef.size.x);
    final spawnY = -playerSize / 2;

    // Use the object pool instead of creating new obstacles
    final obstacle = _obstaclePool.getObstacle(
      position: Vector2(spawnX, spawnY),
      size: Vector2(playerSize, playerSize),
      speed: _currentObstacleSpeed,
    );

    gameRef.add(obstacle);
  }

  void stopSpawning() {
    _spawnTimer.timer.stop();
  }

  void startSpawning() {
    _spawnTimer.timer.start();
  }

  void increaseDifficulty(int level) {
    _currentObstacleSpeed = initialObstacleSpeed + (level - 1) * obstacleSpeedIncreasePerLevel;
    _currentSpawnInterval = initialSpawnInterval - (level - 1) * spawnIntervalDecreasePerLevel;
    if (_currentSpawnInterval < minSpawnInterval) {
      _currentSpawnInterval = minSpawnInterval;
    }

    // More efficient: just update the timer period instead of recreating
    _spawnTimer.timer.stop();
    remove(_spawnTimer);
    _initializeSpawnTimer();
    add(_spawnTimer);
    _spawnTimer.timer.start();
  }

  void reset() {
    _currentObstacleSpeed = initialObstacleSpeed;
    _currentSpawnInterval = initialSpawnInterval;

    // Clear the pool when resetting
    _obstaclePool.clear();
    
    _spawnTimer.timer.stop();
    remove(_spawnTimer);
    _initializeSpawnTimer();
    add(_spawnTimer);
  }

  // Add method to return obstacle to pool
  void returnObstacle(Obstacle obstacle) {
    _obstaclePool.returnObstacle(obstacle);
  }
}