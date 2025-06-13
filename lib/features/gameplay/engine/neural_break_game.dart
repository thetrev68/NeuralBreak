// lib/game/neural_break_game.dart
// Core Flame & Flutter dependencies
import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:neural_break/features/gameplay/engine/game_initialization.dart';
import 'package:neural_break/features/gameplay/engine/text_ui_initializer.dart';
import 'package:neural_break/features/gameplay/engine/game_logic_helpers.dart';

// Game Managers
import 'package:neural_break/features/gameplay/domain/usecases/score_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/life_manager.dart';
import 'package:neural_break/features/gameplay/presentation/bloc/game_state_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/ui_manager.dart';
import 'package:neural_break/features/gameplay/presentation/bloc/game_controller.dart';
import 'package:neural_break/features/gameplay/presentation/components/component_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/input_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/scene_manager.dart';

// Game components
import 'package:neural_break/features/gameplay/domain/entities/player.dart';
import 'package:neural_break/features/gameplay/domain/usecases/obstacle_spawner.dart';
// Contains constants like initialLives, gameOverMessage, etc.
import 'package:neural_break/features/gameplay/data/datasources/obstacle_pool.dart';
import 'package:neural_break/features/gameplay/engine/input_router.dart';

/// Defines possible game states
import 'package:neural_break/core/constants/game_states.dart';

// The main game class. Manages all gameplay logic and components.
class NeuralBreakGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks {
  final TickerProvider tickerProvider;

  NeuralBreakGame({required this.tickerProvider});

  // --- Game Managers ---
  late final ScoreManager scoreManager;
  late final LifeManager lifeManager;
  late final GameStateManager gameStateManager;
  late final UIManager uiManager;
  late final GameController gameController;
  late final ComponentManager componentManager;
  late final InputManager inputManager;
  late final SceneManager sceneManager;
  late final ObstacleSpawner obstacleSpawner;
  late final ObstaclePool obstaclePool;

  // --- Game Components that are *fields* of the game (can be added/removed directly) ---
  late final Player player;
  late final TextComponent levelUpMessageText; // Declared here
  late final TextComponent gameOverText; // Declared here

  // --- Game State Variables ---
  int currentLevelScoreTarget = 0;
  // Flag to ensure level up effects are applied only once per pause
  bool _levelUpEffectsAppliedForCurrentPause = false;

  // The 'loaded' Future is managed internally by FlameGame now that GameWidget is used.
  // late final Future<void> loadComplete; // No longer manually exposed or needed this way

  @override
  Future<void> onLoad() async {
    if (kDebugMode) {
      print('NeuralBreakGame: onLoad started (STEP 3: Inside onLoad)');
    }

    await super.onLoad();
    if (kDebugMode) {
      print('NeuralBreakGame: super.onLoad completed (STEP 4)');
    }

    try {
      // Initialize core systems (managers + player + controller + spawner + components)
      await initializeGameSystems(this);

      // Initialize all UI text components (score, lives, level, overlays)
      await initializeUITextComponents(this);

      restartGame(this);

      if (kDebugMode) {
        print('NeuralBreakGame: _restartGame called (STEP 18)');
        print('NeuralBreakGame: onLoad completed successfully! (STEP 19)');
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
    super.update(dt); // IMPORTANT: Always call super.update(dt) first

    // ... (rest of your update method)
    // --- NEW LEVEL UP LOGIC START ---
    // Check for level up pause state and trigger effects once
    if (gameStateManager.currentGameState == GameState.levelUpPaused) {
      if (!_levelUpEffectsAppliedForCurrentPause) {
        levelUp(
            this); // Trigger the level up effects (component manipulation, UI update)
        _levelUpEffectsAppliedForCurrentPause =
            true; // Set flag to prevent repeated calls
      }
      return; // Stop further game logic updates while paused for level up
    } else {
      // Reset the flag when the game is not in level up paused state
      _levelUpEffectsAppliedForCurrentPause = false;
    }
    // --- NEW LEVEL UP LOGIC END ---

    // Game logic for when the game is playing
    if (gameStateManager.currentGameState == GameState.playing) {
      // Update UI texts (score, lives, level) continuously while playing
      uiManager.updateTexts(); // Call the updateTexts method
      // You can add other continuous playing-state logic here
      // For instance, if player movement needs to be continuously applied based on input,
      // it might be done here or delegated to GameController.
      // gameController.updatePlayingState(dt, player); // If you move update logic to gameController
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

  // ───── Game Logic Helpers ─────
}
