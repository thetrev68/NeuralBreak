// file: lib/features/gameplay/domain/usecases/input_manager.dart

// Flutter package imports
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Project imports
import 'package:neural_break/features/gameplay/domain/entities/player.dart';

class InputManager {
  InputManager();

  // This method handles keyboard input and delegates actions to the player.
  KeyEventResult handleKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed, Player player) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        player.moveLeft();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        player.moveRight();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.space)) {
        player.applyJump();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
          keysPressed.contains(LogicalKeyboardKey.controlRight)) {
        player.applySlide();
        return KeyEventResult.handled;
      }
    }
    // Corrected: Use KeyEventResult.ignored instead of KeyEventResult.notHandled
    return KeyEventResult.ignored;
  }
}
