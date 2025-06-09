// lib/game/components/firewall.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:neural_break/game/components/obstacle.dart';
import 'package:neural_break/game/util/game_constants.dart';

// Represents a Firewall obstacle that the player must avoid by changing lanes or jumping over.
class Firewall extends Obstacle {
  // A specific paint for Firewall obstacles.
  static final _firewallPaint = Paint()
    ..color = Colors.blue // Firewalls can be blue
    ..style = PaintingStyle.fill;

  Firewall({
    required GameLane lane, // The lane in which this firewall will appear
    required double gameWidth, // The width of the game area
    required double obstacleSpeed, // NEW: Pass obstacle speed to constructor
  }) : super(
          // Pass the obstacleSpeed to the super (Obstacle) constructor
          obstacleSpeed: obstacleSpeed, // NEW: Pass the speed
          // Set the initial size of the firewall.
          // It will span the width of a lane and have a fixed height.
          size: Vector2(gameWidth / 3, 60.0), // Firewall takes up one lane width
          // Set the initial position:
          // X: Calculated based on the lane.
          // Y: Starts just off the top of the screen to move downwards.
          // Since anchor is Anchor.center, subtract half its height to place its top edge at Y=0,
          // then subtract its full height to start completely above the screen.
          position: Vector2(getLaneX(lane, gameWidth), -60.0), // Starts just above the top of the screen
          anchor: Anchor.center, // Anchor at the center for easier positioning
        );

  @override
  void render(Canvas canvas) {
    // Override the render method to use the specific firewall paint.
    canvas.drawRect(size.toRect(), _firewallPaint);
  }
}