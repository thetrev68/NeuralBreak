import 'package:flutter/material.dart';

class PulseRunnerSlide extends StatelessWidget {
  final double size;
  const PulseRunnerSlide({this.size = 150, super.key});

  double degToRad(double deg) => deg * 3.141592653589793 / 180;

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF2ECC40);
    final centerX = size * 0.8 / 2;

    return SizedBox(
      width: size * 0.8,
      height: size,
      child: CustomPaint(
        painter: _SlidePosePainter(color, centerX, degToRad),
      ),
    );
  }
}

class _SlidePosePainter extends CustomPainter {
  final Color color;
  final double centerX;
  final double Function(double) degToRad;

  _SlidePosePainter(this.color, this.centerX, this.degToRad);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withAlpha((0.7 * 255).toInt())
      ..style = PaintingStyle.fill;

    // Head trapezoid rotated ~30 degrees forward
    canvas.save();
    canvas.translate(centerX, 40);
    canvas.rotate(degToRad(30));
    final headPath = Path()
      ..moveTo(-20, -25)
      ..lineTo(20, -25)
      ..lineTo(25, 0)
      ..lineTo(-25, 0)
      ..close();
    canvas.drawPath(headPath, paint);
    canvas.restore();

    // Pulse circle inside rotated head
    canvas.save();
    canvas.translate(centerX, 40);
    canvas.rotate(degToRad(30));
    canvas.drawCircle(const Offset(0, -13), 4, fillPaint);
    canvas.restore();

    // Body line bent forward
    canvas.save();
    canvas.translate(centerX, 90);
    canvas.rotate(degToRad(30));
    canvas.drawLine(Offset(0, -50), Offset(0, 0), paint);

    // Legs bent:
    // Left leg bent backward (-45 deg)
    canvas.save();
    canvas.rotate(degToRad(-45));
    canvas.drawLine(Offset(0, 0), Offset(-20, 40), paint);
    canvas.restore();

    // Right leg bent forward (15 deg)
    canvas.save();
    canvas.rotate(degToRad(15));
    canvas.drawLine(Offset(0, 0), Offset(20, 40), paint);
    canvas.restore();

    canvas.restore();

    // Arms bent forward (45 deg)
    canvas.save();
    canvas.translate(centerX, 50);
    canvas.rotate(degToRad(45));
    canvas.drawLine(Offset(0, 0), Offset(-20, 20), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, 50);
    canvas.rotate(degToRad(45));
    canvas.drawLine(Offset(0, 0), Offset(20, 20), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
