import 'package:flutter/material.dart';
import '../models/drawing_point.dart';
import '../services/drawing_analyzer.dart';

class DetailedStats extends StatelessWidget {
  final Map<String, dynamic> analysis;
  final List<DrawingPoint> drawingPoints;

  const DetailedStats({
    Key? key,
    required this.analysis,
    required this.drawingPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            _buildStatRow(
              'Total Time',
              '${DrawingAnalyzer.getTotalTime(drawingPoints)} ms',
            ),
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
}
