import 'package:flutter/material.dart';
import '../painters/speed_chart_painter.dart';

class SpeedChart extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const SpeedChart({Key? key, required this.analysis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
