import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:neural_break/features/gameplay/presentation/pages/neural_break_game.dart';
import 'package:neural_break/features/gameplay/presentation/components/ui_manager.dart';
import 'package:neural_break/widgets/avatars/avatar_display_widget.dart';

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
