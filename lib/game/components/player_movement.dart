// lib/game/components/player_movement.dart
import 'package:flame/components.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';

// This mixin adds horizontal movement capabilities to a PositionComponent.
// It requires the component to have a reference to NeuralBreakGame (via HasGameRef).
mixin PlayerMovement on PositionComponent implements HasGameRef<NeuralBreakGame> {
  // Properties for movement
  double _internalTargetX = 0.0;
  double get targetX => _internalTargetX;

  GameLane _currentLane = GameLane.center;

  // Method to be called by the game to set initial position
  void initializeMovement() {
    _currentLane = GameLane.center; // Reset current lane to center
    _internalTargetX = getLaneX(_currentLane, gameRef.size.x);
    position.x = _internalTargetX;
  }

  // Movement logic to be called in the owning component's update method
  void updateMovement(double dt) {
    final deltaX = _internalTargetX - position.x;
    if (deltaX.abs() > 0.1) {
      if (deltaX.abs() < playerMoveSpeed * dt) {
        position.x = _internalTargetX;
        print('Player snapped to target X: ${_internalTargetX.toStringAsFixed(2)}');
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
        print('Attempted move left, already at leftmost lane.');
        break;
    }
    _updateTargetX();
    print('Player moving left. New current lane: $_currentLane');
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
        print('Attempted move right, already at rightmost lane.');
        break;
    }
    _updateTargetX();
    print('Player moving right. New current lane: $_currentLane');
  }

  // Private helper to update the target X based on current lane
  void _updateTargetX() {
    _internalTargetX = getLaneX(_currentLane, gameRef.size.x);
  }

  // New method to stop horizontal movement
  void stopMovement() {
    _currentLane = GameLane.center;
    _internalTargetX = getLaneX(_currentLane, gameRef.size.x);
    position.x = _internalTargetX; // Snap to center
    print('Player movement stopped and reset to center lane.');
  }
}