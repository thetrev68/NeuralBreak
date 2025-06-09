// lib/game/components/player_slide.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/components/player_jump.dart';

// This mixin adds sliding (ducking) capabilities to a PositionComponent.
// It requires the component to have a reference to NeuralBreakGame and control over its size and position.
// It also explicitly requires PlayerJump to access the groundY and isJumping properties.
mixin PlayerSlide on PositionComponent, HasGameReference<NeuralBreakGame>, PlayerJump { // Correct: Use 'on' for HasGameReference
  // Flag to track if the player is currently sliding.
  bool _isSliding = false;
  // Timer to manage the duration of the slide.
  double _slideTimer = 0.0;
  // Store the original player size to revert after sliding.
  late Vector2 _originalPlayerSize;

  // Public getter to expose _isSliding state (for Player's reset/stop actions)
  bool get isSliding => _isSliding;

  // This method should be called once from the Player's onLoad to set the initial size.
  void initializeSlide() {
    _originalPlayerSize = Vector2.copy(size);
  }

  // Call this to initiate a slide.
  void applySlide() {
    // Only allow sliding if not already sliding or jumping.
    // Access `isJumping` and `groundY` directly since PlayerSlide now `on` PlayerJump.
    if (!_isSliding && !isJumping) {
      _isSliding = true;
      _slideTimer = slideDuration;
      // Adjust the player's size to simulate a slide/duck.
      size.setValues(playerSlideWidth, playerSlideHeight);
      // Adjust position to keep the bottom of the player at the same Y-level.
      // This makes the slide look like the player is ducking down, not moving upwards.
      position.y = groundY + _originalPlayerSize.y - size.y;
    } else {
      // Cannot slide, already sliding or jumping.
    }
  }

  // Call this from the Player's update method to handle slide timing.
  void updateSlide(double dt) {
    if (_isSliding) {
      _slideTimer -= dt;
      if (_slideTimer <= 0) {
        // If the timer runs out, end the slide.
        _isSliding = false;
        // Revert player size back to original.
        size.setValues(_originalPlayerSize.x, _originalPlayerSize.y);
        // Revert player position back to original ground Y.
        position.y = groundY;
      }
    }
  }

  // Public method to reset slide state
  void resetSlide() {
    if (_isSliding) {
      size.setValues(_originalPlayerSize.x, _originalPlayerSize.y);
      position.y = groundY;
    }
    _isSliding = false;
    _slideTimer = 0.0;
  }

  // Public method to stop current slide (e.g., on game over)
  void stopSlide() {
    if (_isSliding) {
      size.setValues(_originalPlayerSize.x, _originalPlayerSize.y);
      position.y = groundY;
    }
    _isSliding = false;
    _slideTimer = 0.0;
  }
}