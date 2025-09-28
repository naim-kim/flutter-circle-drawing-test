import 'package:drawingdemo/models/drawing_point.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnomalyChartPainter extends CustomPainter {
  final List<double> deviations;
  final List<DrawingPoint> drawingPoints;
  final Offset idealCenter;
  final double idealRadius;

  AnomalyChartPainter({
    required this.deviations,
    required this.drawingPoints,
    required this.idealCenter,
    required this.idealRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (drawingPoints.isEmpty) return;

    // Scale drawing to fit in chart
    double scaleX = size.width / 400; // Assuming original canvas was ~400 wide
    double scaleY = size.height / 400;
    double scale = math.min(scaleX, scaleY);

    Offset center = Offset(size.width / 2, size.height / 2);

    // Draw ideal circle
    Paint idealPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, idealRadius * scale * 0.5, idealPaint);

    // Draw actual path with color coding for deviations
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      double deviation = deviations[i];
      double intensity = math.min(1.0, deviation / 50); // Normalize deviation

      Paint linePaint =
          Paint()
            ..color = Color.lerp(Colors.green, Colors.red, intensity)!
            ..strokeWidth = 3;

      Offset p1 = _scalePoint(drawingPoints[i].offset, center, scale);
      Offset p2 = _scalePoint(drawingPoints[i + 1].offset, center, scale);

      canvas.drawLine(p1, p2, linePaint);
    }
  }

  Offset _scalePoint(Offset original, Offset center, double scale) {
    return center + (original - idealCenter) * scale * 0.5;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
