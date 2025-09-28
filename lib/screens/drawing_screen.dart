import 'package:drawingdemo/models/drawing_point.dart';
import 'package:flutter/material.dart';

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<DrawingPoint> points = [];
  List<List<DrawingPoint>> strokes = [];
  List<DrawingPoint> currentStroke = [];
  Offset? currentTouchPosition;
  Offset? actualCircleCenter; // Store actual circle center
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
          Container(
            width: double.infinity,
            height: double.infinity,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: DrawingPainter(
                  strokes: strokes,
                  currentStroke: currentStroke,
                  onCircleCenterCalculated: (center) {
                    actualCircleCenter = center;
                  },
                ),
                size: Size.infinite,
              ),
            ),
          ),
          // Coordinate display
          if (currentTouchPosition != null)
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'X: ${currentTouchPosition!.dx.toStringAsFixed(1)}\n'
                  'Y: ${currentTouchPosition!.dy.toStringAsFixed(1)}\n'
                  'Points: ${points.length}',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
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
                      ).toString().split('.')[0]; // Remove microseconds

                  // Calculate time difference from first point
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
