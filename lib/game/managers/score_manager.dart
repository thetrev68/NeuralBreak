// In lib/game/managers/score_manager.dart
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

  /// Calculates the score target for the current level based on game constants.
  int calculateLevelScoreTarget({
    required double initialSpawnInterval,
    required double spawnIntervalDecreasePerLevel,
    required double minSpawnInterval,
    required double levelDuration,
    required int scorePerObstacle,
  }) {
    // Use internal _level and _score for calculation
    final int currentLevel = _level;
    final int currentScore = _score;

    double spawnInterval = initialSpawnInterval - (currentLevel - 1) * spawnIntervalDecreasePerLevel;
    if (spawnInterval < minSpawnInterval) {
      spawnInterval = minSpawnInterval;
    }

    int estimatedObstacles = (levelDuration / spawnInterval).ceil();
    return currentScore + (estimatedObstacles * scorePerObstacle);
  }
}