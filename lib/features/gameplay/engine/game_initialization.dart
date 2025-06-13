// File: lib/features/gameplay/engine/game_initialization.dart

import 'package:flutter/foundation.dart';
import 'package:neural_break/features/gameplay/domain/usecases/score_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/life_manager.dart';
import 'package:neural_break/features/gameplay/presentation/bloc/game_state_manager.dart';
import 'package:neural_break/features/gameplay/presentation/bloc/game_controller.dart';
import 'package:neural_break/features/gameplay/presentation/components/ui_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/component_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/scene_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/input_manager.dart';
import 'package:neural_break/features/gameplay/data/datasources/obstacle_pool.dart';
import 'package:neural_break/features/gameplay/domain/usecases/obstacle_spawner.dart';
import 'package:neural_break/features/gameplay/domain/entities/player.dart';
import 'package:neural_break/core/constants/game_constants.dart';

import '../engine/neural_break_game.dart';

Future<void> initializeGameSystems(NeuralBreakGame game) async {
  // Initialize Managers that don't depend on player first
  game.scoreManager = ScoreManager(levelUpThreshold: 100);
  game.lifeManager = LifeManager(initialLives: initialLives);
  game.gameStateManager = GameStateManager();
  if (kDebugMode) {
    print('NeuralBreakGame: Core Managers initialized (STEP 5)');
  }

  // Initialize Player early, because UIManager needs it
  game.player = Player(tickerProvider: game.tickerProvider);
  if (kDebugMode) {
    print('NeuralBreakGame: Player instance created (STEP 6)');
  }
  await game.add(game.player);
  if (kDebugMode) {
    print('NeuralBreakGame: Player added to game tree (STEP 7)');
  }

  // Now initialize UIManager with player available
  game.uiManager = UIManager(
    scoreManager: game.scoreManager,
    lifeManager: game.lifeManager,
    player: game.player,
  );
  if (kDebugMode) {
    print('NeuralBreakGame: UIManager initialized (STEP 8)');
  }

  // Initialize inputManager after UIManager
  game.inputManager = InputManager();
  if (kDebugMode) {
    print('NeuralBreakGame: InputManager initialized (STEP 9)');
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
    print('NeuralBreakGame: GameController initialized (STEP 10)');
  }

  game.componentManager = ComponentManager();
  game.sceneManager = SceneManager();
  if (kDebugMode) {
    print(
        'NeuralBreakGame: ComponentManager and SceneManager initialized (STEP 11)');
  }

  // Initialize Obstacle Pool and Spawner
  game.obstaclePool = ObstaclePool();
  game.obstacleSpawner = ObstacleSpawner(obstaclePool: game.obstaclePool);
  if (kDebugMode) {
    print('NeuralBreakGame: ObstaclePool and Spawner initialized (STEP 12)');
  }
  await game.add(game.obstacleSpawner);
  if (kDebugMode) {
    print('NeuralBreakGame: ObstacleSpawner added to game tree (STEP 13)');
  }
}
