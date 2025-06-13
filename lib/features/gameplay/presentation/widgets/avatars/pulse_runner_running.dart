import 'package:flutter/material.dart';

class PulseRunnerRunning extends StatefulWidget {
  final double size;
  const PulseRunnerRunning({this.size = 150, super.key}); // Default size

  @override
  PulseRunnerRunningState createState() => PulseRunnerRunningState();
}

class PulseRunnerRunningState extends State<PulseRunnerRunning>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> armRotationLeft;
  late Animation<double> armRotationRight;
  late Animation<double> legRotationLeft;
  late Animation<double> legRotationRight;
  late Animation<double> pulseRadius;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    armRotationLeft = Tween(begin: 0.0, end: 30.0).animate(_controller);
    armRotationRight = Tween(begin: 0.0, end: -30.0).animate(_controller);
    legRotationLeft = Tween(begin: 20.0, end: -20.0).animate(_controller);
    legRotationRight = Tween(begin: -20.0, end: 20.0).animate(_controller);
    pulseRadius = Tween(begin: 3.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF2ECC40); // circuit board green

    // The SizedBox width and height should define the aspect ratio of the avatar's container.
    // If the avatar is naturally taller than wide, keep this ratio.
    // playerSize is 40.0, so this will be 32x40.
    return SizedBox(
      width: widget.size * 0.8,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _PulseRunnerPainter(
              armLeftAngle: armRotationLeft.value,
              armRightAngle: armRotationRight.value,
              legLeftAngle: legRotationLeft.value,
              legRightAngle: legRotationRight.value,
              pulseRadius: pulseRadius.value,
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class _PulseRunnerPainter extends CustomPainter {
  final double armLeftAngle;
  final double armRightAngle;
  final double legLeftAngle;
  final double legRightAngle;
  final double pulseRadius;
  final Color color;

  _PulseRunnerPainter({
    required this.armLeftAngle,
    required this.armRightAngle,
    required this.legLeftAngle,
    required this.legRightAngle,
    required this.pulseRadius,
    required this.color,
  });

  double degToRad(double deg) => deg * (3.141592653589793 / 180);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2 *
          (size.width /
              120) // Scale stroke width relative to original 120 width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Added for rounded joints

    final fillPaint = Paint()
      ..color = color.withAlpha((0.7 * 255).toInt())
      ..style = PaintingStyle.fill;

    // Base dimensions for proportional scaling (e.g., if original design was 120x150)
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
    final scaledLegPivotY = 90 * heightRatio; // Same as scaledBodyBottom

    final scaledHeadWidth = 45 *
        widthRatio; // Original head width was ~40-50 based on original coords
    final scaledHeadOffset = 5 * widthRatio;

    final scaledLimbLengthX = 30 * widthRatio;
    final scaledLimbLengthY = 20 * heightRatio;

    final scaledPulseCircleRadius =
        4 * (widthRatio + heightRatio) / 2; // Average scaling for radius

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

    // Pulse circle (centered vertically within head)
    canvas.drawCircle(
        Offset(centerX, scaledHeadTop + (scaledHeadBottom - scaledHeadTop) / 2),
        scaledPulseCircleRadius,
        fillPaint);

    // Body line
    canvas.drawLine(Offset(centerX, scaledBodyTop),
        Offset(centerX, scaledBodyBottom), paint);

    // Arms pivot at (centerX, scaledArmPivotY)
    canvas.save();
    canvas.translate(centerX, scaledArmPivotY);
    canvas.rotate(degToRad(armLeftAngle));
    canvas.drawLine(
        Offset(0, 0), Offset(-scaledLimbLengthX, scaledLimbLengthY), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, scaledArmPivotY);
    canvas.rotate(degToRad(armRightAngle));
    canvas.drawLine(
        Offset(0, 0), Offset(scaledLimbLengthX, scaledLimbLengthY), paint);
    canvas.restore();

    // Legs pivot at (centerX, scaledLegPivotY)
    canvas.save();
    canvas.translate(centerX, scaledLegPivotY);
    canvas.rotate(degToRad(legLeftAngle));
    canvas.drawLine(Offset(0, 0),
        Offset(-scaledLimbLengthX * 0.8, scaledLimbLengthY * 1.5), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, scaledLegPivotY);
    canvas.rotate(degToRad(legRightAngle));
    canvas.drawLine(Offset(0, 0),
        Offset(scaledLimbLengthX * 0.8, scaledLimbLengthY * 1.5), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PulseRunnerPainter oldDelegate) {
    return armLeftAngle != oldDelegate.armLeftAngle ||
        armRightAngle != oldDelegate.armRightAngle ||
        legLeftAngle != oldDelegate.legLeftAngle ||
        legRightAngle != oldDelegate.legRightAngle ||
        pulseRadius != oldDelegate.pulseRadius;
  }
}
