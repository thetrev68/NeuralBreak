// Dart standard random number generator
import 'dart:math';

// Flame base components
import 'package:flame/components.dart';

// Reference to main game class and necessary game elements
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/components/firewall.dart';        // Assumes Firewall is a subclass of Obstacle
import 'package:neural_break/game/util/game_constants.dart';       // Game tuning constants like spawn intervals
import 'package:neural_break/game/managers/obstacle_pool.dart';

/// Spawns obstacles into the game world at regular intervals.
/// Adjusts speed and timing dynamically to scale game difficulty.
class ObstacleSpawner extends Component with HasGameReference<NeuralBreakGame> {
  // Timer that triggers obstacle creation
  late TimerComponent _spawnTimer;

  // Used to select random lanes for spawning
  final Random _random = Random();

  // Tracks current speed and interval for spawning obstacles
  double _currentObstacleSpeed = initialObstacleSpeed;
  double _currentSpawnInterval = initialSpawnInterval;

  ObstacleSpawner();

  /// Called when the component is added to the game
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeSpawnTimer(); // Set up initial timer
    add(_spawnTimer);        // Register timer as child component
  }

  // Creates the timer logic for periodically spawning obstacles
  void _initializeSpawnTimer() {
    _spawnTimer = TimerComponent(
      period: _currentSpawnInterval, // Time between spawns
      repeat: true,                  // Loop the timer
      onTick: _spawnObstacle,        // Callback each interval
    );
  }

  // Spawns a new obstacle at a random horizontal lane
  void _spawnObstacle() {
    // Only spawn if game is actively running
    if (game.gameState != GameState.playing) return;

    // Choose a random lane and calculate spawn position
    final laneIndex = _random.nextInt(numLanes);
    final lane = GameLane.values[laneIndex];
    final spawnX = getLaneX(lane, game.size.x);
    final spawnY = -playerSize / 2; // Slightly above the visible screen

    // Create and position a new Firewall obstacle
    final obstacle = game.obstaclePool.getObstacle(
      position: Vector2(spawnX, spawnY),
      size: Vector2(playerSize, playerSize),
      speed: _currentObstacleSpeed,
    );

    game.add(obstacle); // Add to the game world
  }

  // Temporarily pauses obstacle spawning
  void stopSpawning() {
    _spawnTimer.timer.stop();
  }

  // Resumes obstacle spawning
  void startSpawning() {
    _spawnTimer.timer.start();
  }

  // Increase difficulty: faster spawn rate, faster obstacles
  void increaseDifficulty(int level) {
    // Speed up obstacle movement
    _currentObstacleSpeed = initialObstacleSpeed +
        (level - 1) * obstacleSpeedIncreasePerLevel;

    // Reduce time between spawns
    _currentSpawnInterval = initialSpawnInterval -
        (level - 1) * spawnIntervalDecreasePerLevel;

    // Clamp to a minimum spawn interval
    if (_currentSpawnInterval < minSpawnInterval) {
      _currentSpawnInterval = minSpawnInterval;
    }

    // Replace the timer with updated settings
    remove(_spawnTimer);
    _initializeSpawnTimer();
    add(_spawnTimer);
  }

  // Resets speed and interval to initial values
  void reset() {
    _currentObstacleSpeed = initialObstacleSpeed;
    _currentSpawnInterval = initialSpawnInterval;

    remove(_spawnTimer);
    _initializeSpawnTimer();
    add(_spawnTimer);
  }
}
