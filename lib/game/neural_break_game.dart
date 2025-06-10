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

/// The main game class. Manages all gameplay logic and components.
class NeuralBreakGame extends FlameGame
    with TapCallbacks, HasCollisionDetection, KeyboardEvents {
  
  // Main game actors
  late final Player player;
  late final ObstaclePool obstaclePool;
  late final ObstacleSpawner obstacleSpawner;
  late final ScoreManager scoreManager;
  late final LifeManager lifeManager;
  late final GameStateManager gameStateManager;
  late final UIManager uiManager;
  late final GameController gameController;
  late final ComponentManager componentManager;
  late final InputManager inputManager;
  late final SceneManager sceneManager;

  int _currentLevelScoreTarget = 0;
  
    // UI: Text elements for on-screen stats
  final TextComponent _scoreText = TextComponent(
    text: 'Score: 0',
    position: Vector2(10, 10),
    textRenderer: TextPaint(style: TextStyle(fontSize: 20, color: Colors.white)),
  );

  final TextComponent _livesText = TextComponent(
    text: 'Lives: $initialLives',
    position: Vector2(10, 40),
    textRenderer: TextPaint(style: TextStyle(fontSize: 20, color: Colors.white)),
  );

  final TextComponent _levelText = TextComponent(
    text: 'Level: 1',
    position: Vector2(10, 70),
    textRenderer: TextPaint(style: TextStyle(fontSize: 20, color: Colors.white)),
  );

  // UI: Game over message
  final TextComponent _gameOverText = TextComponent(
    text: gameOverMessage,
    anchor: Anchor.center,
    position: Vector2.zero(),
    priority: 10,
    textRenderer: TextPaint(
      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
    ),
  );

  // UI: Level-up message
  final TextComponent _levelUpMessageText = TextComponent(
    text: levelUpMessage,
    anchor: Anchor.center,
    position: Vector2.zero(),
    priority: 10,
    textRenderer: TextPaint(
      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
    ),
  );

  // Current game state
  GameState gameState = GameState.playing;

  // Set game background
  @override
  Color backgroundColor() => Colors.black;

  /// Initializes all components when the game starts
  @override
  @override
Future<void> onLoad() async {
  await super.onLoad();

  // Core game actors
  player = Player();
  obstaclePool = ObstaclePool();
  obstacleSpawner = ObstacleSpawner();

  // Initialize managers
  scoreManager = ScoreManager(levelUpThreshold: 100);
  lifeManager = LifeManager(initialLives: initialLives);
  gameStateManager = GameStateManager();
  uiManager = UIManager(
    scoreManager: scoreManager,
    lifeManager: lifeManager,
    position: Vector2(10, 10),
  );
  gameController = GameController(
    scoreManager: scoreManager,
    lifeManager: lifeManager,
    gameStateManager: gameStateManager,
    uiManager: uiManager,
  );
  componentManager = ComponentManager(
    player: player,
    spawner: obstacleSpawner,
    pool: obstaclePool,
    game: this,
  );
  inputManager = InputManager(
    onTapAction: () => print('Tap!'), // Replace with actual action
    onRestart: _restartGame,
  );
  sceneManager = SceneManager();

  // Add all components
  addAll(uiManager.textComponents);
  componentManager.initializeComponents();

  // Game logic setup
  _calculateCurrentLevelScoreTarget();
}

  /// Repositions messages when the game window resizes
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _gameOverText.position = size / 2;
    _levelUpMessageText.position = size / 2;
  }

  @override
  @override
void update(double dt) {
  super.update(dt);

  // Future expansion: handle per-frame logic based on game state or scene
  if (sceneManager.isScene(Scene.gameplay) && gameStateManager.isPlaying()) {
    // gameController.tick(dt); // Placeholder for future game logic
  }
}

  /// Handles all tap input depending on game state and tap location
  @override
  void onTapDown(TapDownEvent event) {
    if (gameState == GameState.gameOver) {
      _restartGame(); // Restart on game over tap
    } else if (gameState == GameState.levelUpPaused) {
      _continueGameAfterLevelUp(); // Resume after level-up
    } else if (gameState == GameState.playing) {
      // Handle in-game tap logic
      final tapX = event.canvasPosition.x;
      final tapY = event.canvasPosition.y;
      final playerCenterX = player.position.x;
      final playerCenterY = player.position.y;

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

  /// Optional keyboard event for level-up pause
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent &&
        gameState == GameState.levelUpPaused &&
        keysPressed.contains(LogicalKeyboardKey.keyQ)) {
      return KeyEventResult.handled;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  // ───── Game Logic Helpers ─────

  void loseLife() {
    if (gameState == GameState.playing) {
      lifeManager.loseLife(); // Assuming LifeManager has a method called loseLife()
      _updateLivesText();

      if (lifeManager.lives <= 0) {
        gameOver();
      } else {
        _resetForNewLife();
      }
    }
  }

  void gameOver() {
    if (gameState == GameState.playing) {
      gameState = GameState.gameOver;
      add(_gameOverText);

      player.stopAllActions();
      obstacleSpawner.stopSpawning();
      children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
    }
  }

  void _resetForNewLife() {
    gameState = GameState.playing;
    player.reset();
    obstacleSpawner.reset();
    obstaclePool.clear(); // Add here
    obstacleSpawner.startSpawning();
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
  }

  void increaseScore(int amount) {
    scoreManager.incrementScore(amount); // This will handle updating scoreManager.score
    uiManager.updateTexts; // Assuming uiManager has a method for this

    if (scoreManager.score >= _currentLevelScoreTarget) {
      _levelUp();
    }
  }

  void _levelUp() {
    scoreManager.checkLevelUp(); // Assuming scoreManager handles level increment
    uiManager.updateTexts; // Assuming uiManager updates level text

    obstacleSpawner.increaseDifficulty(scoreManager.level);
    _calculateCurrentLevelScoreTarget();

    gameState = GameState.levelUpPaused;
    add(_levelUpMessageText);

    player.stopAllActions();
    obstacleSpawner.stopSpawning();
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
  }

  void _continueGameAfterLevelUp() {
    _levelUpMessageText.removeFromParent();
    gameState = GameState.playing;

    player.reset();
    obstacleSpawner.startSpawning();
  }

  void _restartGame() {
    gameController.restartGame();
    uiManager.updateTexts();
    componentManager.resetComponents();
    _calculateCurrentLevelScoreTarget();
  }

  void _calculateCurrentLevelScoreTarget() {
    int currentLevel = scoreManager.level; // This is correct
    // The currentScore variable itself might not be needed if not used elsewhere,
    // but ensure any usage of `score` here becomes `scoreManager.score`.

    double spawnInterval = initialSpawnInterval - (currentLevel - 1) * spawnIntervalDecreasePerLevel;
    if (spawnInterval < minSpawnInterval) {
      spawnInterval = minSpawnInterval;
    }

    int estimatedObstacles = (levelDuration / spawnInterval).ceil();
    _currentLevelScoreTarget = scoreManager.score + (estimatedObstacles * scorePerObstacle); // Corrected this line
  }

  void _updateScoreText() {
  _scoreText.text = 'Score: ${scoreManager.score}';
  }

  void _updateLivesText() {
    _livesText.text = 'Lives: ${lifeManager.lives}';
  }

  void _updateLevelText() {
    _levelText.text = 'Level: ${scoreManager.level}';
  }
}
