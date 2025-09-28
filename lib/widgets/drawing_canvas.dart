import 'package:flutter/material.dart';
import '../models/drawing_point.dart';
import '../painters/drawing_painter.dart';

class DrawingCanvas extends StatelessWidget {
  final List<List<DrawingPoint>> strokes;
  final List<DrawingPoint> currentStroke;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final void Function(Offset)? onCircleCenterCalculated;

  const DrawingCanvas({
    Key? key,
    required this.strokes,
    required this.currentStroke,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    this.onCircleCenterCalculated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: CustomPaint(
          painter: DrawingPainter(
            strokes: strokes,
            currentStroke: currentStroke,
            onCircleCenterCalculated: onCircleCenterCalculated,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
