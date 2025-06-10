import 'package:flame/components.dart';
import '../components/player.dart';
import '../components/obstacle_spawner.dart';
import '../managers/obstacle_pool.dart';
import 'package:flame/game.dart';
import 'package:neural_break/game/components/obstacle.dart';

class ComponentManager {
  final Player player;
  final ObstacleSpawner spawner;
  final ObstaclePool pool;
  final FlameGame game;

  ComponentManager({
    required this.player,
    required this.spawner,
    required this.pool,
    required this.game,
  });

  void initializeComponents() {
    game.add(player);
    game.add(spawner);
    // Add other initial game components
  }

  void resetComponents() {
    player.reset();
    spawner.reset();
    pool.clear();
    game.children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
    spawner.startSpawning();
  }
}
