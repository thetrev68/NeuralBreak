// lib/game/components/player_movement.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:flame/game.dart';

/// Adds horizontal lane-based movement to the component.
/// Expects the base class to mix in HasGameRef<NeuralBreakGame>.
mixin PlayerMovement on PositionComponent {
  double _internalTargetX = 0.0;
  double get targetX => _internalTargetX;

  GameLane _currentLane = GameLane.center;

  void initializeMovement() {
    final game = (this as HasGameRef<NeuralBreakGame>).gameRef;
    _internalTargetX = getLaneX(_currentLane, game.size.x);
    position.x = _internalTargetX;
  }

  void updateMovement(double dt) {
    final deltaX = _internalTargetX - position.x;
    if (deltaX.abs() > 0.1) {
      final step = playerMoveSpeed * dt;
      position.x += deltaX.abs() < step ? deltaX : deltaX.sign * step;
    }
  }

  void moveLeft() {
    switch (_currentLane) {
      case GameLane.center:
        _currentLane = GameLane.left;
        break;
      case GameLane.right:
        _currentLane = GameLane.center;
        break;
      case GameLane.left:
        break;
    }
    _updateTargetX();
  }

  void moveRight() {
    switch (_currentLane) {
      case GameLane.center:
        _currentLane = GameLane.right;
        break;
      case GameLane.left:
        _currentLane = GameLane.center;
        break;
      case GameLane.right:
        break;
    }
    _updateTargetX();
  }

  void _updateTargetX() {
    final game = (this as HasGameRef<NeuralBreakGame>).gameRef;
    _internalTargetX = getLaneX(_currentLane, game.size.x);
  }

  void resetMovement() {
    _currentLane = GameLane.center;
    initializeMovement();
  }

  void stopMovement() {
    _internalTargetX = position.x;
  }
}
