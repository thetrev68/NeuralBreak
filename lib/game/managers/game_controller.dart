import 'score_manager.dart';
import 'life_manager.dart';
import 'game_state_manager.dart';
import 'ui_manager.dart';

class GameController {
  final ScoreManager scoreManager;
  final LifeManager lifeManager;
  final GameStateManager gameStateManager;
  final UIManager uiManager;

  GameController({
    required this.scoreManager,
    required this.lifeManager,
    required this.gameStateManager,
    required this.uiManager,
  });

  void onPlayerHit() {
    lifeManager.loseLife();
    uiManager.updateTexts();
    if (lifeManager.isGameOver()) {
      gameStateManager.setGameOver();
    }
  }

  void onScore(int amount) {
    scoreManager.incrementScore(amount);
    uiManager.updateTexts();
    if (scoreManager.checkLevelUp()) {
      gameStateManager.setLevelUpPaused();
    }
  }

  void restartGame() {
    scoreManager.reset();
    lifeManager.reset();
    gameStateManager.setPlaying();
    uiManager.updateTexts();
  }
}
