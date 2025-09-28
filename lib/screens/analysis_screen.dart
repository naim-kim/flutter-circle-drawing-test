import 'package:flutter/material.dart';
import '../models/drawing_point.dart';
import '../services/drawing_analyzer.dart';
import '../widgets/score_card.dart';
import '../widgets/anomaly_chart.dart';
import '../widgets/speed_chart.dart';
import '../widgets/detailed_stats.dart';

class AnalysisScreen extends StatelessWidget {
  final List<DrawingPoint> drawingPoints;
  final Offset? actualCircleCenter;
  final double actualRadius;

  const AnalysisScreen({
    Key? key,
    required this.drawingPoints,
    this.actualCircleCenter,
    this.actualRadius = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final analysis = DrawingAnalyzer.analyzeDrawing(
      drawingPoints,
      actualCircleCenter,
      actualRadius,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Drawing Analysis')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScoreCard(analysis: analysis),
            SizedBox(height: 20),
            AnomalyChart(analysis: analysis, drawingPoints: drawingPoints),
            SizedBox(height: 20),
            SpeedChart(analysis: analysis),
            SizedBox(height: 20),
            DetailedStats(analysis: analysis, drawingPoints: drawingPoints),
          ],
        ),
      ),
    );
  }
}
