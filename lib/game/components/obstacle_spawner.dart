// lib/game/components/obstacle_spawner.dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/components/firewall.dart';
import 'package:neural_break/game/util/game_constants.dart'; // To access GameLane enum

// Manages the spawning of obstacles in the game.
// This component will periodically add new obstacles to the game world.
class ObstacleSpawner extends Component with HasGameRef<NeuralBreakGame> {
  // Timer to control when the next obstacle should spawn.
  late TimerComponent _spawnTimer;
  // Random number generator for selecting lanes and obstacle types.
  final Random _random = Random();

  ObstacleSpawner() : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize the spawn timer.
    _spawnTimer = TimerComponent(
      period: 2.0, // Spawn an obstacle every 2 seconds
      autoStart: true,
      repeat: true,
      onTick: _spawnObstacle,
    );
    add(_spawnTimer);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // The timer component handles its own updates, no need to manually call _spawnTimer.update(dt)
  }

  // This method is called by the timer to create and add a new obstacle.
  void _spawnObstacle() {
    // Randomly select a lane for the new obstacle.
    final laneIndex = _random.nextInt(GameLane.values.length);
    final lane = GameLane.values[laneIndex];

    final newObstacle = Firewall(
      lane: lane,
      gameWidth: gameRef.size.x,
    );

    gameRef.add(newObstacle);
    print('Spawned Firewall in lane: $lane');
  }

  // New method to stop obstacle spawning
  void stopSpawning() {
    _spawnTimer.timer.stop();
    print('Obstacle spawning stopped.');
  }

  // New method to reset the spawner for a new game
  void reset() {
    _spawnTimer.timer.start(); // Restart the timer
    print('Obstacle spawner reset and started.');
  }
}