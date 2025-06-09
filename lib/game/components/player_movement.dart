// lib/game/components/player_movement.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';

// This mixin adds horizontal movement capabilities to a PositionComponent.
// It requires the component to have a reference to NeuralBreakGame (via HasGameReference).
mixin PlayerMovement on PositionComponent, HasGameReference<NeuralBreakGame> { // Correct: Use 'on' for HasGameReference
  // Properties for movement
  double _internalTargetX = 0.0;
  double get targetX => _internalTargetX;

  GameLane _currentLane = GameLane.center;

  // Method to be called by the game to set initial position
  void initializeMovement() {
    _internalTargetX = getLaneX(_currentLane, game.size.x); // Correct: Use 'game'
    position.x = _internalTargetX;
  }

  // Movement logic to be called in the owning component's update method
  void updateMovement(double dt) {
    final deltaX = _internalTargetX - position.x;
    if (deltaX.abs() > 0.1) {
      if (deltaX.abs() < playerMoveSpeed * dt) {
        position.x = _internalTargetX;
      } else {
        position.x += deltaX.sign * playerMoveSpeed * dt;
      }
    }
  }

  // Public methods to trigger lane changes
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

  // Private helper to update the target X based on current lane
  void _updateTargetX() {
    _internalTargetX = getLaneX(_currentLane, game.size.x); // Correct: Use 'game'
  }

  void resetMovement() {
    _currentLane = GameLane.center;
    initializeMovement();
  }

  void stopMovement() {
    _internalTargetX = position.x;
  }
}