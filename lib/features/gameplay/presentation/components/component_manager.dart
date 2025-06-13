// file: lib/features/gameplay/presentation/components/component_manager.dart

import 'package:neural_break/features/gameplay/data/datasources/obstacle_pool.dart'; // Project imports
import 'package:neural_break/features/gameplay/domain/entities/obstacle.dart';
import 'package:neural_break/features/gameplay/domain/entities/player.dart';
import 'package:neural_break/features/gameplay/domain/usecases/obstacle_spawner.dart';

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
    activeObstacles
        ?.forEach((o) => o.removeFromParent()); // Remove obstacles if provided
    spawner
        ?.startSpawning(); // Start spawning if spawner is provided (should be called after clearing obstacles)
  }

  // REMOVED: initializeComponents() method, as it's not used and its functionality
  // is typically handled directly in NeuralBreakGame's onLoad.
}
