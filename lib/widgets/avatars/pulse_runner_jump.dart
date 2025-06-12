import 'package:flutter/material.dart';

class PulseRunnerJump extends StatelessWidget {
  final double size;
  const PulseRunnerJump({this.size = 150, super.key});

  double degToRad(double deg) => deg * 3.141592653589793 / 180;

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF2ECC40);
    final centerX = size * 0.8 / 2;

    return SizedBox(
      width: size * 0.8,
      height: size,
      child: CustomPaint(
        painter: _JumpPosePainter(color, centerX, degToRad),
      ),
    );
  }
}

class _JumpPosePainter extends CustomPainter {
  final Color color;
  final double centerX;
  final double Function(double) degToRad;

  _JumpPosePainter(this.color, this.centerX, this.degToRad);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withAlpha((0.7 * 255).toInt())
      ..style = PaintingStyle.fill;

    // Head trapezoid
    final headPath = Path()
      ..moveTo(centerX - 20, 15)
      ..lineTo(centerX + 20, 15)
      ..lineTo(centerX + 25, 40)
      ..lineTo(centerX - 25, 40)
      ..close();
    canvas.drawPath(headPath, paint);

    // Pulse circle
    canvas.drawCircle(Offset(centerX, 27), 4, fillPaint);

    // Body line
    canvas.drawLine(Offset(centerX, 40), Offset(centerX, 90), paint);

    // Arms fully stretched up (-90 degrees)
    canvas.save();
    canvas.translate(centerX, 50);
    canvas.rotate(degToRad(-90));
    canvas.drawLine(Offset(0, 0), Offset(-30, 20), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, 50);
    canvas.rotate(degToRad(-90));
    canvas.drawLine(Offset(0, 0), Offset(30, 20), paint);
    canvas.restore();

    // Legs tucked (rotate 60 and -60 degrees)
    canvas.save();
    canvas.translate(centerX, 90);
    canvas.rotate(degToRad(60));
    canvas.drawLine(Offset(0, 0), Offset(-20, 40), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, 90);
    canvas.rotate(degToRad(-60));
    canvas.drawLine(Offset(0, 0), Offset(20, 40), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
