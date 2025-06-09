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
    // It will fire every 2 seconds, and then repeat.
    _spawnTimer = TimerComponent(
      period: 2.0, // Spawn an obstacle every 2 seconds
      autoStart: true,
      repeat: true,
      onTick: _spawnObstacle, // Call _spawnObstacle when the timer ticks
    );
    add(_spawnTimer); // Add the timer component to the spawner.
  }

  // This method is called by the timer to create and add a new obstacle.
  void _spawnObstacle() {
    // Randomly select a lane for the new obstacle.
    final laneIndex = _random.nextInt(GameLane.values.length);
    final lane = GameLane.values[laneIndex];

    // For now, we'll only spawn Firewalls. Later, we can add more obstacle types.
    final newObstacle = Firewall(
      lane: lane,
      gameWidth: gameRef.size.x,
      // Removed gameHeight as it's no longer needed by Firewall constructor
    );

    // Add the newly created obstacle to the game.
    gameRef.add(newObstacle);
    print('Spawned Firewall in lane: $lane');
  }

  // You can add methods here later to control spawn rate based on game speed,
  // or to introduce different obstacle patterns.
}