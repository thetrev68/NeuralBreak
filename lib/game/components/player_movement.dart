// Flame component base class
import 'package:flame/components.dart';

// Game constants like lane positions and movement speed
import 'package:neural_break/game/util/game_constants.dart';

// Access to the main game class for gameRef usage
import 'package:neural_break/game/neural_break_game.dart';

// Adds horizontal lane-based movement to the component.
// Requires the component to mix in HasGameReference<NeuralBreakGame>.
mixin PlayerMovement on PositionComponent, HasGameReference<NeuralBreakGame> {
  // <--- NEW
  // Internal X target for movement interpolation
  double _internalTargetX = 0.0;

  // Public read-only access to target X (useful for debugging or UI)
  double get targetX => _internalTargetX;

  // Tracks which lane the player is currently in
  GameLane _currentLane = GameLane.center;

  // Initializes the movement by placing the player in the center lane
  void initializeMovement() {
    // OLD: final game = (this as HasGameReference<NeuralBreakGame>).game;
    // NEW:
    _internalTargetX =
        getLaneX(_currentLane, game.size.x); // Use 'game' directly
    position.x = _internalTargetX; // Set initial horizontal position
  }

  // Called every frame to smoothly move toward the target X position
  void updateMovement(double dt) {
    final deltaX = _internalTargetX - position.x;
    if (deltaX.abs() > 0.1) {
      final step =
          playerMoveSpeed * dt; // Calculate movement step based on time
      // Move either the remaining distance or one step, whichever is smaller
      position.x += deltaX.abs() < step ? deltaX : deltaX.sign * step;
    }
  }

  // Attempt to move one lane to the left
  void moveLeft() {
    switch (_currentLane) {
      case GameLane.center:
        _currentLane = GameLane.left;
        break;
      case GameLane.right:
        _currentLane = GameLane.center;
        break;
      case GameLane.left:
        break; // Already at leftmost lane, do nothing
    }
    _updateTargetX(); // Update destination X position
  }

  // Attempt to move one lane to the right
  void moveRight() {
    switch (_currentLane) {
      case GameLane.center:
        _currentLane = GameLane.right;
        break;
      case GameLane.left:
        _currentLane = GameLane.center;
        break;
      case GameLane.right:
        break; // Already at rightmost lane, do nothing
    }
    _updateTargetX(); // Update destination X position
  }

  // Recalculates target X based on the current lane
  void _updateTargetX() {
    // OLD: final mygame = game;
    _internalTargetX =
        getLaneX(_currentLane, game.size.x); // Use 'game' directly
  }

  // Reset lane to center and reinitialize X position
  void resetMovement() {
    _currentLane = GameLane.center;
    initializeMovement();
  }

  // Freeze horizontal movement at current X
  void stopMovement() {
    _internalTargetX = position.x; // Player won't move anymore
  }
}
