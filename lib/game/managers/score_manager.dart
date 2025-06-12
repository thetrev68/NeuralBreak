// lib/game/managers/score_manager.dart
import 'package:flutter/foundation.dart'; // Import for ValueNotifier

class ScoreManager {
  // Change _score and _level to ValueNotifier
  final ValueNotifier<int> _score = ValueNotifier(0);
  final ValueNotifier<int> _level = ValueNotifier(1);
  final int levelUpThreshold;

  ScoreManager({this.levelUpThreshold = 100});

  // Expose ValueNotifier getters
  ValueNotifier<int> get scoreNotifier => _score;
  ValueNotifier<int> get levelNotifier => _level;

  // Keep plain getters for convenience within the game logic
  int get score => _score.value;
  int get level => _level.value;

  void reset() {
    _score.value = 0; // Update ValueNotifier's value
    _level.value = 1; // Update ValueNotifier's value
  }

  void incrementScore(int amount) {
    _score.value += amount; // Update ValueNotifier's value
  }

  bool checkLevelUp() {
    // Use .value for checking conditions
    if (_score.value >= _level.value * levelUpThreshold) {
      _level.value++; // Update ValueNotifier's value
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
    // Use .value for calculation
    final int currentLevel = _level.value;
    final int currentScore = _score.value;

    double spawnInterval = initialSpawnInterval -
        (currentLevel - 1) * spawnIntervalDecreasePerLevel;
    if (spawnInterval < minSpawnInterval) {
      spawnInterval = minSpawnInterval;
    }

    int estimatedObstacles = (levelDuration / spawnInterval).ceil();
    return currentScore + (estimatedObstacles * scorePerObstacle);
  }
}
