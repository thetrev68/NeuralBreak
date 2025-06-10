enum GameState { playing, gameOver, levelUpPaused }

class GameStateManager {
  GameState _state = GameState.playing;

  GameState get state => _state;

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
