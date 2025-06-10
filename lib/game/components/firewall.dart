// Core Flame and Flutter imports
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// Base obstacle class that Firewall extends
import 'package:neural_break/game/components/obstacle.dart';

/// A visual variant of the Obstacle component.
/// Inherits all obstacle behavior, but uses a blue paint instead of red.
class Firewall extends Obstacle {
  // Custom paint object for drawing a blue firewall
  static final _firewallPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;

  /// Constructor passes all parameters up to the Obstacle superclass.
  Firewall({
    required Vector2 super.position,     // Start position in the game world
    required Vector2 super.size,         // Width and height
    required Anchor super.anchor,        // Anchor point (usually center)
    required super.obstacleSpeed,        // Speed at which it moves down
  });

  /// Custom rendering logic: draws a blue rectangle over the default one
  @override
  void render(Canvas canvas) {
    super.render(canvas); // Retain the obstacle’s default render logic (which may include debug elements)
    canvas.drawRect(size.toRect(), _firewallPaint); // Overlay a blue rectangle
  }
}
