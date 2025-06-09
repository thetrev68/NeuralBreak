// lib/game/components/player_jump.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';

// This mixin adds jumping capabilities to a PositionComponent.
// It requires the component to have a reference to NeuralBreakGame and control over its position.
mixin PlayerJump on PositionComponent, HasGameReference<NeuralBreakGame> { // Correct: Use 'on' for HasGameReference
  // Properties for jump state and physics
  double _yVelocity = 0.0;
  bool _isJumping = false;
  double _groundY = 0.0;

  // Public getter to expose the groundY to other mixins/classes that need it.
  double get groundY => _groundY;

  // Public getter to expose the jump state (for PlayerSlide)
  bool get isJumping => _isJumping;

  // This method should be called once from the Player's onLoad to set the initial ground level.
  void initializeJump() {
    _groundY = position.y;
  }

  // Call this to initiate a jump
  void applyJump() {
    if (!_isJumping) {
      _isJumping = true;
      _yVelocity = -playerJumpForce;
    } else {
      // Nothing to do if already jumping
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
        position.y = _groundY;
        _isJumping = false;
        _yVelocity = 0.0;
      }
    }
  }

  // Resets jump state for a new game
  void resetJump() {
    _yVelocity = 0.0;
    _isJumping = false;
    position.y = _groundY;
  }

  // Stops any ongoing jump (e.g., on game over)
  void stopJump() {
    _isJumping = false;
    _yVelocity = 0.0;
  }
}