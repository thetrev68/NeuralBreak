// lib/game/neural_break_game.dart
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'package:neural_break/game/components/player.dart';
import 'package:neural_break/game/components/obstacle_spawner.dart'; // Import the new spawner
import 'package:neural_break/game/util/game_constants.dart';

class NeuralBreakGame extends FlameGame with TapCallbacks {
  late final Player player;
  late final ObstacleSpawner obstacleSpawner; // Declare the spawner

  @override
  Color backgroundColor() => Colors.black;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = Player();
    add(player);

    obstacleSpawner = ObstacleSpawner(); // Initialize the spawner
    add(obstacleSpawner); // Add the spawner to the game

    print('NeuralBreakGame loaded and Player and ObstacleSpawner added!');
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapX = event.canvasPosition.x;
    final tapY = event.canvasPosition.y;
    final playerCenterX = player.position.x;
    final playerCenterY = player.position.y;

    final jumpZoneLeft = playerCenterX - (jumpTapZoneWidth / 2);
    final jumpZoneRight = playerCenterX + (jumpTapZoneWidth / 2);

    final slideZoneTop = playerCenterY + player.size.y / 2;
    final slideZoneBottom = slideZoneTop + slideTapZoneHeight;

    if (tapX >= jumpZoneLeft && tapX <= jumpZoneRight && tapY < playerCenterY) {
      player.applyJump();
      print('Jump tap detected. Player Y: ${player.position.y.toStringAsFixed(2)}');
    } else if (tapX >= jumpZoneLeft && tapX <= jumpZoneRight && tapY > slideZoneTop && tapY < slideZoneBottom) {
      player.applySlide();
      print('Slide tap detected. Player Y: ${player.position.y.toStringAsFixed(2)}');
    } else if (tapX < playerCenterX) {
      player.moveLeft();
      print('Move Left tap detected. Player X: ${player.position.x.toStringAsFixed(2)}');
    } else {
      player.moveRight();
      print('Move Right tap detected. Player X: ${player.position.x.toStringAsFixed(2)}');
    }
  }
}