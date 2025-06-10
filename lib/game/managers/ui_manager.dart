import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'score_manager.dart';
import 'life_manager.dart';

class UIManager {
  final ScoreManager scoreManager;
  final LifeManager lifeManager;

  final TextComponent scoreText;
  final TextComponent livesText;
  final TextComponent levelText;

  UIManager({
    required this.scoreManager,
    required this.lifeManager,
    required Vector2 position,
  })  : scoreText = TextComponent(
          text: 'Score: ${scoreManager.score}',
          position: position.clone(),
          textRenderer: TextPaint(
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        livesText = TextComponent(
          text: 'Lives: ${lifeManager.lives}',
          position: position + Vector2(0, 30),
          textRenderer: TextPaint(
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        levelText = TextComponent(
          text: 'Level: ${scoreManager.level}',
          position: position + Vector2(0, 60),
          textRenderer: TextPaint(
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        );

  List<TextComponent> get textComponents => [scoreText, livesText, levelText];

  void updateTexts() {
    scoreText.text = 'Score: ${scoreManager.score}';
    livesText.text = 'Lives: ${lifeManager.lives}';
    levelText.text = 'Level: ${scoreManager.level}';
  }
}
