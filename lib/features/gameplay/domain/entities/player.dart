import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:neural_break/features/gameplay/presentation/pages/neural_break_game.dart';
import 'package:neural_break/core/constants/game_constants.dart';
import 'package:neural_break/features/gameplay/domain/usecases/player_movement.dart';
import 'package:neural_break/features/gameplay/domain/usecases/player_jump.dart';
import 'package:neural_break/features/gameplay/domain/usecases/player_slide.dart';
import 'package:neural_break/features/gameplay/domain/entities/obstacle.dart';
import 'package:neural_break/widgets/avatars/pulse_runner_controller.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode print

class Player extends PositionComponent
    with
        HasGameReference<NeuralBreakGame>,
        CollisionCallbacks,
        PlayerMovement,
        PlayerJump,
        PlayerSlide {
  // static final _playerPaint = Paint() // Keep this commented out
  //   ..color = Colors.white
  //   ..style = PaintingStyle.fill;

  final PulseRunnerController poseController;

  Player({required TickerProvider tickerProvider})
      : poseController = PulseRunnerController(tickerProvider),
        super(
          size: Vector2(playerSize, playerSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    if (kDebugMode) {
      print('Player: onLoad started');
    }
    await super.onLoad();
    initializeMovement();
    position.y = getGroundY(game.size.y, playerSize);
    initializeJump();
    initializeSlide();
    add(RectangleHitbox());

    // Remove the previous attempts to add/listen to poseController for rendering
    // since the rendering happens via AvatarDisplayWidget.
    // if (poseController.runnerComponent != null) { ... }
    // poseController.addListener(_onPoseChanged);

    if (kDebugMode) {
      print('Player: onLoad completed');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateMovement(dt);
    updateJump(dt);
    updateSlide(dt);
    // No explicit call to poseController.update(dt) if it doesn't have one.
    // Its internal AnimationController handles the timing.
  }

  // @override
  // void render(Canvas canvas) { // Keep this commented out
  //  super.render(canvas);
  //  canvas.drawRect(size.toRect(), _playerPaint);
  // }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstacle) {
      game.loseLife();
    }
  }

  void reset() {
    resetMovement();
    resetJump();
    resetSlide();
    position.y = getGroundY(game.size.y, playerSize);
  }

  void stopAllActions() {
    stopMovement();
    stopJump();
    stopSlide();
  }

  void applyJump() {
    jump();
    poseController
        .jump(); // Still call poseController to change internal pose state
  }

  void applySlide() {
    slide();
    poseController
        .slide(); // Still call poseController to change internal pose state
  }

  @override
  void moveLeft() {
    super.moveLeft();
    poseController
        .run(); // Still call poseController to change internal pose state
  }

  @override
  void moveRight() {
    super.moveRight();
    poseController
        .run(); // Still call poseController to change internal pose state
  }

  @override
  void onRemove() {
    // poseController.removeListener(_onPoseChanged); // Remove this line
    poseController.dispose();
    super.onRemove();
  }
}
