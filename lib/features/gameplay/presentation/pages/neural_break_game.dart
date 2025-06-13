// lib/game/neural_break_game.dart
// Core Flame & Flutter dependencies
import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode

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
import 'package:neural_break/features/gameplay/domain/entities/obstacle.dart';
import 'package:neural_break/features/gameplay/domain/usecases/obstacle_spawner.dart';
import 'package:neural_break/core/constants/game_constants.dart'; // Contains constants like initialLives, gameOverMessage, etc.
import 'package:neural_break/features/gameplay/data/datasources/obstacle_pool.dart';

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
  late final ObstaclePool
      obstaclePool; // ObstaclePool is a regular class, not a Component

  // --- Game Components that are *fields* of the game (can be added/removed directly) ---
  late final Player player;
  late final TextComponent _levelUpMessageText; // Declared here
  late final TextComponent _gameOverText; // Declared here

  // --- Game State Variables ---
  int _currentLevelScoreTarget = 0;
  // Flag to ensure level up effects are applied only once per pause
  bool _levelUpEffectsAppliedForCurrentPause = false;

  // The 'loaded' Future is managed internally by FlameGame now that GameWidget is used.
  // late final Future<void> loadComplete; // No longer manually exposed or needed this way

  @override
  Future<void> onLoad() async {
    if (kDebugMode) {
      print('NeuralBreakGame: onLoad started (STEP 3: Inside onLoad)');
    }
    await super.onLoad(); // IMPORTANT: Call super.onLoad() first
    if (kDebugMode) {
      print('NeuralBreakGame: super.onLoad completed (STEP 4)');
    }

    try {
      // Initialize Managers that don't depend on player first
      scoreManager = ScoreManager(levelUpThreshold: 100);
      lifeManager = LifeManager(
          initialLives:
              initialLives); // Using constant from game_constants.dart
      gameStateManager = GameStateManager();
      if (kDebugMode) {
        print('NeuralBreakGame: Core Managers initialized (STEP 5)');
      }

      // Initialize Player early, because UIManager needs it
      player = Player(tickerProvider: tickerProvider);
      if (kDebugMode) {
        print('NeuralBreakGame: Player instance created (STEP 6)');
      }
      await add(player); // Add player as a component to the game tree
      if (kDebugMode) {
        print('NeuralBreakGame: Player added to game tree (STEP 7)');
      }

      // Now initialize UIManager with player available
      uiManager = UIManager(
        scoreManager: scoreManager,
        lifeManager: lifeManager,
        player: player,
      );
      if (kDebugMode) {
        print('NeuralBreakGame: UIManager initialized (STEP 8)');
      }

      // Initialize inputManager after UIManager
      inputManager = InputManager();
      if (kDebugMode) {
        print('NeuralBreakGame: InputManager initialized (STEP 9)');
      }

      // Initialize GameController with all dependencies ready
      gameController = GameController(
        scoreManager: scoreManager,
        lifeManager: lifeManager,
        gameStateManager: gameStateManager,
        uiManager: uiManager,
        inputManager: inputManager,
      );
      if (kDebugMode) {
        print('NeuralBreakGame: GameController initialized (STEP 10)');
      }

      componentManager = ComponentManager();
      sceneManager = SceneManager();
      if (kDebugMode) {
        print(
            'NeuralBreakGame: ComponentManager and SceneManager initialized (STEP 11)');
      }

      // Initialize Obstacle Pool and Spawner
      obstaclePool = ObstaclePool();
      obstacleSpawner = ObstacleSpawner(obstaclePool: obstaclePool);
      if (kDebugMode) {
        print(
            'NeuralBreakGame: ObstaclePool and Spawner initialized (STEP 12)');
      }
      await add(obstacleSpawner); // Add spawner as a component to the game tree
      if (kDebugMode) {
        print('NeuralBreakGame: ObstacleSpawner added to game tree (STEP 13)');
      }

      // Initialize UI Text Components
      final scoreTextComponent = TextComponent(
        text: 'Score: ${scoreManager.score}',
        position: Vector2(size.x / 2, 20),
        anchor: Anchor.topCenter,
        priority: 5,
        textRenderer: TextPaint(
            style: const TextStyle(fontSize: 20, color: Colors.white)),
      );
      final livesTextComponent = TextComponent(
        text: 'Lives: ${lifeManager.lives}',
        position: Vector2(size.x - 20, 20),
        anchor: Anchor.topRight,
        priority: 5,
        textRenderer: TextPaint(
            style: const TextStyle(fontSize: 20, color: Colors.white)),
      );
      final levelTextComponent = TextComponent(
        text: 'Level: ${scoreManager.level}',
        position: Vector2(20, 20),
        anchor: Anchor.topLeft,
        priority: 5,
        textRenderer: TextPaint(
            style: const TextStyle(fontSize: 20, color: Colors.white)),
      );

      // Add UI text components to the game tree
      await addAll(
          [scoreTextComponent, livesTextComponent, levelTextComponent]);
      if (kDebugMode) {
        print('NeuralBreakGame: UI Text Components added (STEP 14)');
      }

      // Pass text components to UIManager
      uiManager.initializeTextComponents(
          scoreTextComponent, livesTextComponent, levelTextComponent);
      if (kDebugMode) {
        print(
            'NeuralBreakGame: UIManager text components initialized (STEP 15)');
      }

      // Initialize level up message text
      _levelUpMessageText = TextComponent(
        text: levelUpMessage, // Using constant from game_constants.dart
        position: size / 2,
        anchor: Anchor.center,
        priority: 10,
        textRenderer: TextPaint(
            style: const TextStyle(fontSize: 48, color: Colors.yellowAccent)),
      );
      if (kDebugMode) {
        print('NeuralBreakGame: Level Up Message Text initialized (STEP 16)');
      }

      // Initialize game over message text
      _gameOverText = TextComponent(
        text: gameOverMessage, // Using constant from game_constants.dart
        anchor: Anchor.center,
        position: size / 2,
        priority: 10,
        textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
      );
      if (kDebugMode) {
        print('NeuralBreakGame: Game Over Message Text initialized (STEP 17)');
      }

      // Initial game state setup
      _restartGame(); // This method might have its own issues.
      if (kDebugMode) {
        print('NeuralBreakGame: _restartGame called (STEP 18)');
      }

      if (kDebugMode) {
        print('NeuralBreakGame: onLoad completed successfully! (STEP 19)');
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('NeuralBreakGame: FATAL ERROR in onLoad(): $e');
        print('Stack Trace: $s');
      }
      rethrow; // Re-throw the error so RootWidgetState can potentially catch it
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
        _levelUp(); // Trigger the level up effects (component manipulation, UI update)
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
    // Corrected parameter type to TapDownEvent
    // If game is over, tap to restart
    if (gameStateManager.currentGameState == GameState.gameOver) {
      if (contains(_gameOverText)) {
        remove(_gameOverText); // Remove the game over message from view
      }
      _restartGame(); // Restart on game over tap
    }
    // If game is paused for level up, tap to continue
    else if (gameStateManager.currentGameState == GameState.levelUpPaused) {
      if (contains(_levelUpMessageText)) {
        remove(_levelUpMessageText); // Remove level up message from view
      }
      _continueGameAfterLevelUp(); // Resume after level-up
    }
    // Handle in-game tap logic only when playing
    else if (gameStateManager.currentGameState == GameState.playing) {
      final tapX = event.canvasPosition.x; // Corrected access for TapDownEvent
      final tapY = event.canvasPosition.y; // Corrected access for TapDownEvent
      final playerCenterX = player.position.x;
      final playerCenterY = player.position.y;

      // Assuming jumpTapZoneWidth and slideTapZoneHeight are defined as constants or fields
      final jumpZoneLeft = playerCenterX - (jumpTapZoneWidth / 2);
      final jumpZoneRight = playerCenterX + (jumpTapZoneWidth / 2);
      final slideZoneTop = playerCenterY + player.size.y / 2;
      final slideZoneBottom = slideZoneTop + slideTapZoneHeight;

      // Tap above player = jump
      if (tapX >= jumpZoneLeft &&
          tapX <= jumpZoneRight &&
          tapY < playerCenterY) {
        player.applyJump();
      }
      // Tap below player = slide
      else if (tapX >= jumpZoneLeft &&
          tapX <= jumpZoneRight &&
          tapY > slideZoneTop &&
          tapY < slideZoneBottom) {
        player.applySlide();
      }
      // Tap left = move left
      else if (tapX < playerCenterX) {
        player.moveLeft();
      }
      // Tap right = move right
      else if (tapX > playerCenterX) {
        player.moveRight();
      }
    }
  }

  // --- Input Handling ---
  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Delegate input handling to InputManager
    final result = inputManager.handleKeyEvent(event, keysPressed, player);

    // If our input manager handled it, return that result.
    // Otherwise, call super.onKeyEvent to allow other keyboard components or default Flame behavior to process it.
    if (result == KeyEventResult.handled) {
      return result;
    }
    return super.onKeyEvent(event, keysPressed); // Call super method
  }

  @override
  void onRemove() {
    super.onRemove();
    if (kDebugMode) {
      print('NeuralBreakGame: onRemove called. Game is being removed.');
    }
  }

  // ───── Game Logic Helpers ─────

  void loseLife() {
    if (gameStateManager.currentGameState == GameState.playing) {
      // Use gameStateManager
      lifeManager
          .loseLife(); // Assuming LifeManager has a method called loseLife()
      uiManager.updateTexts(); // Update UI after life change

      if (lifeManager.lives <= 0) {
        onGameOver(); // Use onGameOver()
      } else {
        _resetForNewLife();
      }
    }
  }

  // You might need methods like `onGameOver()` that delegate to gameController,
  // and manage the _gameOverText here:
  void onGameOver() {
    // This is triggered by gameController.onPlayerHit if lives run out
    gameStateManager.setGameOver(); // Ensure state is set
    add(_gameOverText); // Add the game over message
    // Potentially stop all game components here if not handled elsewhere
    player.stopAllActions();
    obstacleSpawner.stopSpawning();
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
  }

  void _resetForNewLife() {
    gameStateManager.setPlaying(); // Use gameStateManager to set state
    player.reset();
    obstacleSpawner.reset();
    obstaclePool.clear(); // Add here
    obstacleSpawner.startSpawning();
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
  }

  void increaseScore(int amount) {
    scoreManager
        .incrementScore(amount); // This will handle updating scoreManager.score
    uiManager.updateTexts(); // Call the updateTexts method properly

    if (scoreManager.score >= _currentLevelScoreTarget) {
      _levelUp();
    }
  }

  void _levelUp() {
    // This method now only applies the effects after GameController has set the state.
    // The state change to levelUpPaused happens in update() and triggers this method.
    obstacleSpawner.increaseDifficulty(scoreManager.level);

    add(_levelUpMessageText); // Add the level up message component to the game tree

    player.stopAllActions();
    obstacleSpawner.stopSpawning();
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
  }

  void _continueGameAfterLevelUp() {
    _levelUpMessageText
        .removeFromParent(); // Remove the message from the game tree
    gameStateManager
        .setPlaying(); // Manually set state to playing after level up for now
    // gameController.continueGameAfterLevelUp(); // Delegate state change to controller (if gameController manages state transition)

    player.reset(); // Reset player position/state
    obstacleSpawner.startSpawning(); // Restart spawning
  }

  void _restartGame() {
    gameController.restartGame(); // Delegates core reset logic to controller
    // Ensure componentManager's resetComponents can actually reset player and obstacles
    componentManager.resetComponents(
        player: player,
        activeObstacles: children.whereType<Obstacle>().toList());
    _calculateCurrentLevelScoreTarget(); // Recalculate target for new game
    uiManager.updateTexts(); // Update UI after restart
  }

  void _calculateCurrentLevelScoreTarget() {
    // Delegates calculation to ScoreManager
    _currentLevelScoreTarget = scoreManager.calculateLevelScoreTarget(
      initialSpawnInterval: initialSpawnInterval,
      spawnIntervalDecreasePerLevel: spawnIntervalDecreasePerLevel,
      minSpawnInterval: minSpawnInterval,
      levelDuration: levelDuration,
      scorePerObstacle: scorePerObstacle,
    );
  }

  // REMOVED: _updateScoreText, _updateLivesText, _updateLevelText
  // These are now handled by uiManager.updateTexts()
}
