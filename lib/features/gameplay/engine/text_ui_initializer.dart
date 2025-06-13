// File: lib/features/gameplay/engine/text_ui_initializer.dart

// Flame and Flutter packages
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports
import 'package:neural_break/core/constants/game_constants.dart';

// Relative imports
import 'package:neural_break/features/gameplay/engine/neural_break_game.dart';

Future<void> initializeUITextComponents(NeuralBreakGame game) async {
  // Score, Lives, Level
  final scoreTextComponent = TextComponent(
    text: 'Score: ${game.scoreManager.score}',
    position: Vector2(game.size.x / 2, 20),
    anchor: Anchor.topCenter,
    priority: 5,
    textRenderer: TextPaint(
      style: const TextStyle(fontSize: 20, color: Colors.white),
    ),
  );

  final livesTextComponent = TextComponent(
    text: 'Lives: ${game.lifeManager.lives}',
    position: Vector2(game.size.x - 20, 20),
    anchor: Anchor.topRight,
    priority: 5,
    textRenderer: TextPaint(
      style: const TextStyle(fontSize: 20, color: Colors.white),
    ),
  );

  final levelTextComponent = TextComponent(
    text: 'Level: ${game.scoreManager.level}',
    position: Vector2(20, 20),
    anchor: Anchor.topLeft,
    priority: 5,
    textRenderer: TextPaint(
      style: const TextStyle(fontSize: 20, color: Colors.white),
    ),
  );

  await game.addAll([
    scoreTextComponent,
    livesTextComponent,
    levelTextComponent,
  ]);

  if (kDebugMode) {
    print('NeuralBreakGame: UI Text Components added (STEP 14)');
  }

  game.uiManager.initializeTextComponents(
    scoreTextComponent,
    livesTextComponent,
    levelTextComponent,
  );

  if (kDebugMode) {
    print('NeuralBreakGame: UIManager text components initialized (STEP 15)');
  }

  // Level up message
  game.levelUpMessageText = TextComponent(
    text: levelUpMessage,
    position: game.size / 2,
    anchor: Anchor.center,
    priority: 10,
    textRenderer: TextPaint(
      style: const TextStyle(fontSize: 48, color: Colors.yellowAccent),
    ),
  );

  if (kDebugMode) {
    print('NeuralBreakGame: Level Up Message Text initialized (STEP 16)');
  }

  // Game over message
  game.gameOverText = TextComponent(
    text: gameOverMessage,
    anchor: Anchor.center,
    position: game.size / 2,
    priority: 10,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  if (kDebugMode) {
    print('NeuralBreakGame: Game Over Message Text initialized (STEP 17)');
  }
}
