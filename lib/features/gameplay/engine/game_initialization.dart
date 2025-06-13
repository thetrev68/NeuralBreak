// File: lib/features/gameplay/engine/game_initialization.dart

// Flutter package imports
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

// Project imports
import 'package:neural_break/core/constants/game_constants.dart';
import 'package:neural_break/features/gameplay/data/datasources/obstacle_pool.dart';
import 'package:neural_break/features/gameplay/domain/entities/player.dart';
import 'package:neural_break/features/gameplay/domain/usecases/input_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/life_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/obstacle_spawner.dart';
import 'package:neural_break/features/gameplay/domain/usecases/score_manager.dart';
import 'package:neural_break/features/gameplay/presentation/bloc/game_controller.dart';
import 'package:neural_break/features/gameplay/presentation/bloc/game_state_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/component_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/scene_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/ui_manager.dart';

// Relative imports
import '../engine/neural_break_game.dart';

Future<void> initializeGameSystems(NeuralBreakGame game) async {
  if (kDebugMode) {
    print('initializeGameSystems: STARTING.'); // New precise print
  }

  // Initialize Managers that don't depend on player first
  game.scoreManager = ScoreManager(levelUpThreshold: 100);
  game.lifeManager = LifeManager(initialLives: initialLives);
  game.gameStateManager = GameStateManager();
  if (kDebugMode) {
    print(
        'initializeGameSystems: Core Managers initialized.'); // New precise print
  }

  // Initialize Player early, because UIManager needs it
  game.player = Player(tickerProvider: game.tickerProvider);
  if (kDebugMode) {
    print(
        'initializeGameSystems: Player instance created.'); // New precise print
  }
  await game.add(game.player);
  if (kDebugMode) {
    print(
        'initializeGameSystems: Player added to game tree.'); // New precise print
  }

  // Now initialize UIManager with player available
  game.uiManager = UIManager(
    scoreManager: game.scoreManager,
    lifeManager: game.lifeManager,
    player: game.player,
  );
  if (kDebugMode) {
    print('initializeGameSystems: UIManager initialized.'); // New precise print
  }

  // Initialize inputManager after UIManager
  game.inputManager = InputManager();
  if (kDebugMode) {
    print(
        'initializeGameSystems: InputManager initialized.'); // New precise print
  }

  // Initialize GameController with all dependencies ready
  game.gameController = GameController(
    scoreManager: game.scoreManager,
    lifeManager: game.lifeManager,
    gameStateManager: game.gameStateManager,
    uiManager: game.uiManager,
    inputManager: game.inputManager,
  );
  if (kDebugMode) {
    print(
        'initializeGameSystems: GameController initialized.'); // New precise print
  }

  game.componentManager = ComponentManager();
  game.sceneManager = SceneManager();
  if (kDebugMode) {
    print(
        'initializeGameSystems: ComponentManager and SceneManager initialized.'); // New precise print
  }

  // Initialize Obstacle Pool and Spawner
  game.obstaclePool = ObstaclePool();
  // 🔥🔥🔥 POTENTIAL FIX: You MUST await the onLoad of ObstaclePool if it loads assets or does async setup.
  // The ObstaclePool class will have an onLoad method if it extends Component or has async init.
  // If ObstaclePool has its own onLoad, it should be called and awaited.
  // Assuming ObstaclePool itself might have an onLoad to load obstacles, for example.
  // If ObstaclePool doesn't have an onLoad, but you add its children components,
  // those children's onLoads might need to be awaited directly.
  // For safety, add the `await` here. If `ObstaclePool.onLoad` is not async, this won't hurt.
  if (game.obstaclePool is Component) {
    // Check if it's a Flame component
    await (game.obstaclePool as Component).onLoad(); // Cast and await
    if (kDebugMode) {
      print('initializeGameSystems: ObstaclePool onLoad completed.');
    }
  }

  game.obstacleSpawner = ObstacleSpawner(obstaclePool: game.obstaclePool);
  if (kDebugMode) {
    print(
        'initializeGameSystems: ObstaclePool and Spawner initialized.'); // New precise print
  }
  await game.add(game.obstacleSpawner);
  if (kDebugMode) {
    print(
        'initializeGameSystems: ObstacleSpawner added to game tree.'); // New precise print
  }

  if (kDebugMode) {
    print(
        'initializeGameSystems: ALL SYSTEMS INITIALIZED. EXITING.'); // New precise print
  }
}
