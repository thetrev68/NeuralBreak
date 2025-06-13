// file: lib/features/gameplay/presentation/widgets/avatars/pulse_runner_controller.dart

import 'package:flutter/material.dart';

class PulseRunnerJump extends StatelessWidget {
  final double size;
  const PulseRunnerJump({this.size = 150, super.key});

  double degToRad(double deg) => deg * (3.141592653589793 / 180);

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF2ECC40);

    return SizedBox(
      width: size * 0.8,
      height: size,
      child: CustomPaint(
        painter: _JumpPosePainter(color, degToRad),
      ),
    );
  }
}

class _JumpPosePainter extends CustomPainter {
  final Color color;
  final double Function(double) degToRad;

  _JumpPosePainter(this.color, this.degToRad);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2 * (size.width / 120) // Scale stroke width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withAlpha((0.7 * 255).toInt())
      ..style = PaintingStyle.fill;

    // Base dimensions for proportional scaling
    const double originalWidth = 120.0;
    const double originalHeight = 150.0;

    final double widthRatio = size.width / originalWidth;
    final double heightRatio = size.height / originalHeight;

    // Calculate scaled coordinates and lengths
    final scaledHeadTop = 15 * heightRatio;
    final scaledHeadBottom = 40 * heightRatio;
    final scaledBodyTop = scaledHeadBottom;
    final scaledBodyBottom = 90 * heightRatio;
    final scaledArmPivotY = 50 * heightRatio;
    final scaledLegPivotY = 90 * heightRatio;

    final scaledHeadWidth = 45 * widthRatio;
    final scaledHeadOffset = 5 * widthRatio;

    final scaledLimbLengthX = 30 * widthRatio;
    final scaledLimbLengthY = 20 * heightRatio;

    final scaledPulseCircleRadius = 4 * (widthRatio + heightRatio) / 2;

    final centerX = size.width / 2;

    // Head trapezoid
    final headPath = Path()
      ..moveTo(centerX - scaledHeadWidth / 2, scaledHeadTop)
      ..lineTo(centerX + scaledHeadWidth / 2, scaledHeadTop)
      ..lineTo(
          centerX + scaledHeadWidth / 2 + scaledHeadOffset, scaledHeadBottom)
      ..lineTo(
          centerX - scaledHeadWidth / 2 - scaledHeadOffset, scaledHeadBottom)
      ..close();
    canvas.drawPath(headPath, paint);

    // Pulse circle
    canvas.drawCircle(
        Offset(centerX, scaledHeadTop + (scaledHeadBottom - scaledHeadTop) / 2),
        scaledPulseCircleRadius,
        fillPaint);

    // Body line
    canvas.drawLine(Offset(centerX, scaledBodyTop),
        Offset(centerX, scaledBodyBottom), paint);

    // Arms fully stretched up (-90 degrees)
    canvas.save();
    canvas.translate(centerX, scaledArmPivotY);
    canvas.rotate(degToRad(-90));
    canvas.drawLine(
        Offset(0, 0), Offset(-scaledLimbLengthX, scaledLimbLengthY), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, scaledArmPivotY);
    canvas.rotate(degToRad(-90));
    canvas.drawLine(
        Offset(0, 0), Offset(scaledLimbLengthX, scaledLimbLengthY), paint);
    canvas.restore();

    // Legs tucked (rotate 60 and -60 degrees)
    canvas.save();
    canvas.translate(centerX, scaledLegPivotY);
    canvas.rotate(degToRad(60));
    canvas.drawLine(Offset(0, 0),
        Offset(-scaledLimbLengthX * 0.8, scaledLimbLengthY * 1.5), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, scaledLegPivotY);
    canvas.rotate(degToRad(-60));
    canvas.drawLine(Offset(0, 0),
        Offset(scaledLimbLengthX * 0.8, scaledLimbLengthY * 1.5), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
