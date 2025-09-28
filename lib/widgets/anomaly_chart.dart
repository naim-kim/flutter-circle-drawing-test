import 'package:flutter/material.dart';
import '../models/drawing_point.dart';
import '../painters/anomaly_chart_painter.dart';

class AnomalyChart extends StatelessWidget {
  final Map<String, dynamic> analysis;
  final List<DrawingPoint> drawingPoints;

  const AnomalyChart({
    Key? key,
    required this.analysis,
    required this.drawingPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<double> deviations = analysis['deviations'] ?? [];
    if (deviations.isEmpty) return Container();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Circle Accuracy Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: CustomPaint(
                painter: AnomalyChartPainter(
                  deviations: deviations,
                  drawingPoints: drawingPoints,
                  idealCenter: analysis['idealCenter'],
                  idealRadius: analysis['idealRadius'],
                ),
                size: Size.infinite,
              ),
            ),
            Text(
              'Red areas show deviations from perfect circle',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
