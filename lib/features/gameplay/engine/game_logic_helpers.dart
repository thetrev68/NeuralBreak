// File: lib/features/gameplay/engine/game_logic_helpers.dart

import 'package:neural_break/core/constants/game_constants.dart';
import 'package:neural_break/core/constants/game_states.dart';
import 'package:neural_break/features/gameplay/domain/entities/obstacle.dart';

import '../engine/neural_break_game.dart';

void loseLife(NeuralBreakGame game) {
  if (game.gameStateManager.currentGameState == GameState.playing) {
    game.lifeManager.loseLife();
    game.uiManager.updateTexts();

    if (game.lifeManager.lives <= 0) {
      onGameOver(game);
    } else {
      _resetForNewLife(game);
    }
  }
}

void onGameOver(NeuralBreakGame game) {
  game.gameStateManager.setGameOver();
  game.add(game.gameOverText);
  game.player.stopAllActions();
  game.obstacleSpawner.stopSpawning();
  game.children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
}

void _resetForNewLife(NeuralBreakGame game) {
  game.gameStateManager.setPlaying();
  game.player.reset();
  game.obstacleSpawner.reset();
  game.obstaclePool.clear();
  game.obstacleSpawner.startSpawning();
  game.children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
}

void increaseScore(NeuralBreakGame game, int amount) {
  game.scoreManager.incrementScore(amount);
  game.uiManager.updateTexts();

  if (game.scoreManager.score >= game.currentLevelScoreTarget) {
    levelUp(game);
  }
}

void levelUp(NeuralBreakGame game) {
  game.obstacleSpawner.increaseDifficulty(game.scoreManager.level);
  game.add(game.levelUpMessageText);
  game.player.stopAllActions();
  game.obstacleSpawner.stopSpawning();
  game.children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
}

void continueGameAfterLevelUp(NeuralBreakGame game) {
  game.levelUpMessageText.removeFromParent();
  game.gameStateManager.setPlaying();
  game.player.reset();
  game.obstacleSpawner.startSpawning();
}

void restartGame(NeuralBreakGame game) {
  game.gameController.restartGame();
  game.componentManager.resetComponents(
    player: game.player,
    activeObstacles: game.children.whereType<Obstacle>().toList(),
  );
  _calculateCurrentLevelScoreTarget(game);
  game.uiManager.updateTexts();
}

void _calculateCurrentLevelScoreTarget(NeuralBreakGame game) {
  game.currentLevelScoreTarget = game.scoreManager.calculateLevelScoreTarget(
    initialSpawnInterval: initialSpawnInterval,
    spawnIntervalDecreasePerLevel: spawnIntervalDecreasePerLevel,
    minSpawnInterval: minSpawnInterval,
    levelDuration: levelDuration,
    scorePerObstacle: scorePerObstacle,
  );
}
