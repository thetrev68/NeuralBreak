class LifeManager {
  int _lives;
  final int initialLives;

  LifeManager({this.initialLives = 3}) : _lives = initialLives;

  int get lives => _lives;

  void reset() {
    _lives = initialLives;
  }

  void loseLife() {
    if (_lives > 0) {
      _lives--;
    }
  }

  bool isGameOver() => _lives <= 0;
}
