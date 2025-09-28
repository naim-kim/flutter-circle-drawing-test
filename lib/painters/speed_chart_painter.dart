import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpeedChartPainter extends CustomPainter {
  final List<double> speeds;

  SpeedChartPainter({required this.speeds});

  @override
  void paint(Canvas canvas, Size size) {
    if (speeds.isEmpty) return;

    double maxSpeed = speeds.reduce(math.max);
    if (maxSpeed == 0) return;

    Paint linePaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2;

    Paint fillPaint = Paint()..color = Colors.blue.withOpacity(0.3);

    // Create path for the speed curve
    Path path = Path();
    Path fillPath = Path();

    double stepX = size.width / (speeds.length - 1);

    fillPath.moveTo(0, size.height);
    path.moveTo(0, size.height - (speeds[0] / maxSpeed * size.height));
    fillPath.lineTo(0, size.height - (speeds[0] / maxSpeed * size.height));

    for (int i = 1; i < speeds.length; i++) {
      double x = i * stepX;
      double y = size.height - (speeds[i] / maxSpeed * size.height);

      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw filled area and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw average line
    double avgSpeed = speeds.reduce((a, b) => a + b) / speeds.length;
    double avgY = size.height - (avgSpeed / maxSpeed * size.height);

    Paint avgPaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, avgY), Offset(size.width, avgY), avgPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
