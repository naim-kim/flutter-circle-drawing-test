import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DrawingScreen(),
    );
  }
}

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

class AnalysisScreen extends StatelessWidget {
  final List<DrawingPoint> drawingPoints;
  final Offset? actualCircleCenter;
  final double actualRadius;

  AnalysisScreen({
    required this.drawingPoints,
    this.actualCircleCenter,
    this.actualRadius = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = _analyzeDrawing();

    return Scaffold(
      appBar: AppBar(title: Text('Drawing Analysis')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(analysis),
            SizedBox(height: 20),
            _buildAnomalyChart(analysis),
            SizedBox(height: 20),
            _buildSpeedChart(analysis),
            SizedBox(height: 20),
            _buildDetailedStats(analysis),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _analyzeDrawing() {
    if (drawingPoints.isEmpty) return {};

    // Use actual circle center or calculate from drawing
    Offset idealCenter;
    if (actualCircleCenter != null) {
      idealCenter = actualCircleCenter!;
    } else {
      // Fallback: calculate center from drawing points
      double centerX = 0, centerY = 0;
      for (var point in drawingPoints) {
        centerX += point.offset.dx;
        centerY += point.offset.dy;
      }
      centerX /= drawingPoints.length;
      centerY /= drawingPoints.length;
      idealCenter = Offset(centerX, centerY);
    }

    double idealRadius = actualRadius;

    // Calculate anomalies and metrics
    List<double> deviations = [];
    List<double> speeds = [];
    List<double> smoothness = [];

    for (int i = 0; i < drawingPoints.length; i++) {
      // Distance from ideal circle
      double distToIdeal = (drawingPoints[i].offset - idealCenter).distance;
      double deviation = (distToIdeal - idealRadius).abs();
      deviations.add(deviation);

      // Speed calculation
      if (i > 0) {
        double distance =
            (drawingPoints[i].offset - drawingPoints[i - 1].offset).distance;
        int timeDiff =
            drawingPoints[i].timestamp.millisecondsSinceEpoch -
            drawingPoints[i - 1].timestamp.millisecondsSinceEpoch;
        double speed =
            timeDiff > 0 ? distance / timeDiff * 1000 : 0; // pixels per second
        speeds.add(speed);

        // Smoothness (acceleration changes)
        if (speeds.length > 1) {
          double acceleration = (speeds.last - speeds[speeds.length - 2]).abs();
          smoothness.add(acceleration);
        }
      }
    }

    // Performance metrics
    double avgDeviation =
        deviations.isNotEmpty
            ? deviations.reduce((a, b) => a + b) / deviations.length
            : 0;
    double maxDeviation =
        deviations.isNotEmpty ? deviations.reduce(math.max) : 0;
    double avgSpeed =
        speeds.isNotEmpty ? speeds.reduce((a, b) => a + b) / speeds.length : 0;
    double speedVariation = speeds.isNotEmpty ? _calculateVariation(speeds) : 0;
    double smoothnessScore =
        smoothness.isNotEmpty ? _calculateVariation(smoothness) : 0;

    // Overall score (0-100) - improved scoring
    double accuracyScore = math.max(
      0,
      100 - (avgDeviation * 1.5),
    ); // More lenient
    double speedScore = math.max(
      0,
      100 - (speedVariation / 20),
    ); // More lenient
    double smoothnessScoreNormalized = math.max(
      0,
      100 - (smoothnessScore / 200),
    ); // More lenient
    double overallScore =
        (accuracyScore + speedScore + smoothnessScoreNormalized) / 3;

    return {
      'deviations': deviations,
      'speeds': speeds,
      'smoothness': smoothness,
      'avgDeviation': avgDeviation,
      'maxDeviation': maxDeviation,
      'avgSpeed': avgSpeed,
      'speedVariation': speedVariation,
      'accuracyScore': accuracyScore,
      'speedScore': speedScore,
      'smoothnessScore': smoothnessScoreNormalized,
      'overallScore': overallScore,
      'idealCenter': idealCenter,
      'idealRadius': idealRadius,
    };
  }

  double _calculateVariation(List<double> values) {
    if (values.isEmpty) return 0;
    double mean = values.reduce((a, b) => a + b) / values.length;
    double variance =
        values.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
        values.length;
    return math.sqrt(variance);
  }

  Widget _buildScoreCard(Map<String, dynamic> analysis) {
    double score = analysis['overallScore'] ?? 0;
    String rating =
        score >= 80
            ? 'Excellent'
            : score >= 60
            ? 'Good'
            : score >= 40
            ? 'Average'
            : 'Below Average';

    Color scoreColor =
        score >= 80
            ? Colors.green
            : score >= 60
            ? Colors.blue
            : score >= 40
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Overall Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              strokeWidth: 8,
            ),
            SizedBox(height: 10),
            Text(
              '${score.toStringAsFixed(1)}/100',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(rating, style: TextStyle(fontSize: 16, color: scoreColor)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniScore('Accuracy', analysis['accuracyScore'] ?? 0),
                _buildMiniScore('Speed', analysis['speedScore'] ?? 0),
                _buildMiniScore('Smoothness', analysis['smoothnessScore'] ?? 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniScore(String label, double score) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        Text(
          '${score.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAnomalyChart(Map<String, dynamic> analysis) {
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

  Widget _buildSpeedChart(Map<String, dynamic> analysis) {
    List<double> speeds = analysis['speeds'] ?? [];
    if (speeds.isEmpty) return Container();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Drawing Speed Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 150,
              child: CustomPaint(
                painter: SpeedChartPainter(speeds: speeds),
                size: Size.infinite,
              ),
            ),
            Text(
              'Shows your drawing speed over time (pixels/second)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(Map<String, dynamic> analysis) {
    Offset idealCenter = analysis['idealCenter'] ?? Offset(0, 0);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildStatRow('Total Points', '${drawingPoints.length}'),
            _buildStatRow(
              'Circle Center',
              '${idealCenter.dx.toInt()}, ${idealCenter.dy.toInt()}',
            ),
            _buildStatRow(
              'Average Deviation',
              '${(analysis['avgDeviation'] ?? 0).toStringAsFixed(1)} px',
            ),
            _buildStatRow(
              'Max Deviation',
              '${(analysis['maxDeviation'] ?? 0).toStringAsFixed(1)} px',
            ),
            _buildStatRow(
              'Average Speed',
              '${(analysis['avgSpeed'] ?? 0).toStringAsFixed(1)} px/s',
            ),
            _buildStatRow('Total Time', '${_getTotalTime()} ms'),
            SizedBox(height: 10),
            Text(
              'Testing Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '• Start at 3 o\'clock position\n• Draw clockwise slowly\n• Stay close to gray circle\n• Good score: <20px deviation',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getTotalTime() {
    if (drawingPoints.length < 2) return '0';
    int totalTime =
        drawingPoints.last.timestamp.millisecondsSinceEpoch -
        drawingPoints.first.timestamp.millisecondsSinceEpoch;
    return totalTime.toString();
  }
}

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
