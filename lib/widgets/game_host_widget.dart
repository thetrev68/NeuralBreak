import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:neural_break/game/neural_break_game.dart';

class GameHostWidget extends StatefulWidget {
  const GameHostWidget({super.key});

  @override
  State<GameHostWidget> createState() => _GameHostWidgetState();
}

class _GameHostWidgetState extends State<GameHostWidget>
    with SingleTickerProviderStateMixin {
  late final NeuralBreakGame game;

  @override
  void initState() {
    super.initState();
    game = NeuralBreakGame(tickerProvider: this);
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}
