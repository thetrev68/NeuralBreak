import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import 'package:neural_break/features/gameplay/domain/usecases/score_manager.dart';
import 'package:neural_break/features/gameplay/domain/usecases/life_manager.dart';
import 'package:neural_break/features/gameplay/domain/entities/player.dart';

import 'package:neural_break/features/gameplay/presentation/widgets/avatars/pulse_runner_controller.dart';
import 'package:neural_break/features/gameplay/presentation/widgets/avatars/pulse_runner_running.dart';
import 'package:neural_break/features/gameplay/presentation/widgets/avatars/pulse_runner_jump.dart';
import 'package:neural_break/features/gameplay/presentation/widgets/avatars/pulse_runner_slide.dart';

class UIManager {
  final ScoreManager _scoreManager;
  final LifeManager _lifeManager;

  late TextComponent _scoreTextComponent;
  late TextComponent _livesTextComponent;
  late TextComponent _levelTextComponent;

  final Player player;
  late final PulseRunnerController controller;

  UIManager({
    required ScoreManager scoreManager,
    required LifeManager lifeManager,
    required this.player,
  })  : _scoreManager = scoreManager,
        _lifeManager = lifeManager {
    controller = player.poseController;
    controller.addListener(_onPoseChanged);
  }

  void initializeTextComponents(TextComponent scoreText,
      TextComponent livesText, TextComponent levelText) {
    _scoreTextComponent = scoreText;
    _livesTextComponent = livesText;
    _levelTextComponent = levelText;
  }

  void updateTexts() {
    _scoreTextComponent.text = 'Score: ${_scoreManager.score}';
    _livesTextComponent.text = 'Lives: ${_lifeManager.lives}';
    _levelTextComponent.text = 'Level: ${_scoreManager.level}';
  }

  void _onPoseChanged() {
    debugPrint('TODO: _onPoseChanged called');
  }

  Widget buildAvatar(double size) {
    switch (controller.currentPose) {
      case PulseRunnerPose.running:
        return PulseRunnerRunning(size: size);
      case PulseRunnerPose.jump:
        return PulseRunnerJump(size: size);
      case PulseRunnerPose.slide:
        return PulseRunnerSlide(size: size);
    }
  }

  void dispose() {
    controller.removeListener(_onPoseChanged);
  }
}
