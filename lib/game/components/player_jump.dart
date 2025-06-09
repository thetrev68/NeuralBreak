// lib/game/components/player_jump.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';

// This mixin adds jumping capabilities to a PositionComponent.
// It requires the component to have a reference to NeuralBreakGame and control over its position.
mixin PlayerJump on PositionComponent implements HasGameRef<NeuralBreakGame> {
  // Properties for jump state and physics
  double _yVelocity = 0.0;
  bool _isJumping = false;
  double _groundY = 0.0; // The Y position where the player is considered "grounded"

  // Public getter to expose the groundY to other mixins/classes that need it.
  double get groundY => _groundY;

  // This method should be called once from the Player's onLoad to set the initial ground level.
  void initializeJump() {
    _groundY = position.y; // The initial Y position is our ground
  }

  // Call this to initiate a jump
  void applyJump() {
    if (!_isJumping) { // Only jump if not already in the air
      _isJumping = true;
      _yVelocity = -playerJumpForce; // Negative for upward movement (Flame's Y is inverted)
      print('Jump applied! Initial Y velocity: $_yVelocity');
    } else {
      print('Cannot jump, already in air.');
    }
  }

  // Call this from the Player's update method to handle jump physics each frame
  void updateJump(double dt) {
    if (_isJumping) {
      // Apply gravity
      _yVelocity += gravity * dt;
      position.y += _yVelocity * dt;

      // Check if player has landed
      if (position.y >= _groundY) {
        position.y = _groundY; // Snap to ground
        _isJumping = false;
        _yVelocity = 0.0;
        print('Player landed. Current Y: ${position.y.toStringAsFixed(2)}');
      }
    }
  }

  // You might need a getter for _isJumping if other parts of the game
  // need to know if the player is in the air (e.g., for animations).
  bool get isJumping => _isJumping;
}