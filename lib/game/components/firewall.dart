// lib/game/components/firewall.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:neural_break/game/components/obstacle.dart';
import 'package:neural_break/game/util/game_constants.dart';

class Firewall extends Obstacle {
  static final _firewallPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;

  Firewall({
    required Vector2 position,
    required Vector2 size,
    required Anchor anchor,
    required double obstacleSpeed,
  }) : super(
          position: position,
          size: size,
          anchor: anchor,
          obstacleSpeed: obstacleSpeed,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas); // ✅ preserve parent behavior
    canvas.drawRect(size.toRect(), _firewallPaint); // ✅ draw custom blue box
  }
}
