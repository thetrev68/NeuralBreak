import 'package:neural_break/core/constants/game_states.dart';

class GameStateManager {
  GameState _state = GameState.playing;

  // Renamed the getter from 'state' to 'currentGameState' for consistency
  // with how it's being accessed in NeuralBreakGame and ObstacleSpawner.
  GameState get currentGameState => _state;

  void setPlaying() {
    _state = GameState.playing;
  }

  void setGameOver() {
    _state = GameState.gameOver;
  }

  void setLevelUpPaused() {
    _state = GameState.levelUpPaused;
  }

  bool isPlaying() => _state == GameState.playing;
  bool isGameOver() => _state == GameState.gameOver;
  bool isLevelUpPaused() => _state == GameState.levelUpPaused;
}
