import 'package:flutter/material.dart';

class CoordinateDisplay extends StatelessWidget {
  final Offset position;
  final int pointCount;

  const CoordinateDisplay({
    Key? key,
    required this.position,
    required this.pointCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'X: ${position.dx.toStringAsFixed(1)}\n'
          'Y: ${position.dy.toStringAsFixed(1)}\n'
          'Points: $pointCount',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
