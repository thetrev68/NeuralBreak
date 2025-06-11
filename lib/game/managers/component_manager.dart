// lib/game/managers/component_manager.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/components/player.dart';
import 'package:neural_break/game/components/obstacle.dart'; // Make sure Obstacle is imported
import 'package:neural_break/game/components/obstacle_spawner.dart'; // Make sure ObstacleSpawner is imported
import 'package:neural_break/game/managers/obstacle_pool.dart'; // Make sure ObstaclePool is imported

class ComponentManager {
  // The constructor no longer requires specific components.
  // It's a general manager that performs actions on components passed to its methods.
  ComponentManager();

  // This method now accepts the components it needs to reset as optional named parameters.
  void resetComponents({
    Player? player, // Player is now an optional parameter
    ObstacleSpawner? spawner, // Spawner is now an optional parameter
    ObstaclePool? pool, // Pool is now an optional parameter
    List<Obstacle>? activeObstacles, // List of active obstacles
  }) {
    player?.reset(); // Reset player if provided
    spawner?.reset(); // Reset spawner if provided
    pool?.clear(); // Clear pool if provided
    activeObstacles?.forEach((o) => o.removeFromParent()); // Remove obstacles if provided
    spawner?.startSpawning(); // Start spawning if spawner is provided (should be called after clearing obstacles)
  }

  // REMOVED: initializeComponents() method, as it's not used and its functionality
  // is typically handled directly in NeuralBreakGame's onLoad.
}