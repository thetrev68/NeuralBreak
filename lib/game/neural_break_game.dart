// Core Flame & Flutter dependencies
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';


import 'package:neural_break/game/managers/score_manager.dart';
import 'package:neural_break/game/managers/life_manager.dart';
import 'package:neural_break/game/managers/game_state_manager.dart';
import 'package:neural_break/game/managers/ui_manager.dart';
import 'package:neural_break/game/managers/game_controller.dart';
import 'package:neural_break/game/managers/component_manager.dart';
import 'package:neural_break/game/managers/input_manager.dart';
import 'package:neural_break/game/managers/scene_manager.dart';

// Game components
import 'package:neural_break/game/components/player.dart';
import 'package:neural_break/game/components/obstacle.dart';
import 'package:neural_break/game/components/obstacle_spawner.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/managers/obstacle_pool.dart';

/// Defines possible game states
enum GameState { playing, gameOver, levelUpPaused }

// The main game class. Manages all gameplay logic and components.
class NeuralBreakGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks {
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
  late final ObstaclePool obstaclePool; // ObstaclePool is a regular class, not a Component

  // --- Game Components that are *fields* of the game (can be added/removed directly) ---
  late final Player player;
  late final TextComponent _levelUpMessageText; // Declared here
  late final TextComponent _gameOverText;      // Declared here

  // --- Game State Variables ---
  int _currentLevelScoreTarget = 0;
  // Flag to ensure level up effects are applied only once per pause
  bool _levelUpEffectsAppliedForCurrentPause = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize Managers
    scoreManager = ScoreManager(levelUpThreshold: 100);
    lifeManager = LifeManager(initialLives: initialLives);
    gameStateManager = GameStateManager();
    uiManager = UIManager(
      scoreManager: scoreManager,
      lifeManager: lifeManager,
    );
    gameController = GameController(
      scoreManager: scoreManager,
      lifeManager: lifeManager,
      gameStateManager: gameStateManager,
      uiManager: uiManager,
      inputManager: inputManager, // Passed to GameController
    );
    componentManager = ComponentManager(); // No 'player' needed in constructor
    inputManager = InputManager(); // No 'onTapAction' needed in constructor
    sceneManager = SceneManager(); // Assuming SceneManager constructor is default

    // Initialize Obstacle Pool and Spawner
    obstaclePool = ObstaclePool();
    // await add(obstaclePool); // REMOVED: ObstaclePool is not a Flame Component
    obstacleSpawner = ObstacleSpawner(obstaclePool: obstaclePool);
    await add(obstacleSpawner); // ObstacleSpawner is a Component and needs to be added

    // Initialize Player
    player = Player();
    await add(player);

    // Initialize UI Text Components (these are local variables, passed to UIManager)
    final scoreTextComponent = TextComponent(
      text: 'Score: ${scoreManager.score}',
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
      priority: 5,
      textRenderer: TextPaint(style: TextStyle(fontSize: 20, color: Colors.white)),
    );
    final livesTextComponent = TextComponent(
      text: 'Lives: ${lifeManager.lives}',
      position: Vector2(size.x - 20, 20),
      anchor: Anchor.topRight,
      priority: 5,
      textRenderer: TextPaint(style: TextStyle(fontSize: 20, color: Colors.white)),
    );
    final levelTextComponent = TextComponent(
      text: 'Level: ${scoreManager.level}',
      position: Vector2(20, 20),
      anchor: Anchor.topLeft,
      priority: 5,
      textRenderer: TextPaint(style: TextStyle(fontSize: 20, color: Colors.white)),
    );

    // Add UI text components to the game tree
    await addAll([scoreTextComponent, livesTextComponent, levelTextComponent]);

    // Pass the created text components to the UIManager
    uiManager.initializeTextComponents(scoreTextComponent, livesTextComponent, levelTextComponent);


    // Initialize the level up message text (declared above as a field)
    _levelUpMessageText = TextComponent(
      text: levelUpMessage, // Using constant
      position: size / 2,
      anchor: Anchor.center,
      priority: 10,
      textRenderer: TextPaint(style: TextStyle(fontSize: 48, color: Colors.yellowAccent)),
    );

    // Initialize the game over message text (declared above as a field)
    _gameOverText = TextComponent(
      text: gameOverMessage, // Using constant
      anchor: Anchor.center,
      position: size / 2,
      priority: 10,
      textRenderer: TextPaint(style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
    );

    // Initial game state setup
    _restartGame(); // Call restart to set up initial state
  }

  // Set game background
  @override
  Color backgroundColor() => Colors.black;

  @override
  void update(double dt) {
    super.update(dt); // IMPORTANT: Always call super.update(dt) first

    // --- NEW LEVEL UP LOGIC START ---
    // Check for level up pause state and trigger effects once
    if (gameStateManager.currentGameState == GameState.levelUpPaused) {
      if (!_levelUpEffectsAppliedForCurrentPause) {
        _levelUp(); // Trigger the level up effects (component manipulation, UI update)
        _levelUpEffectsAppliedForCurrentPause = true; // Set flag to prevent repeated calls
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
  void onTapDown(TapDownEvent event) { // Corrected parameter type to TapDownEvent
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
      if (tapX >= jumpZoneLeft && tapX <= jumpZoneRight && tapY < playerCenterY) {
        player.applyJump();
      }
      // Tap below player = slide
      else if (tapX >= jumpZoneLeft && tapX <= jumpZoneRight && tapY > slideZoneTop && tapY < slideZoneBottom) {
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
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Delegate input handling to InputManager
    return inputManager.handleKeyEvent(event, keysPressed, player);
  }

  // --- Collision Handling ---
  // Ensure your components like Player and Obstacle have the HasCollisionDetection mixin
  // and implement onCollisionStart.
  // Example for Player (if it detects collisions with Obstacle):
  // @override
  // void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   super.onCollisionStart(intersectionPoints, other);
  //   if (other is Obstacle) {
  //     gameController.onPlayerHit(); // Notify game controller about player hit
  //     other.removeFromParent(); // Remove obstacle on collision
  //   }
  // }
  // Example for Obstacle (if it detects collisions with Firewall for scoring):
  // @override
  // void onCollisionEnd(PositionComponent other) {
  //   super.onCollisionEnd(other);
  //   // If obstacle passes firewall, or is destroyed, increment score
  //   if (other is Firewall) { // Assuming you have a Firewall component
  //     gameController.onScore(scorePerObstacle);
  //     removeFromParent(); // Remove the obstacle
  //   }
  // }

  // ───── Game Logic Helpers ─────

  void loseLife() {
    if (gameStateManager.currentGameState == GameState.playing) { // Use gameStateManager
      lifeManager.loseLife(); // Assuming LifeManager has a method called loseLife()
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
    scoreManager.incrementScore(amount); // This will handle updating scoreManager.score
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
    _levelUpMessageText.removeFromParent(); // Remove the message from the game tree
    gameStateManager.setPlaying(); // Manually set state to playing after level up for now
    // gameController.continueGameAfterLevelUp(); // Delegate state change to controller (if gameController manages state transition)

    player.reset(); // Reset player position/state
    obstacleSpawner.startSpawning(); // Restart spawning
  }

  void _restartGame() {
    gameController.restartGame(); // Delegates core reset logic to controller
    // Ensure componentManager's resetComponents can actually reset player and obstacles
    componentManager.resetComponents(player: player, activeObstacles: children.whereType<Obstacle>().toList());
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