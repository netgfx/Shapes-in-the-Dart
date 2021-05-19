import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class MazeMode extends StatefulWidget {
  MazeMode({required Key key}) : super(key: key);

  @override
  _MazeModeState createState() => _MazeModeState();
}

class _MazeModeState extends State<MazeMode> {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 25.0;
  List<DrawingPoints?> points = [];
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.round : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.amber, Colors.black];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.purple,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), color: Colors.black),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.album),
                            onPressed: () {
                              setState(() {
                                if (selectedMode == SelectedMode.StrokeWidth) showBottomList = !showBottomList;
                                selectedMode = SelectedMode.StrokeWidth;
                              });
                            }),
                        IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.opacity),
                            onPressed: () {
                              setState(() {
                                if (selectedMode == SelectedMode.Opacity) showBottomList = !showBottomList;
                                selectedMode = SelectedMode.Opacity;
                              });
                            }),
                        IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                showBottomList = false;
                                points.clear();
                              });
                            }),
                      ],
                    ),
                  ],
                ),
              )),
        ),
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return GestureDetector(
            onTapDown: (details) {
              setState(() {
                RenderBox? renderBox = context.findRenderObject() as RenderBox;
                points.add(DrawingPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: Paint()
                      ..strokeCap = strokeCap
                      ..isAntiAlias = true
                      ..color = selectedColor.withOpacity(opacity)
                      ..strokeWidth = strokeWidth));
                points.add(null);
              });
            },
            onTapCancel: () {
              setState(() {
                points.add(null);
              });
            },
            // onPanUpdate: (details) {
            //   setState(() {
            //     RenderBox? renderBox = context.findRenderObject() as RenderBox;
            //     points.add(DrawingPoints(
            //         points: renderBox.globalToLocal(details.globalPosition),
            //         paint: Paint()
            //           ..strokeCap = strokeCap
            //           ..isAntiAlias = true
            //           ..color = selectedColor.withOpacity(opacity)
            //           ..strokeWidth = strokeWidth));
            //   });
            // },
            // onPanStart: (details) {
            //   setState(() {
            //     RenderBox renderBox = context.findRenderObject() as RenderBox;
            //     points.add(DrawingPoints(
            //         points: renderBox.globalToLocal(details.globalPosition),
            //         paint: Paint()
            //           ..strokeCap = strokeCap
            //           ..isAntiAlias = true
            //           ..color = selectedColor.withOpacity(opacity)
            //           ..strokeWidth = strokeWidth));
            //   });
            // },
            // onPanEnd: (details) {
            //   setState(() {
            //     points.add(null);
            //   });
            // },
            child: Stack(children: [
              ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return RadialGradient(
                      radius: 50,
                      center: Alignment.topCenter,
                      colors: <Color>[Colors.black, Colors.black54],
                      tileMode: TileMode.clamp,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcOut,
                  child: Stack(children: [
                    Container(
                      width: viewportConstraints.maxWidth,
                      height: viewportConstraints.maxHeight,
                      color: Colors.transparent,
                      clipBehavior: Clip.none,
                    ),
                    CustomPaint(
                      size: Size.infinite,
                      painter: DrawingPainter(
                        pointsList: points,
                      ),
                    ),
                  ]))
            ]),
          );
        }));
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({required this.pointsList});
  List<DrawingPoints?> pointsList;
  List<Offset> offsetPoints = [];
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i]!.points, pointsList[i + 1]!.points, pointsList[i]!.paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i]!.points);
        offsetPoints.add(Offset(pointsList[i]!.points.dx + 0.1, pointsList[i]!.points.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({required this.points, required this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }
