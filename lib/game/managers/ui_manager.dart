// lib/game/managers/ui_manager.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/managers/score_manager.dart';
import 'package:neural_break/game/managers/life_manager.dart';

class UIManager {
  final ScoreManager _scoreManager;
  final LifeManager _lifeManager;

  // These will hold references to the actual TextComponents from NeuralBreakGame
  late TextComponent _scoreTextComponent;
  late TextComponent _livesTextComponent;
  late TextComponent _levelTextComponent;

  UIManager({
    required ScoreManager scoreManager,
    required LifeManager lifeManager,
  })  : _scoreManager = scoreManager,
        _lifeManager = lifeManager;

  // Method called once from NeuralBreakGame.onLoad() to pass the TextComponent instances
  void initializeTextComponents(
      TextComponent scoreText,
      TextComponent livesText,
      TextComponent levelText) {
    _scoreTextComponent = scoreText;
    _livesTextComponent = livesText;
    _levelTextComponent = levelText;
  }

  // Method to update the text content of the UI components
  void updateTexts() {
    _scoreTextComponent.text = 'Score: ${_scoreManager.score}';
    _livesTextComponent.text = 'Lives: ${_lifeManager.lives}';
    _levelTextComponent.text = 'Level: ${_scoreManager.level}';
  }
}