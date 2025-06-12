import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';

import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/util/game_constants.dart';
import 'package:neural_break/game/components/player_movement.dart';
import 'package:neural_break/game/components/player_jump.dart';
import 'package:neural_break/game/components/player_slide.dart';
import 'package:neural_break/game/components/obstacle.dart';

import 'package:neural_break/widgets/avatars/pulse_runner_controller.dart';

class Player extends PositionComponent
    with
        HasGameReference<NeuralBreakGame>,
        CollisionCallbacks,
        PlayerMovement,
        PlayerJump,
        PlayerSlide {
  // static final _playerPaint = Paint()
  //   ..color = Colors.white
  //   ..style = PaintingStyle.fill;

  final PulseRunnerController poseController;

  // You must pass a TickerProvider here — see next step
  Player({required TickerProvider tickerProvider})
      : poseController = PulseRunnerController(tickerProvider),
        super(
          size: Vector2(playerSize, playerSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    initializeMovement();
    position.y = game.size.y - size.y * 2;
    initializeJump();
    initializeSlide();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateMovement(dt);
    updateJump(dt);
    updateSlide(dt);
  }

  // @override
  // void render(Canvas canvas) {
  //  super.render(canvas);
  //  canvas.drawRect(size.toRect(), _playerPaint); // removed to use avatar
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
    position.y = game.size.y - size.y * 2;
  }

  void stopAllActions() {
    stopMovement();
    stopJump();
    stopSlide();
  }

  void applyJump() {
    jump();
    poseController.jump();
  }

  void applySlide() {
    slide();
    poseController.slide();
  }

  @override
  void moveLeft() {
    super.moveLeft();
    poseController.run();
  }

  @override
  void moveRight() {
    super.moveRight();
    poseController.run();
  }

  @override
  void onRemove() {
    poseController.dispose();
    super.onRemove();
  }
}
