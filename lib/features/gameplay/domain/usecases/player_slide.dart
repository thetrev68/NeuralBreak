// file: lib/features/gameplay/domain/usecases/player_slide.dart

// Flame package imports
import 'package:flame/components.dart';

// Project imports
import 'package:neural_break/core/constants/game_constants.dart';
import 'package:neural_break/features/gameplay/domain/usecases/player_jump.dart';

// Mixin for adding slide behavior to a Flame PositionComponent.
// This allows any component to have slide logic by simply mixing this in.
mixin PlayerSlide on PositionComponent {
  // Internal state: is the player currently sliding?
  bool _isSliding = false;

  // Timer to track remaining slide duration
  double _slideTimer = 0.0;

  // To remember the original (full standing) size before sliding
  late Vector2 _originalPlayerSize;

  // Public getter to check slide status
  bool get isSliding => _isSliding;

  // Called during component initialization (e.g., in onLoad)
  // Stores the initial size so we can revert after sliding ends
  void initializeSlide() {
    _originalPlayerSize = Vector2.copy(size);
  }

  // Begins the slide action
  // Player must be on the ground and not jumping to start a slide
  void slide() {
    final isJumping = this is PlayerJump && (this as PlayerJump).isJumping;
    final groundY =
        this is PlayerJump ? (this as PlayerJump).groundY : position.y;

    if (!_isSliding && !isJumping) {
      _isSliding = true;
      _slideTimer = slideDuration; // Set the countdown for how long to slide
      size.setValues(playerSlideWidth, playerSlideHeight); // Shrink the player
      position.y = groundY +
          _originalPlayerSize.y -
          size.y; // Adjust position to keep on ground
    }
  }

  // Updates the slide each frame
  // Ends the slide automatically when time runs out
  void updateSlide(double dt) {
    if (_isSliding) {
      _slideTimer -= dt; // Decrease the timer
      if (_slideTimer <= 0) {
        _isSliding = false;
        size.setFrom(_originalPlayerSize); // Restore original size
        final groundY =
            this is PlayerJump ? (this as PlayerJump).groundY : position.y;
        position.y = groundY; // Reset Y position back to ground level
      }
    }
  }

  // Reset slide state (used during full game reset)
  void resetSlide() => stopSlide();

  // Stop the slide immediately (e.g., when stopping all player actions)
  void stopSlide() {
    if (_isSliding) {
      size.setFrom(_originalPlayerSize); // Revert to original size
      final groundY =
          this is PlayerJump ? (this as PlayerJump).groundY : position.y;
      position.y = groundY; // Reset vertical position
    }
    _isSliding = false;
    _slideTimer = 0.0;
  }
}
