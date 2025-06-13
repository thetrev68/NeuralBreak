// Flame and Flutter packages
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// Project imports
import 'package:neural_break/core/constants/game_constants.dart';
import 'package:neural_break/features/gameplay/domain/usecases/life_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/score_manager.dart';
import 'package:neural_break/features/gameplay/presentation/components/ui_manager.dart'; // Ensure UIManager is passed if needed for avatar
import 'package:neural_break/features/gameplay/presentation/widgets/avatars/avatar_display_widget.dart';

class GameOverlayWidget extends StatelessWidget {
  final ScoreManager scoreManager;
  final LifeManager lifeManager;
  final UIManager uiManager; // Pass if needed for AvatarDisplayWidget
  final Vector2 gameSize; // Pass the game size for responsive positioning

  const GameOverlayWidget({
    super.key,
    required this.scoreManager,
    required this.lifeManager,
    required this.uiManager,
    required this.gameSize,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate positions based on gameSize
    final double textPadding = gameSize.y * 0.03;
    final double horizontalMargin = gameSize.x * 0.05;
    final double fontSize = gameSize.y * 0.05;

    // Player avatar positioning
    // Assuming getGroundY is accessible, perhaps in game_constants.dart or passed here
    final double playerGameY = getGroundY(gameSize.y, playerSize);
    final double avatarWidgetBottomPadding =
        (gameSize.y - playerGameY) - (playerSize / 2);
    final double avatarWidgetLeft = (gameSize.x / 2) - (playerSize * 0.8 / 2);

    return Stack(
      children: [
        // Avatar Display
        Positioned(
          bottom: avatarWidgetBottomPadding,
          left: avatarWidgetLeft,
          child: AvatarDisplayWidget(
            uiManager: uiManager,
            avatarSize: playerSize,
          ),
        ),
        // Score Text
        Positioned(
          top: textPadding,
          left: horizontalMargin,
          child: ValueListenableBuilder<int>(
            valueListenable: scoreManager.scoreNotifier,
            builder: (_, score, __) => Text(
              'Score: $score',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
        // Lives Text
        Positioned(
          top: textPadding,
          right: horizontalMargin,
          child: ValueListenableBuilder<int>(
            valueListenable: lifeManager.livesNotifier,
            builder: (_, lives, __) => Text(
              'Lives: $lives',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
        // Level Text
        Positioned(
          top: textPadding,
          left: (gameSize.x / 2) - 50, // Center roughly
          child: ValueListenableBuilder<int>(
            valueListenable: scoreManager.levelNotifier,
            builder: (_, level, __) => Text(
              'Level: $level',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
