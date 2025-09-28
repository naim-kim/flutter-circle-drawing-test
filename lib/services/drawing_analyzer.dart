import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/drawing_point.dart';

class DrawingAnalyzer {
  static Map<String, dynamic> analyzeDrawing(
    List<DrawingPoint> drawingPoints,
    Offset? actualCircleCenter,
    double actualRadius,
  ) {
    if (drawingPoints.isEmpty) return {};

    // Use actual circle center or calculate from drawing
    Offset idealCenter;
    if (actualCircleCenter != null) {
      idealCenter = actualCircleCenter;
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
    double accuracyScore = math.max(0, 100 - (avgDeviation * 1.5));
    double speedScore = math.max(0, 100 - (speedVariation / 20));
    double smoothnessScoreNormalized = math.max(
      0,
      100 - (smoothnessScore / 200),
    );
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

  static double _calculateVariation(List<double> values) {
    if (values.isEmpty) return 0;
    double mean = values.reduce((a, b) => a + b) / values.length;
    double variance =
        values.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
        values.length;
    return math.sqrt(variance);
  }

  static String getTotalTime(List<DrawingPoint> drawingPoints) {
    if (drawingPoints.length < 2) return '0';
    int totalTime =
        drawingPoints.last.timestamp.millisecondsSinceEpoch -
        drawingPoints.first.timestamp.millisecondsSinceEpoch;
    return totalTime.toString();
  }
}
