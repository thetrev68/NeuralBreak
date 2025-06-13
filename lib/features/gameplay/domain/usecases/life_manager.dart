// lib/game/managers/life_manager.dart
import 'package:flutter/foundation.dart'; // Import for ValueNotifier

class LifeManager {
  // Change _lives to ValueNotifier
  final ValueNotifier<int> _lives;
  final int initialLives; // Keep initialLives as a regular field

  LifeManager({this.initialLives = 3}) : _lives = ValueNotifier(initialLives);

  // Expose ValueNotifier getter for UI listening
  ValueNotifier<int> get livesNotifier => _lives;

  // Keep plain getter for convenience within game logic
  int get lives => _lives.value;

  void reset() {
    _lives.value = initialLives; // Update ValueNotifier's value
  }

  void loseLife() {
    if (_lives.value > 0) {
      // Use .value for checking condition
      _lives.value--; // Update ValueNotifier's value
    }
  }

  bool isGameOver() => _lives.value <= 0; // Use .value for checking condition
}
