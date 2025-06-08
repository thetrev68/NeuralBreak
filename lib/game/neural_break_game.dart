// lib/game/neural_break_game.dart
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'package:neural_break/game/components/player.dart';
import 'package:neural_break/game/util/game_constants.dart'; // Import constants for jumpTapZoneWidth

class NeuralBreakGame extends FlameGame with TapCallbacks {
  late final Player player;

  @override
  Color backgroundColor() => Colors.black;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = Player();
    add(player);

    print('NeuralBreakGame loaded and Player added!');
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapX = event.canvasPosition.x;
    final playerCenterX = player.position.x;

    // Calculate the left and right boundaries of the jump tap zone
    final jumpZoneLeft = playerCenterX - (jumpTapZoneWidth / 2);
    final jumpZoneRight = playerCenterX + (jumpTapZoneWidth / 2);

    if (tapX >= jumpZoneLeft && tapX <= jumpZoneRight) {
      // Tapped within the horizontal zone above the player (jump area)
      player.applyJump();
      print('Jump tap detected. Player Y: ${player.position.y.toStringAsFixed(2)}');
    } else if (tapX < playerCenterX) {
      // Tapped to the left of the player's center (move left area)
      player.moveLeft();
      print('Move Left tap detected. Player X: ${player.position.x.toStringAsFixed(2)}');
    } else {
      // Tapped to the right of the player's center (move right area)
      player.moveRight();
      print('Move Right tap detected. Player X: ${player.position.x.toStringAsFixed(2)}');
    }
  }
}