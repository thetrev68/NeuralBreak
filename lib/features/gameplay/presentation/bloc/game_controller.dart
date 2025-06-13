// File: lib/features/gameplay/presentation/bloc/game_controller.dart

// Project imports
import 'package:neural_break/features/gameplay/domain/usecases/input_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/life_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/score_manager.dart';
import 'package:neural_break/features/gameplay/presentation/bloc/game_state_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/ui_manager.dart';

class GameController {
  final ScoreManager scoreManager;
  final LifeManager lifeManager;
  final GameStateManager gameStateManager;
  final UIManager uiManager;
  final InputManager inputManager; // <-- New: Add InputManager field

  GameController({
    required this.scoreManager,
    required this.lifeManager,
    required this.gameStateManager,
    required this.uiManager,
    required this.inputManager, // <-- New: Add InputManager to constructor
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
      // No direct call to _levelUp() from here; NeuralBreakGame will handle component-specific parts
    }
  }

  void restartGame() {
    scoreManager.reset();
    lifeManager.reset();
    gameStateManager.setPlaying();
    uiManager.updateTexts();
    // NeuralBreakGame will handle componentManager.resetComponents() and
    // _calculateCurrentLevelScoreTarget() if they are part of _restartGame()
  }

  /// Handles the common effects that happen when a level up occurs.
  /// Does NOT handle component-specific actions (like removing obstacles or stopping player).
  void handleLevelUpEffects() {
    uiManager.updateTexts(); // Update score, lives, level display
    // The obstacle spawner difficulty increase needs the current level from ScoreManager.
    // We cannot increase difficulty here, as obstacleSpawner is not a manager to GameController.
    // This will stay in NeuralBreakGame or passed if a GameController.onLevelUp() takes obstacleSpawner.
  }

  /// Continues the game after a level-up pause.
  /// This method is for orchestrating state and UI changes, not direct component manipulation.
  void continueGameAfterLevelUp() {
    gameStateManager.setPlaying(); // Set game state back to playing
    // The part about removing _levelUpMessageText and resetting player/spawner
    // will be handled in NeuralBreakGame's _continueGameAfterLevelUp()
  }
}
