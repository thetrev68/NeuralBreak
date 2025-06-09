// lib/game/components/firewall.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart'; // New import for RectangleHitbox

import 'package:neural_break/game/components/obstacle.dart';
import 'package:neural_break/game/util/game_constants.dart';

// Represents a Firewall obstacle that the player must avoid by changing lanes or jumping over.
class Firewall extends Obstacle with CollisionCallbacks { // Added CollisionCallbacks
  // A specific paint for Firewall obstacles.
  static final _firewallPaint = Paint()
    ..color = Colors.blue // Firewalls can be blue
    ..style = PaintingStyle.fill;

  Firewall({
    required GameLane lane, // The lane in which this firewall will appear
    required double gameWidth, // The width of the game area
  }) : super(
          // Set the initial size of the firewall.
          size: Vector2(gameWidth / 3, 60.0),
          // Set the initial position:
          position: Vector2(getLaneX(lane, gameWidth), -60.0),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox()); // Add a hitbox for collision detection
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _firewallPaint);
  }
}