class ScoreManager {
  int _score = 0;
  int _level = 1;
  final int levelUpThreshold;

  ScoreManager({this.levelUpThreshold = 100});

  int get score => _score;
  int get level => _level;

  void reset() {
    _score = 0;
    _level = 1;
  }

  void incrementScore(int amount) {
    _score += amount;
  }

  bool checkLevelUp() {
    if (_score >= _level * levelUpThreshold) {
      _level++;
      return true;
    }
    return false;
  }
}
