// lib/game/components/player_jump.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/components/player_slide.dart';
import 'package:flame/game.dart';

/// Mixin to add jump capability to a PositionComponent.
/// Requires `HasGameRef<NeuralBreakGame>` in the base class.
mixin PlayerJump on PositionComponent {
  double _velocityY = 0.0;
  bool _isJumping = false;
  late double _groundY;

  bool get isJumping => _isJumping;
  double get groundY => _groundY;

  void initializeJump() {
    _groundY = position.y;
  }

  void jump() {
    if (_isJumping) return;

    final isSliding = this is PlayerSlide && (this as PlayerSlide).isSliding;
    if (!isSliding) {
      _isJumping = true;
      _velocityY = -playerJumpForce;
    }
  }

  void updateJump(double dt) {
    if (!_isJumping) return;

    _velocityY += gravity * dt;
    position.y += _velocityY * dt;

    if (position.y >= _groundY) {
      position.y = _groundY;
      _isJumping = false;
      _velocityY = 0.0;
    }
  }

  void resetJump() {
    _isJumping = false;
    _velocityY = 0.0;
    position.y = _groundY;
  }

  void stopJump() {
    _isJumping = false;
    _velocityY = 0.0;
    position.y = _groundY;
  }
}
