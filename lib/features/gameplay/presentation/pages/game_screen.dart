// file: lib/features/gameplay/presentation/pages/game_screen.dart

// Flame and Flutter packages
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// Project imports
import 'package:neural_break/features/gameplay/engine/neural_break_game.dart';
import 'package:neural_break/features/gameplay/presentation/components/ui_manager.dart';
import 'package:neural_break/features/gameplay/presentation/widgets/avatars/avatar_display_widget.dart';

class GameScreen extends StatefulWidget {
  final NeuralBreakGame game;
  final UIManager uiManager;

  const GameScreen({super.key, required this.game, required this.uiManager});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(game: widget.game),
        Positioned(
          left: 20,
          bottom: 50,
          child: AvatarDisplayWidget(uiManager: widget.uiManager),
        ),
      ],
    );
  }
}
