import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_shaders/MazeGenerator.dart';
import 'package:flutter_shaders/MazePainter.dart';
import 'package:flutter_shaders/ParticleEmitter.dart';

import 'MazeGeneratorV2.dart';
import 'ShapeMaster.dart';

class MazeMode extends StatefulWidget {
  MazeMode({required Key key}) : super(key: key);

  @override
  _MazeModeState createState() => _MazeModeState();
}

class _MazeModeState extends State<MazeMode> with TickerProviderStateMixin {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 50.0;
  List<DrawingPoints?> points = [];
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.round : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.amber, Colors.black];
  Map<String, dynamic>? mazeData;
  late AnimationController _controller;
  Offset particlePoint = Offset(0, 0);
  Color _color = Colors.green;
  final _random = new Random();
  @override
  void initState() {
    super.initState();

    MazeGeneratorV2 mzg = MazeGeneratorV2(4, 6, 57392);
    // Curves.easeOutBack // explode
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    //_controller.addListener(() {setState(() {});}); no need to setState
    //_controller.drive(CurveTween(curve: Curves.bounceIn));
    //_controller.repeat();
    //_controller.forward();
    mazeData = mzg.init();

    print(mazeData);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color randomColor(double alpha) {
    int r = (_random.nextDouble() * 255).floor();
    int g = (_random.nextDouble() * 255).floor();
    int b = (_random.nextDouble() * 255).floor();
    int a = (alpha * 255).floor();

    return Color.fromARGB(a, r, g, b);
  }

  List<Widget> getCircles() {
    List<Widget> finalList = [];

    for (var i = 0; i < points.length; i++) {
      if (points[i] == null) {
        continue;
      }
      finalList.add(
        Transform.translate(
            offset: Offset(points[i]!.points.dx - 20, points[i]!.points.dy - 20),
            child: PhysicalModel(
                color: Colors.yellow,
                shape: BoxShape.circle,
                elevation: 5,
                shadowColor: Colors.orange.shade300,
                child: Container(
                  key: UniqueKey(),
                  width: 40,
                  height: 40,
                  constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black, // Color does not matter but should not be transparent
                      //borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(blurRadius: 4, offset: const Offset(0, 0), color: Colors.black, spreadRadius: 2), BoxShadow(blurRadius: 2, offset: const Offset(0, 0), color: Colors.black, spreadRadius: 8)]),
                  child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.yellow.withOpacity(0.0),
                            Colors.yellow.withOpacity(0.6),
                          ],
                          center: AlignmentDirectional(0.0, 0.0),
                          focal: AlignmentDirectional(0.0, 0.0),
                          radius: 0.6,
                          focalRadius: 0.001,
                          stops: [0.75, 1.0],
                        ),
                      )),
                ))),
      );
    }

    return finalList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade800,
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
                // RenderBox? renderBox = context.findRenderObject() as RenderBox;
                // points.add(DrawingPoints(
                //     points: renderBox.globalToLocal(details.globalPosition),
                //     paint: Paint()
                //       ..strokeCap = strokeCap
                //       ..isAntiAlias = true
                //       ..color = selectedColor.withOpacity(opacity)
                //       ..strokeWidth = strokeWidth));
                // points.add(null);
                particlePoint = details.globalPosition;
                _color = randomColor(1.0);
              });

              _controller.repeat();
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
                  //blendMode: BlendMode.srcOut,
                  child: Stack(children: [
                    Container(
                      width: viewportConstraints.maxWidth,
                      height: viewportConstraints.maxHeight,
                      color: Colors.transparent,
                      clipBehavior: Clip.none,
                    ),
                    // mazeData != null
                    //     ? Padding(
                    //         padding: EdgeInsets.only(top: 50, left: 5),
                    //         child: CustomPaint(
                    //           key: UniqueKey(),
                    //           painter: MazePainter(mazeData!, viewportConstraints.maxWidth, viewportConstraints.maxHeight, (data) {}),
                    //           isComplex: true,
                    //           willChange: false,
                    //           child: Container(),
                    //         ))
                    //   : Container(),

                    Stack(
                      children: getCircles(),
                    ),
                    // CustomPaint(
                    //   size: Size.infinite,
                    //   painter: DrawingPainter(
                    //     pointsList: points,
                    //   ),
                    // ),
                  ])),
              Transform.translate(
                  offset: particlePoint,
                  child: RepaintBoundary(
                      child: CustomPaint(
                          key: UniqueKey(),
                          isComplex: true,
                          willChange: true,
                          child: Container(),
                          // painter: ParticleEmitter(
                          //     listenable: _controller,
                          //     controller: _controller,
                          //     particleSize: Size(30, 30),
                          //     minParticles: 50,
                          //     center: Offset.zero,
                          //     color: _color,
                          //     radius: 10,
                          //     type: ShapeType.Circle,
                          //     endAnimation: EndAnimation.FADE_OUT,
                          //     particleType: ParticleType.FIRE,
                          //     spreadBehaviour: SpreadBehaviour.CONTINUOUS,
                          //     minimumSpeed: 0.4,
                          //     maximumSpeed: 0.8,
                          //     timeToLive: 500,
                          //     hasBase: true,
                          //     blendMode: BlendMode.softLight)
                          // painter: ParticleEmitter(
                          //     listenable: _controller,
                          //     controller: _controller,
                          //     particleSize: Size(50, 50),
                          //     minParticles: 30,
                          //     center: Offset.zero,
                          //     color: _color,
                          //     radius: 10,
                          //     type: ShapeType.Circle,
                          //     endAnimation: EndAnimation.FADE_OUT,
                          //     particleType: ParticleType.FIRE,
                          //     spreadBehaviour: SpreadBehaviour.CONTINUOUS,
                          //     minimumSpeed: 0.01,
                          //     maximumSpeed: 0.1,
                          //     timeToLive: {"min": 10, "max": 15},
                          //     hasBase: true,
                          //     blendMode: BlendMode.srcOver,
                          //     delay: 5)
                          painter: ParticleEmitter(
                              listenable: _controller,
                              controller: _controller,
                              particleSize: Size(50, 50),
                              minParticles: 5,
                              center: Offset.zero,
                              color: _color,
                              radius: 10,
                              type: ShapeType.Circle,
                              endAnimation: EndAnimation.NONE,
                              particleType: ParticleType.FOUNTAIN,
                              spreadBehaviour: SpreadBehaviour.CONTINUOUS,
                              minimumSpeed: 0.01,
                              maximumSpeed: 0.05,
                              timeToLive: {"min": 5000, "max": 6000},
                              hasBase: false,
                              blendMode: BlendMode.srcOver,
                              delay: 1)))),
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
        var path = Path();
        path.addOval(Rect.fromCircle(center: pointsList[i]!.points, radius: 25.0));
        //canvas.drawLine(pointsList[i]!.points, pointsList[i + 1]!.points, pointsList[i]!.paint);
        canvas.drawShadow(path.shift(Offset(pointsList[i]!.points.dx - 5, pointsList[i]!.points.dy - 5)), Colors.black54, 5.0, true);
        canvas.drawPath(path, pointsList[i]!.paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        // offsetPoints.add(pointsList[i]!.points);
        // offsetPoints.add(Offset(pointsList[i]!.points.dx + 0.1, pointsList[i]!.points.dy + 0.1));
        // canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i]!.paint);
        var path = Path();
        path.addOval(Rect.fromCircle(center: pointsList[i]!.points, radius: 25.0));
        canvas.drawShadow(path, Colors.black87, 5.0, true);
        canvas.drawPath(path, pointsList[i]!.paint);
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
