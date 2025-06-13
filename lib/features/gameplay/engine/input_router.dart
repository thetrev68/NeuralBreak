// File: lib/features/gameplay/engine/input_router.dart

// Flame and Flutter packages
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports
import 'package:neural_break/core/constants/game_constants.dart';
import 'package:neural_break/core/constants/game_states.dart';
import 'package:neural_break/features/gameplay/engine/game_logic_helpers.dart';

// Relative imports
import '../engine/neural_break_game.dart';

KeyEventResult forwardKeyEventToInputManager(
  NeuralBreakGame game,
  KeyEvent event,
  Set<LogicalKeyboardKey> keysPressed,
) {
  // Delegate input handling to InputManager
  final result =
      game.inputManager.handleKeyEvent(event, keysPressed, game.player);

  // If our input manager handled it, return that result.
  // Otherwise, allow default Flame behavior to process it.
  return result;
}

void forwardTapEventToGame(NeuralBreakGame game, TapDownEvent event) {
  // If game is over, tap to restart
  if (game.gameStateManager.currentGameState == GameState.gameOver) {
    if (game.contains(game.gameOverText)) {
      game.remove(game.gameOverText);
    }
    restartGame(game);
  }

  // If game is paused for level up, tap to continue
  else if (game.gameStateManager.currentGameState == GameState.levelUpPaused) {
    if (game.contains(game.levelUpMessageText)) {
      game.remove(game.levelUpMessageText);
    }
    continueGameAfterLevelUp(game);
  }

  // Handle in-game tap logic only when playing
  else if (game.gameStateManager.currentGameState == GameState.playing) {
    final tapX = event.canvasPosition.x;
    final tapY = event.canvasPosition.y;
    final playerCenterX = game.player.position.x;
    final playerCenterY = game.player.position.y;

    final jumpZoneLeft = playerCenterX - (jumpTapZoneWidth / 2);
    final jumpZoneRight = playerCenterX + (jumpTapZoneWidth / 2);
    final slideZoneTop = playerCenterY + game.player.size.y / 2;
    final slideZoneBottom = slideZoneTop + slideTapZoneHeight;

    if (tapX >= jumpZoneLeft && tapX <= jumpZoneRight && tapY < playerCenterY) {
      game.player.applyJump();
    } else if (tapX >= jumpZoneLeft &&
        tapX <= jumpZoneRight &&
        tapY > slideZoneTop &&
        tapY < slideZoneBottom) {
      game.player.applySlide();
    } else if (tapX < playerCenterX) {
      game.player.moveLeft();
    } else if (tapX > playerCenterX) {
      game.player.moveRight();
    }
  }
}
