import 'package:flutter/material.dart';
import '../models/drawing_point.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/coordinate_display.dart';
import 'analysis_screen.dart';

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<DrawingPoint> points = [];
  List<List<DrawingPoint>> strokes = [];
  List<DrawingPoint> currentStroke = [];
  Offset? currentTouchPosition;
  Offset? actualCircleCenter;
  double actualRadius = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing Demo'),
        actions: [
          IconButton(icon: Icon(Icons.clear), onPressed: _clearCanvas),
          IconButton(icon: Icon(Icons.data_usage), onPressed: _showData),
          IconButton(
            icon: Icon(Icons.check_circle),
            onPressed: points.isNotEmpty ? _finishDrawing : null,
            tooltip: 'Finish & Analyze',
          ),
        ],
      ),
      body: Stack(
        children: [
          DrawingCanvas(
            strokes: strokes,
            currentStroke: currentStroke,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onCircleCenterCalculated: (center) {
              actualCircleCenter = center;
            },
          ),
          if (currentTouchPosition != null)
            CoordinateDisplay(
              position: currentTouchPosition!,
              pointCount: points.length,
            ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    currentStroke = [];

    DrawingPoint point = DrawingPoint(
      offset: details.localPosition,
      timestamp: DateTime.now(),
    );

    setState(() {
      currentStroke.add(point);
      points.add(point);
      currentTouchPosition = details.localPosition;
    });

    print('Start drawing at: ${point.toString()}');
  }

  void _onPanUpdate(DragUpdateDetails details) {
    DrawingPoint point = DrawingPoint(
      offset: details.localPosition,
      timestamp: DateTime.now(),
    );

    setState(() {
      currentStroke.add(point);
      points.add(point);
      currentTouchPosition = details.localPosition;
    });

    print('Drawing at: ${point.toString()}');
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      strokes.add(List.from(currentStroke));
      currentStroke = [];
      currentTouchPosition = null;
    });
    print('Stroke ended. Total points: ${points.length}');
  }

  void _clearCanvas() {
    setState(() {
      points.clear();
      strokes.clear();
      currentStroke.clear();
      currentTouchPosition = null;
    });
  }

  void _finishDrawing() {
    if (points.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AnalysisScreen(
              drawingPoints: points,
              actualCircleCenter: actualCircleCenter,
              actualRadius: actualRadius,
            ),
      ),
    );
  }

  void _showData() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Drawing Data (${points.length} points)'),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: points.length,
                itemBuilder: (context, index) {
                  String readableTime =
                      DateTime.fromMillisecondsSinceEpoch(
                        points[index].timestamp.millisecondsSinceEpoch,
                      ).toString().split('.')[0];

                  int timeDiff = 0;
                  if (points.isNotEmpty && index > 0) {
                    timeDiff =
                        points[index].timestamp.millisecondsSinceEpoch -
                        points[0].timestamp.millisecondsSinceEpoch;
                  }

                  return Text(
                    '${index + 1}: X:${points[index].offset.dx.toStringAsFixed(1)} '
                    'Y:${points[index].offset.dy.toStringAsFixed(1)} '
                    '+${timeDiff}ms\n'
                    'Time: $readableTime',
                    style: TextStyle(fontSize: 11),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }
}
