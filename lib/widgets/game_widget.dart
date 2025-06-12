import 'package:flutter/material.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/widgets/game_widget_wrapper.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget>
    with SingleTickerProviderStateMixin {
  late final NeuralBreakGame _game;

  @override
  void initState() {
    super.initState();
    _game = NeuralBreakGame(tickerProvider: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox.expand(
          child: KeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKeyEvent: (KeyEvent event) {
              // Forward keyboard events to your game if needed
            },
            child: GameWidgetWrapper(game: _game),
          ),
        ),
      ),
    );
  }
}
