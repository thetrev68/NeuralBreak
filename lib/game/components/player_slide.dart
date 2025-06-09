// lib/game/components/player_slide.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/components/player_jump.dart';

/// Mixin for adding slide behavior to a Flame PositionComponent.
mixin PlayerSlide on PositionComponent {
  bool _isSliding = false;
  double _slideTimer = 0.0;
  late Vector2 _originalPlayerSize;

  bool get isSliding => _isSliding;

  void initializeSlide() {
    _originalPlayerSize = Vector2.copy(size);
  }

  void slide() {
    final isJumping = this is PlayerJump && (this as PlayerJump).isJumping;
    final groundY = this is PlayerJump ? (this as PlayerJump).groundY : position.y;

    if (!_isSliding && !isJumping) {
      _isSliding = true;
      _slideTimer = slideDuration;
      size.setValues(playerSlideWidth, playerSlideHeight);
      position.y = groundY + _originalPlayerSize.y - size.y;
    }
  }

  void updateSlide(double dt) {
    if (_isSliding) {
      _slideTimer -= dt;
      if (_slideTimer <= 0) {
        _isSliding = false;
        size.setFrom(_originalPlayerSize);
        final groundY = this is PlayerJump ? (this as PlayerJump).groundY : position.y;
        position.y = groundY;
      }
    }
  }

  void resetSlide() => stopSlide();
  void stopSlide() {
    if (_isSliding) {
      size.setFrom(_originalPlayerSize);
      final groundY = this is PlayerJump ? (this as PlayerJump).groundY : position.y;
      position.y = groundY;
    }
    _isSliding = false;
    _slideTimer = 0.0;
  }
}
