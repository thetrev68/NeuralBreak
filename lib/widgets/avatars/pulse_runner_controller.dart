import 'package:flutter/material.dart';
// for TickerProvider and Ticker

class PoseAngles {
  final double armLeft;
  final double armRight;
  final double legLeft;
  final double legRight;
  final double torsoAngle;

  const PoseAngles({
    required this.armLeft,
    required this.armRight,
    required this.legLeft,
    required this.legRight,
    this.torsoAngle = 0,
  });
}

enum PulseRunnerPose { running, jump, slide }

const runningPose = PoseAngles(
  armLeft: 30,
  armRight: -30,
  legLeft: 20,
  legRight: -20,
);

const jumpPose = PoseAngles(
  armLeft: -90,
  armRight: -90,
  legLeft: 60,
  legRight: -60,
);

const slidePose = PoseAngles(
  armLeft: 45,
  armRight: 45,
  legLeft: -15,
  legRight: 15,
  torsoAngle: 30,
);

class PulseRunnerController extends ChangeNotifier {
  final TickerProvider tickerProvider;

  PulseRunnerPose _currentPose = PulseRunnerPose.running;
  PoseAngles _currentAngles = runningPose;

  late final AnimationController _animationController;
  late Animation<double> _armLeftAnim;
  late Animation<double> _armRightAnim;
  late Animation<double> _legLeftAnim;
  late Animation<double> _legRightAnim;
  late Animation<double> _torsoAnim;

  PulseRunnerController(this.tickerProvider) {
    _animationController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        notifyListeners();
      });

    _setAnimations(runningPose, runningPose);
  }

  PulseRunnerPose get currentPose => _currentPose;

  double get armLeftAngle => _armLeftAnim.value;
  double get armRightAngle => _armRightAnim.value;
  double get legLeftAngle => _legLeftAnim.value;
  double get legRightAngle => _legRightAnim.value;
  double get torsoAngle => _torsoAnim.value;

  void _setAnimations(PoseAngles from, PoseAngles to) {
    _armLeftAnim = Tween(begin: from.armLeft, end: to.armLeft)
        .animate(_animationController);
    _armRightAnim = Tween(begin: from.armRight, end: to.armRight)
        .animate(_animationController);
    _legLeftAnim = Tween(begin: from.legLeft, end: to.legLeft)
        .animate(_animationController);
    _legRightAnim = Tween(begin: from.legRight, end: to.legRight)
        .animate(_animationController);
    _torsoAnim = Tween(begin: from.torsoAngle, end: to.torsoAngle)
        .animate(_animationController);
  }

  void _animateToPose(PulseRunnerPose newPose, PoseAngles newAngles) {
    if (_currentPose == newPose) return;
    final fromAngles = _currentAngles;
    _currentPose = newPose;
    _currentAngles = newAngles;
    _setAnimations(fromAngles, newAngles);
    _animationController.forward(from: 0);
  }

  void run() => _animateToPose(PulseRunnerPose.running, runningPose);
  void jump() => _animateToPose(PulseRunnerPose.jump, jumpPose);
  void slide() => _animateToPose(PulseRunnerPose.slide, slidePose);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
