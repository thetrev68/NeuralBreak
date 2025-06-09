import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:neural_break/game/components/player.dart';
import 'package:neural_break/game/components/obstacle.dart';
import 'package:neural_break/game/components/obstacle_spawner.dart';
import 'package:neural_break/game/util/game_constants.dart';

// Game states
enum GameState { playing, gameOver, levelUpPaused }

class NeuralBreakGame extends FlameGame
    with TapCallbacks, HasCollisionDetection, KeyboardEvents {
  late final Player player;
  late final ObstacleSpawner obstacleSpawner;

  int score = 0;
  int lives = initialLives;
  int currentLevel = 1;
  int _currentLevelScoreTarget = 0;

  // Text components
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

  final TextComponent _gameOverText = TextComponent(
    text: gameOverMessage,
    anchor: Anchor.center,
    position: Vector2.zero(),
    priority: 10,
    textRenderer: TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  final TextComponent _levelUpMessageText = TextComponent(
    text: levelUpMessage,
    anchor: Anchor.center,
    position: Vector2.zero(),
    priority: 10,
    textRenderer: TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  GameState gameState = GameState.playing;

  @override
  Color backgroundColor() => Colors.black;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(_scoreText);
    add(_livesText);
    add(_levelText);

    player = Player();
    add(player);

    obstacleSpawner = ObstacleSpawner();
    add(obstacleSpawner);

    _calculateCurrentLevelScoreTarget();
    _updateScoreText();
    _updateLivesText();
    _updateLevelText();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    _gameOverText.position = canvasSize / 2;
    _levelUpMessageText.position = canvasSize / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState == GameState.gameOver) {
      _restartGame();
    } else if (gameState == GameState.levelUpPaused) {
      _continueGameAfterLevelUp();
    } else if (gameState == GameState.playing) {
      final tapX = event.canvasPosition.x;
      final tapY = event.canvasPosition.y;
      final playerCenterX = player.position.x;
      final playerCenterY = player.position.y;

      final jumpZoneLeft = playerCenterX - (jumpTapZoneWidth / 2);
      final jumpZoneRight = playerCenterX + (jumpTapZoneWidth / 2);
      final slideZoneTop = playerCenterY + player.size.y / 2;
      final slideZoneBottom = slideZoneTop + slideTapZoneHeight;

      if (tapX >= jumpZoneLeft &&
          tapX <= jumpZoneRight &&
          tapY < playerCenterY) {
        player.applyJump();
      } else if (tapX >= jumpZoneLeft &&
          tapX <= jumpZoneRight &&
          tapY > slideZoneTop &&
          tapY < slideZoneBottom) {
        player.applySlide();
      } else if (tapX < playerCenterX) {
        player.moveLeft();
      } else if (tapX > playerCenterX) {
        player.moveRight();
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent &&
        gameState == GameState.levelUpPaused &&
        keysPressed.contains(LogicalKeyboardKey.keyQ)) {
      return KeyEventResult.handled;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void loseLife() {
    if (gameState == GameState.playing) {
      lives--;
      _updateLivesText();

      if (lives <= 0) {
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
    obstacleSpawner.startSpawning();
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
  }

  void increaseScore(int amount) {
    score += amount;
    _updateScoreText();

    if (score >= _currentLevelScoreTarget) {
      _levelUp();
    }
  }

  void _levelUp() {
    currentLevel++;
    _updateLevelText();
    obstacleSpawner.increaseDifficulty(currentLevel);
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
    score = 0;
    lives = initialLives;
    currentLevel = 1;

    _updateScoreText();
    _updateLivesText();
    _updateLevelText();

    _gameOverText.removeFromParent();
    player.reset();
    obstacleSpawner.reset();
    obstacleSpawner.startSpawning();
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());

    gameState = GameState.playing;
    _calculateCurrentLevelScoreTarget();
  }

  void _calculateCurrentLevelScoreTarget() {
    double spawnInterval = initialSpawnInterval - (currentLevel - 1) * spawnIntervalDecreasePerLevel;
    if (spawnInterval < minSpawnInterval) {
      spawnInterval = minSpawnInterval;
    }
    int estimatedObstacles = (levelDuration / spawnInterval).ceil();
    _currentLevelScoreTarget = score + (estimatedObstacles * scorePerObstacle);
  }

  void _updateScoreText() {
    _scoreText.text = 'Score: $score';
  }

  void _updateLivesText() {
    _livesText.text = 'Lives: $lives';
  }

  void _updateLevelText() {
    _levelText.text = 'Level: $currentLevel';
  }
}
