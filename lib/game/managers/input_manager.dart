import 'package:flame/events.dart';
import 'package:flutter/services.dart';

class InputManager {
  final void Function() onTapAction;
  final void Function() onRestart;

  InputManager({
    required this.onTapAction,
    required this.onRestart,
  });

  void handleTap(TapDownEvent event) {
    onTapAction();
  }

  void handleKeyboard(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.space) {
      onRestart();
    }
  }
}
