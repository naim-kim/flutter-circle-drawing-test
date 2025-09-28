import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const ScoreCard({Key? key, required this.analysis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
