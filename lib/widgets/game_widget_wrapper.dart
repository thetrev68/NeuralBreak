import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class GameWidgetWrapper extends StatelessWidget {
  final FlameGame game;

  const GameWidgetWrapper({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}
