import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset offset;
  final DateTime timestamp;

  DrawingPoint({required this.offset, required this.timestamp});

  @override
  String toString() {
    return 'Point(x: ${offset.dx.toStringAsFixed(1)}, y: ${offset.dy.toStringAsFixed(1)}, time: ${timestamp.millisecondsSinceEpoch})';
  }
}
