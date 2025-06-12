import 'package:flutter/material.dart';

class PulseRunnerRunning extends StatefulWidget {
  final double size;
  const PulseRunnerRunning({this.size = 150, super.key});

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

  double degToRad(double deg) => deg * 3.141592653589793 / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;

    // Head trapezoid
    final headPath = Path()
      ..moveTo(centerX - 20, 15)
      ..lineTo(centerX + 20, 15)
      ..lineTo(centerX + 25, 40)
      ..lineTo(centerX - 25, 40)
      ..close();
    canvas.drawPath(headPath, paint);

    // Pulse circle
    final pulsePaint = Paint()
      ..color = color.withAlpha((0.7 * 255).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, 27), pulseRadius, pulsePaint);

    // Body line
    canvas.drawLine(Offset(centerX, 40), Offset(centerX, 90), paint);

    // Arms pivot at (centerX, 50)
    canvas.save();
    canvas.translate(centerX, 50);
    canvas.rotate(degToRad(armLeftAngle));
    canvas.drawLine(Offset(0, 0), Offset(-30, 20), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, 50);
    canvas.rotate(degToRad(armRightAngle));
    canvas.drawLine(Offset(0, 0), Offset(30, 20), paint);
    canvas.restore();

    // Legs pivot at (centerX, 90)
    canvas.save();
    canvas.translate(centerX, 90);
    canvas.rotate(degToRad(legLeftAngle));
    canvas.drawLine(Offset(0, 0), Offset(-20, 40), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, 90);
    canvas.rotate(degToRad(legRightAngle));
    canvas.drawLine(Offset(0, 0), Offset(20, 40), paint);
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
