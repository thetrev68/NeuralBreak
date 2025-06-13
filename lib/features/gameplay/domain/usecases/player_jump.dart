// file: lib/features/gameplay/domain/usecases/player_jump.dart

// Flame package imports
import 'package:flame/components.dart';

// Project imports
import 'package:neural_break/core/constants/game_constants.dart';
import 'package:neural_break/features/gameplay/domain/usecases/player_slide.dart';

// Mixin to add jump capability to a PositionComponent.
// Requires the base class to include `HasGameReference<NeuralBreakGame>`.
mixin PlayerJump on PositionComponent {
  // Vertical velocity used in jumping physics
  double _velocityY = 0.0;

  // Is the component currently in the air?
  bool _isJumping = false;

  // Y-position representing the ground level (starting point for jumps)
  late double _groundY;

  // Public getter to check if the component is currently jumping
  bool get isJumping => _isJumping;

  // Getter to expose the ground Y-value
  double get groundY => _groundY;

  // Called during component initialization (e.g., onLoad)
  // Records the starting Y position as the "ground" level
  void initializeJump() {
    _groundY = position.y;
  }

  // Attempts to trigger a jump
  // Will not jump if already in the air or if currently sliding
  void jump() {
    if (_isJumping) return;

    // If also using PlayerSlide, check to prevent jumping while sliding
    final isSliding = this is PlayerSlide && (this as PlayerSlide).isSliding;
    if (!isSliding) {
      _isJumping = true;
      _velocityY = -playerJumpForce; // Set upward velocity
    }
  }

  // Called every frame to apply gravity and update vertical position
  void updateJump(double dt) {
    if (!_isJumping) return;

    _velocityY += gravity * dt; // Apply gravity to velocity
    position.y += _velocityY * dt; // Move component vertically

    // If we've landed (or overshot), reset position and stop jumping
    if (position.y >= _groundY) {
      position.y = _groundY;
      _isJumping = false;
      _velocityY = 0.0;
    }
  }

  // Resets jump-related state and places the component back on the ground
  void resetJump() {
    _isJumping = false;
    _velocityY = 0.0;
    position.y = _groundY;
  }

  // Stops the jump in progress (used to cancel actions)
  void stopJump() {
    _isJumping = false;
    _velocityY = 0.0;
    position.y = _groundY;
  }
}
