// Importing necessary Flame and Flutter modules
import 'package:flame/components.dart';      // Base Flame components
import 'package:flutter/material.dart';      // For colors, paint, canvas drawing
import 'package:flame/collisions.dart';      // Hitbox and collision handling

// Importing game-specific modules
import 'package:neural_break/game/neural_break_game.dart';      // Reference to the main game class
import 'package:neural_break/game/util/game_constants.dart';    // Constants like `playerSize`
import 'package:neural_break/game/components/player_movement.dart'; // Mixin for movement logic
import 'package:neural_break/game/components/player_jump.dart';     // Mixin for jumping logic
import 'package:neural_break/game/components/player_slide.dart';    // Mixin for sliding logic
import 'package:neural_break/game/components/obstacle.dart';        // Obstacle class used in collision

// Main Player class
class Player extends PositionComponent
    with
        HasGameReference<NeuralBreakGame>, // Provides access to gameRef, the main game instance
        CollisionCallbacks,          // Enables collision detection
        PlayerMovement,              // Adds movement behavior
        PlayerJump,                  // Adds jump behavior
        PlayerSlide {                // Adds slide behavior

  // Paint object used to draw the player
  static final _playerPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  // Constructor sets player size and anchor point
  Player()
      : super(
          size: Vector2(playerSize, playerSize), // Sets width and height of the player
          anchor: Anchor.center,                // Anchors the position at the center of the component
        );

  // Called when the component is added to the game
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    initializeMovement(); // Initialize movement variables and states
    position.y = game.size.y - size.y * 2; // Start player near the bottom of the screen

    initializeJump();   // Setup for jumping logic
    initializeSlide();  // Setup for sliding logic

    add(RectangleHitbox()); // Adds a rectangular collision box to the player
  }

  // Called every frame to update player logic
  @override
  void update(double dt) {
    super.update(dt);
    updateMovement(dt); // Update position and speed
    updateJump(dt);     // Update jump mechanics
    updateSlide(dt);    // Update slide state
  }

  // Draws the player on the screen
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _playerPaint); // Renders a filled white square
  }

  // Called when player starts colliding with another component
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other); // Ensure parent class behavior runs
    if (other is Obstacle) {
      game.loseLife(); // Player loses a life when hitting an obstacle
    }
  }

  // Resets all player states and positions
  void reset() {
    resetMovement();  // Reset movement-related properties
    resetJump();      // Reset jumping state
    resetSlide();     // Reset sliding state
    position.y = game.size.y - size.y * 2; // Reposition at starting Y
  }

  // Stops all ongoing player actions (e.g., for pausing or death)
  void stopAllActions() {
    stopMovement();
    stopJump();
    stopSlide();
  }

  // Triggers the jump action
  void applyJump() {
    jump();
  }

  // Triggers the slide action
  void applySlide() {
    slide();
  }
}