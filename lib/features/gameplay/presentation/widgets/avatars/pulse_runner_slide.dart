// file: lib/features/gameplay/presentation/widgets/avatars/pulse_runner_controller.dart

import 'package:flutter/material.dart';

class PulseRunnerSlide extends StatelessWidget {
  final double size;
  const PulseRunnerSlide({this.size = 150, super.key});

  double degToRad(double deg) => deg * (3.141592653589793 / 180);

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF2ECC40);

    return SizedBox(
      width: size * 0.8,
      height: size,
      child: CustomPaint(
        painter: _SlidePosePainter(color, degToRad),
      ),
    );
  }
}

class _SlidePosePainter extends CustomPainter {
  final Color color;
  final double Function(double) degToRad;

  _SlidePosePainter(this.color, this.degToRad);

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

    final scaledHeadWidth = 45 * widthRatio;
    final scaledHeadOffset = 5 * widthRatio;

    final scaledLimbLengthX = 30 * widthRatio;
    final scaledLimbLengthY = 20 * heightRatio;

    final scaledPulseCircleRadius = 4 * (widthRatio + heightRatio) / 2;

    final centerX = size.width / 2;

    // Head trapezoid rotated ~30 degrees forward
    canvas.save();
    // Translate to the center of the head for rotation
    canvas.translate(
        centerX, scaledHeadTop + (scaledHeadBottom - scaledHeadTop) / 2);
    canvas.rotate(degToRad(30));
    final headPath = Path()
      ..moveTo(-scaledHeadWidth / 2,
          -scaledHeadBottom / 2 + scaledHeadTop / 2) // Relative to new origin
      ..lineTo(scaledHeadWidth / 2, -scaledHeadBottom / 2 + scaledHeadTop / 2)
      ..lineTo(scaledHeadWidth / 2 + scaledHeadOffset,
          scaledHeadBottom / 2 - scaledHeadTop / 2)
      ..lineTo(-scaledHeadWidth / 2 - scaledHeadOffset,
          scaledHeadBottom / 2 - scaledHeadTop / 2)
      ..close();
    canvas.drawPath(headPath, paint);
    canvas.restore();

    // Pulse circle inside rotated head
    canvas.save();
    canvas.translate(
        centerX, scaledHeadTop + (scaledHeadBottom - scaledHeadTop) / 2);
    canvas.rotate(degToRad(30));
    canvas.drawCircle(Offset(0, -scaledPulseCircleRadius),
        scaledPulseCircleRadius, fillPaint); // Relative to new origin
    canvas.restore();

    // Body line bent forward
    canvas.save();
    canvas.translate(centerX, scaledBodyTop);
    canvas.rotate(degToRad(30));
    canvas.drawLine(
        Offset(0, 0), Offset(0, scaledBodyBottom - scaledBodyTop), paint);

    // Legs bent:
    // Left leg bent backward (-45 deg)
    canvas.save();
    canvas.translate(
        0, scaledBodyBottom - scaledBodyTop); // Translate to end of body line
    canvas.rotate(degToRad(-45));
    canvas.drawLine(Offset(0, 0),
        Offset(-scaledLimbLengthX, scaledLimbLengthY * 1.5), paint);
    canvas.restore();

    // Right leg bent forward (15 deg)
    canvas.save();
    canvas.translate(0, scaledBodyBottom - scaledBodyTop);
    canvas.rotate(degToRad(15));
    canvas.drawLine(Offset(0, 0),
        Offset(scaledLimbLengthX, scaledLimbLengthY * 1.5), paint);
    canvas.restore();

    canvas.restore(); // Restore from body line rotation

    // Arms bent forward (45 deg)
    canvas.save();
    canvas.translate(centerX, scaledArmPivotY);
    canvas.rotate(degToRad(45));
    canvas.drawLine(Offset(0, 0),
        Offset(-scaledLimbLengthX * 0.8, scaledLimbLengthY), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, scaledArmPivotY);
    canvas.rotate(degToRad(45));
    canvas.drawLine(Offset(0, 0),
        Offset(scaledLimbLengthX * 0.8, scaledLimbLengthY), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
