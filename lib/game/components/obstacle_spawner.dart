// lib/game/components/obstacle_spawner.dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/components/firewall.dart';
import 'package:neural_break/game/util/game_constants.dart';

// Manages the spawning of obstacles in the game.
// This component will periodically add new obstacles to the game world.
class ObstacleSpawner extends Component with HasGameReference<NeuralBreakGame> { // Correct: Use HasGameReference
  // Timer to control when the next obstacle should spawn.
  late TimerComponent _spawnTimer;
  // Random number generator for selecting lanes and obstacle types.
  final Random _random = Random();

  // New properties for dynamic difficulty
  double _currentObstacleSpeed = initialObstacleSpeed;
  double _currentSpawnInterval = initialSpawnInterval;

  ObstacleSpawner() : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize the spawn timer.
    _initializeSpawnTimer();
    add(_spawnTimer); // Add the timer component to the spawner.
  }

  @override
  void update(double dt) {
    super.update(dt);
    // TimerComponent handles its own update, so no direct update logic needed here
  }

  // Helper method to initialize the spawn timer with current interval
  void _initializeSpawnTimer() {
    _spawnTimer = TimerComponent(
      period: _currentSpawnInterval,
      autoStart: true,
      repeat: true,
      onTick: _spawnObstacle,
    );
  }

  // This method is called by the timer to create and add a new obstacle.
  void _spawnObstacle() {
    // Check if the game is playing before spawning obstacles
    if (game.gameState != GameState.playing) { // Correct: Use 'game'
      return;
    }

    // Randomly select a lane for the new obstacle.
    final laneIndex = _random.nextInt(GameLane.values.length);
    final lane = GameLane.values[laneIndex];

    // For now, we'll only spawn Firewalls. Later, we can add more obstacle types.
    final newObstacle = Firewall(
      lane: lane,
      gameWidth: game.size.x, // Correct: Use 'game'
      obstacleSpeed: _currentObstacleSpeed,
    );

    // Add the newly created obstacle to the game.
    game.add(newObstacle); // Correct: Use 'game'
  }

  // New method: Call this to stop obstacle spawning (e.g., on game over)
  void stopSpawning() {
    _spawnTimer.timer.stop();
  }

  // New method: Call this to resume obstacle spawning (e.g., after game over or reset)
  void startSpawning() {
    _spawnTimer.timer.start();
  }

  // New method: Adjusts difficulty based on the current level
  void increaseDifficulty(int level) {
    _currentObstacleSpeed = initialObstacleSpeed + (level - 1) * obstacleSpeedIncreasePerLevel;
    _currentSpawnInterval = initialSpawnInterval - (level - 1) * spawnIntervalDecreasePerLevel;
    if (_currentSpawnInterval < minSpawnInterval) {
      _currentSpawnInterval = minSpawnInterval;
    }

    remove(_spawnTimer);
    _initializeSpawnTimer();
    add(_spawnTimer);
  }

  // Resets spawner to initial state (e.g., for a new game)
  void reset() {
    _currentObstacleSpeed = initialObstacleSpeed;
    _currentSpawnInterval = initialSpawnInterval;

    remove(_spawnTimer);
    _initializeSpawnTimer();
    add(_spawnTimer);
  }
}