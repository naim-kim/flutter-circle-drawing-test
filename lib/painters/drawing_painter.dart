import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class DrawingPainter extends CustomPainter {
  final List<List<DrawingPoint>> strokes;
  final List<DrawingPoint> currentStroke;
  final Function(Offset)? onCircleCenterCalculated;

  DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    this.onCircleCenterCalculated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw watermark (simple circle as example)
    _drawWatermark(canvas, size);

    // Draw completed strokes
    Paint strokePaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

    for (List<DrawingPoint> stroke in strokes) {
      _drawStroke(canvas, stroke, strokePaint);
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      strokePaint.color = Colors.blue.withOpacity(0.8);
      _drawStroke(canvas, currentStroke, strokePaint);
    }
  }

  void _drawWatermark(Canvas canvas, Size size) {
    Paint watermarkPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    // Draw a simple circle as watermark/template
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = 100.0;
    canvas.drawCircle(center, radius, watermarkPaint);

    // Notify parent about actual circle center
    if (onCircleCenterCalculated != null) {
      onCircleCenterCalculated!(center);
    }

    // Debug: Show center point
    Paint centerPaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 4;
    canvas.drawCircle(center, 3, centerPaint);

    // Add some guiding text
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text:
            'Trace the circle\nCenter: ${center.dx.toInt()}, ${center.dy.toInt()}',
        style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - radius - 50),
    );
  }

  void _drawStroke(Canvas canvas, List<DrawingPoint> stroke, Paint paint) {
    if (stroke.isEmpty) return;

    if (stroke.length == 1) {
      // Draw a single point as a small circle
      canvas.drawCircle(stroke[0].offset, paint.strokeWidth / 2, paint);
      return;
    }

    // Draw lines between consecutive points
    for (int i = 0; i < stroke.length - 1; i++) {
      canvas.drawLine(stroke[i].offset, stroke[i + 1].offset, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
