// lib/game/neural_break_game.dart

// Core Flame & Flutter dependencies
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package Imports (if any external packages)
// import 'package:some_package/some_package.dart';

// Project Imports
import 'package:neural_break/core/constants/game_states.dart';
import 'package:neural_break/features/gameplay/data/datasources/obstacle_pool.dart';
import 'package:neural_break/features/gameplay/domain/entities/player.dart';
import 'package:neural_break/features/gameplay/domain/usecases/input_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/life_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/obstacle_spawner.dart';
import 'package:neural_break/features/gameplay/domain/usecases/score_manager.dart';
import 'package:neural_break/features/gameplay/engine/game_initialization.dart';
import 'package:neural_break/features/gameplay/engine/game_logic_helpers.dart';
import 'package:neural_break/features/gameplay/engine/input_router.dart';
import 'package:neural_break/features/gameplay/engine/text_ui_initializer.dart';
import 'package:neural_break/features/gameplay/presentation/bloc/game_controller.dart';
import 'package:neural_break/features/gameplay/presentation/bloc/game_state_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/component_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/scene_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/ui_manager.dart';

// The main game class. Manages all gameplay logic and components.
class NeuralBreakGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks {
  final TickerProvider tickerProvider;

  NeuralBreakGame({required this.tickerProvider});

  // --- Game Managers ---
  late final ComponentManager componentManager;
  late final GameController gameController;
  late final GameStateManager gameStateManager;
  late final InputManager inputManager;
  late final LifeManager lifeManager;
  late final ObstaclePool obstaclePool;
  late final ObstacleSpawner obstacleSpawner;
  late final SceneManager sceneManager;
  late final ScoreManager scoreManager;
  late final UIManager uiManager;

  // --- Game Components that are *fields* of the game (can be added/removed directly) ---
  late final TextComponent gameOverText;
  late final TextComponent levelUpMessageText;
  late final Player player;

  // --- Game State Variables ---
  int currentLevelScoreTarget = 0;

  // Flag to ensure level up effects are applied only once per pause
  bool _levelUpEffectsAppliedForCurrentPause = false;

  @override
  Future<void> onLoad() async {
    if (kDebugMode) {
      print('NeuralBreakGame.onLoad(): --- STEP 1: Method entered.');
    }

    await super.onLoad();
    if (kDebugMode) {
      print('NeuralBreakGame.onLoad(): --- STEP 2: super.onLoad() completed.');
    }

    try {
      if (kDebugMode) {
        print(
            'NeuralBreakGame.onLoad(): --- STEP 3: Calling initializeGameSystems...');
      }
      await initializeGameSystems(this);
      if (kDebugMode) {
        print(
            'NeuralBreakGame.onLoad(): --- STEP 4: initializeGameSystems completed.');
      }

      if (kDebugMode) {
        print(
            'NeuralBreakGame.onLoad(): --- STEP 5: Calling initializeUITextComponents...');
      }
      await initializeUITextComponents(this);
      if (kDebugMode) {
        print(
            'NeuralBreakGame.onLoad(): --- STEP 6: initializeUITextComponents completed.');
      }

      if (kDebugMode) {
        print('NeuralBreakGame.onLoad(): --- STEP 7: Calling restartGame...');
      }
      // This function is assumed synchronous. If it contains async calls that *need* awaiting,
      // it should be made async and awaited here.
      restartGame(this);
      if (kDebugMode) {
        print('NeuralBreakGame.onLoad(): --- STEP 8: restartGame completed.');
      }

      if (kDebugMode) {
        print(
            'NeuralBreakGame.onLoad(): --- STEP 9: ALL onLoad TASKS COMPLETE.');
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('NeuralBreakGame: FATAL ERROR in onLoad(): $e');
        print('Stack Trace: $s');
      }
      rethrow;
    }
  }

  @override
  Color backgroundColor() => Colors.black;

  @override
  void update(double dt) {
    super.update(dt);

    if (gameStateManager.currentGameState == GameState.levelUpPaused) {
      if (!_levelUpEffectsAppliedForCurrentPause) {
        levelUp(this); // Trigger the level up effects
        _levelUpEffectsAppliedForCurrentPause = true;
      }
      return; // Stop further game logic updates while paused for level up
    }

    // Reset the flag if not in levelUpPaused state.
    if (_levelUpEffectsAppliedForCurrentPause &&
        gameStateManager.currentGameState != GameState.levelUpPaused) {
      _levelUpEffectsAppliedForCurrentPause = false;
    }

    if (gameStateManager.currentGameState == GameState.playing) {
      uiManager.updateTexts();
    }
  }

  // Handles all tap input depending on game state and tap location
  @override
  void onTapDown(TapDownEvent event) {
    forwardTapEventToGame(this, event);
  }

  // --- Input Handling ---
  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final result = forwardKeyEventToInputManager(this, event, keysPressed);
    return result == KeyEventResult.handled
        ? result
        : super.onKeyEvent(event, keysPressed);
  }

  @override
  void onRemove() {
    super.onRemove();
    if (kDebugMode) {
      print('NeuralBreakGame: onRemove called. Game is being removed.');
    }
  }
}
