import 'dart:core';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/LetterParticle.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/Star.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;

class BorderCanvas extends CustomPainter {
  List<Map<String, dynamic>> points = [
    // test
    // {"point": Point(0.0, 0.0), "targetPoint": Point(10.0, 0.0), "direction": "x", "amount": 10.0},
    // {"point": Point(10.0, 0.0), "targetPoint": Point(10.0, 10.0), "direction": "y", "amount": 10.0},
    // {"point": Point(10.0, 10.0), "targetPoint": Point(0.0, 10.0), "direction": "x", "amount": -10.0},
    // {"point": Point(0.0, 10.0), "targetPoint": Point(0.0, 0.0), "direction": "y", "amount": -10.0},
    // end of test
    // {"point": Point(0.0, 0.0), "targetPoint": Point(10.0, 0.0)},
    // {"point": Point(20.0, 0.0), "targetPoint": Point(30.0, 0.0)},
    // {"point": Point(40.0, 0.0), "targetPoint": Point(50.0, 0.0)},
    // {"point": Point(60.0, 0.0), "targetPoint": Point(70.0, 0.0)},
    // {"point": Point(80.0, 0.0), "targetPoint": Point(90.0, 0.0)},
    // {"point": Point(90.0, 0.0), "targetPoint": Point(90.0, 10.0)},
    // {"point": Point(90.0, 20.0), "targetPoint": Point(90.0, 30.0)},
    // {"point": Point(90.0, 40.0), "targetPoint": Point(90.0, 50.0)},
    // {"point": Point(90.0, 60.0), "targetPoint": Point(90.0, 70.0)},
    // {"point": Point(90.0, 80.0), "targetPoint": Point(90.0, 90.0)},
    // {"point": Point(90.0, 90.0), "targetPoint": Point(80.0, 90.0)},
    // {"point": Point(70.0, 90.0), "targetPoint": Point(60.0, 90.0)},
    // {"point": Point(50.0, 90.0), "targetPoint": Point(40.0, 90.0)},
    // {"point": Point(30.0, 90.0), "targetPoint": Point(20.0, 90.0)},
    // {"point": Point(10.0, 90.0), "targetPoint": Point(0.0, 90.0)},
    // {"point": Point(0.0, 90.0), "targetPoint": Point(0.0, 80.0)},
    // {"point": Point(0.0, 70.0), "targetPoint": Point(0.0, 60.0)},
    // {"point": Point(0.0, 50.0), "targetPoint": Point(0.0, 40.0)},
    // {"point": Point(0.0, 30.0), "targetPoint": Point(0.0, 20.0)},
    // {"point": Point(0.0, 10.0), "targetPoint": Point(0.0, 0.0)},
  ];

  Color color = Colors.black;
  var index = 0;
  var offset = 0;
  AnimationController? controller;
  Canvas? canvas;
  double radius = 10.0;
  int delay = 500;
  int currentTime = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  ShapeType type = ShapeType.Circle;
  int timeDecay = 0;
  double? rate = 0.01;
  double endT = 0.0;
  final _random = new Random();
  int timeAlive = 0;
  int timeToLive = 24;
  int zDecay = 1000;
  double width = 100;
  double height = 100;
  int gap = 10;
  int dashWidth = 10;
  int maxDashesX = 10;
  int maxDashesY = 10;
  BoxConstraints sceneSize = BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;

  /// Constructor
  BorderCanvas({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,
    required this.dashWidth,

    ///
    required this.gap,

    /// <-- Color of the particles
    required this.color,

    /// <-- The delay until the animation starts
    required this.width,
    required this.height,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,

    /// <-- Custom callback to call after Delay has passed
    this.animate,
  }) : super(repaint: controller) {
    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();

    /// default painter

    var painter = Paint()
      ..color = this.color.withAlpha(1)
      //..blendMode = this.blendMode ?? ui.BlendMode.src
      ..style = PaintingStyle.fill;

    /// calculate points
    int dashAndGap = this.dashWidth + gap - 1;
    maxDashesX = (this.width / dashAndGap).floor();
    maxDashesY = (this.height / dashAndGap).floor();
    print("$dashAndGap MAX DASHES: $maxDashesX $maxDashesY");
    int totalDashesX = (maxDashesX);
    int totalDashesY = (maxDashesY);

    /// make points
    var counter = 0;
    var side = "x";
    var currentSide = 0;
    int posX = 0;
    int posY = 0;
    List<Map<String, dynamic>> side1 = [];
    List<Map<String, dynamic>> side2 = [];
    List<Map<String, dynamic>> side3 = [];
    List<Map<String, dynamic>> side4 = [];

    for (var i = 0; i < totalDashesX; i++) {
      posX = i == 0 ? i * dashWidth : i * dashWidth + gap * i;
      var finalPosX = posX + dashWidth;
      var point = {"point": Point(posX, posY), "targetPoint": Point(finalPosX, posY)};
      side1.add(point);
      posX = finalPosX;
    }

    for (var i = 0; i < totalDashesY; i++) {
      posY = i == 0 ? i * dashWidth : i * dashWidth + gap * i;
      var finalPosY = posY + dashWidth;
      var point = {"point": Point(posX, posY), "targetPoint": Point(posX, finalPosY)};
      side2.add(point);
      posY = finalPosY;
    }

    for (var i = 0; i < totalDashesX; i++) {
      posX = i == 0 ? i * dashWidth : i * dashWidth + gap * i;
      var finalPosX = posX + dashWidth;
      var point = {"point": Point(finalPosX, posY), "targetPoint": Point(posX, posY)};
      side3.add(point);
    }
    posX = 0;
    side3 = new List.from(side3.reversed);

    for (var i = 0; i < totalDashesY; i++) {
      posY = i == 0 ? i * dashWidth : i * dashWidth + gap * i;
      var finalPosY = posY + dashWidth;
      var point = {"point": Point(posX, finalPosY), "targetPoint": Point(posX, posY)};
      side4.add(point);
    }
    points = [];
    side4 = new List.from(side4.reversed);
    print("$side3");

    List<List<Map<String, dynamic>>> mainArr = [side1, side2, side3, side4];
    mainArr.forEach((e) => points.addAll(e));

    //print(points);

    /// fire the animate after a delay
    if (this.delay > 0 && this.animate != null) {
      Future.delayed(Duration(milliseconds: this.delay), () => {this.animate!()});
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    paintImage(canvas, size);
  }

  void paintImage(Canvas canvas, Size size) async {
    draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void draw(Canvas canvas, Size size) {
    double cx = this.sceneSize.maxWidth / 2;
    double cy = this.sceneSize.maxHeight / 2;
    var _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill;

    /// check if the controller is running
    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        /// in order to run in our required frames per second
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay && this.timeAlive == 0) {
          /// reset the time

          int elapsed = (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime);
          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;

          /// manual ticker
          endT += this.rate ?? 0.009;
          if (endT >= 1.0) {
            endT = 0.0;
            //offset = offset == 0 ? 1 : 0;
          }

          for (var i = 0; i < points.length; i++) {
            // double directionX = points[i]["direction"] == "x" ? points[i]["amount"].abs() : 0.0;
            // double directionY = points[i]["direction"] == "y" ? points[i]["amount"].abs() : 0.0;
            Map<String, dynamic> nextPos = points[i];
            if (i + 1 >= points.length) {
              nextPos = points[0];
            } else {
              nextPos = points[i + 1];
            }

            var x = ui.lerpDouble(points[i]["point"].x, nextPos["point"].x, endT)!;
            var y = ui.lerpDouble(points[i]["point"].y, nextPos["point"].y, endT)!;

            var targetX = ui.lerpDouble(points[i]["targetPoint"].x, nextPos["targetPoint"].x, endT)!;
            var targetY = ui.lerpDouble(points[i]["targetPoint"].y, nextPos["targetPoint"].y, endT)!;

            //print("$x $y");

            drawLine(x, y, targetX, targetY, _paint);
          }
        } else {
          for (var i = 0; i < points.length; i++) {
            //double directionX = points[i]["direction"] == "x" ? points[i]["amount"].abs() : 0.0;
            //double directionY = points[i]["direction"] == "y" ? (points[i]["amount"]).abs() : 0.0;
            Map<String, dynamic> nextPos = points[i];
            if (i + 1 >= points.length) {
              nextPos = points[0];
            } else {
              nextPos = points[i + 1];
            }

            var x = ui.lerpDouble(points[i]["point"].x, nextPos["point"].x, endT)!;
            var y = ui.lerpDouble(points[i]["point"].y, nextPos["point"].y, endT)!;

            var targetX = ui.lerpDouble(points[i]["targetPoint"].x, nextPos["targetPoint"].x, endT)!;
            var targetY = ui.lerpDouble(points[i]["targetPoint"].y, nextPos["targetPoint"].y, endT)!;

            drawLine(x, y, targetX, targetY, _paint);
          }
        }
      }
    } else {
      print("re-rendering points with no changes");
    }
  }

  int getSign() {
    return _random.nextBool() == false ? 1 : -1;
  }

  /// Draw the particle shape
  void drawType(double x, double y, ShapeType type, Paint painter) {
    switch (type) {
      case ShapeType.Circle:
        drawCircle(x, y, painter);
        break;
      case ShapeType.Rect:
        drawRect(x, y, painter);
        break;
      case ShapeType.RoundedRect:
        drawRRect(x, y, painter);
        break;
      case ShapeType.Triangle:
        drawPolygon(x, y, 3, painter, initialAngle: 30);
        break;
      case ShapeType.Diamond:
        drawPolygon(x, y, 4, painter, initialAngle: 0);
        break;
      case ShapeType.Pentagon:
        drawPolygon(x, y, 5, painter, initialAngle: -18);
        break;
      case ShapeType.Hexagon:
        drawPolygon(x, y, 6, painter, initialAngle: 0);
        break;
      case ShapeType.Octagon:
        drawPolygon(x, y, 8, painter, initialAngle: 0);
        break;
      case ShapeType.Decagon:
        drawPolygon(x, y, 10, painter, initialAngle: 0);
        break;
      case ShapeType.Dodecagon:
        drawPolygon(x, y, 12, painter, initialAngle: 0);
        break;
      case ShapeType.Heart:
        drawHeart(x, y, painter);
        break;
    }
  }

  void drawCircle(double x, double y, Paint paint) {
    rotate(0, 0, () {
      canvas!.drawCircle(Offset(x, y), this.radius, paint);
    });
  }

  void drawRect(double x, double y, Paint paint) {
    rotate(x, y, () {
      canvas!.drawRect(rect(), paint);
    });
  }

  void drawRRect(double x, double y, Paint paint, {double? cornerRadius}) {
    rotate(x, y, () {
      canvas!.drawRRect(RRect.fromRectAndRadius(rect(), Radius.circular(cornerRadius ?? radius * 0.2)), paint);
    });
  }

  // DRAW LINE ///////////////////////////////
  void drawLine(double x, double y, double targetX, double targetY, Paint paint) {
    rotate(0, 0, () {
      //print("$x, $y, $signX, $signY");
      canvas!.drawLine(
        Offset(x, y),
        Offset(targetX, targetY),
        paint,
      );
    });
  }

  void drawPolygon(double x, double y, int num, Paint paint, {double initialAngle = 0}) {
    rotate(x, y, () {
      final Path path = Path();
      for (int i = 0; i < num; i++) {
        final double radian = vectorMath.radians(initialAngle + 360 / num * i.toDouble());
        final double x = radius * cos(radian);
        final double y = radius * sin(radian);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas!.drawPath(path, paint);
    });
  }

  void drawCurve(double x, double y, double width, double height, Paint paint) {
    rotate(x, y, () {
      final Path path = Path();

      path.moveTo(0, y);

      path.cubicTo(x, y, x + width * 0.5, y, x + width * 0.5, y + height * 0.5);

      canvas!.drawPath(path, paint);
    });
  }

  void drawHeart(double x, double y, Paint paint) {
    rotate(x, y, () {
      final Path path = Path();

      path.moveTo(0, radius);

      path.cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0, -radius * 0.5);
      path.cubicTo(radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);

      canvas!.drawPath(path, paint);
    });
  }

  Rect rect() => Rect.fromCircle(center: Offset.zero, radius: radius);

  double doubleInRange(double start, double end) {
    if (start == end) {
      return start;
    } else {
      return _random.nextDouble() * (end - start) + start;
    }
  }

  double randomDelay({double min = 0.005, double max = 0.05}) {
    if (min == max) {
      return min;
    } else {
      return doubleInRange(min, max);
    }
  }

  void delayedPrint(String str) {
    if (DateTime.now().millisecondsSinceEpoch - this.printTime > 100) {
      this.printTime = DateTime.now().millisecondsSinceEpoch;
      print(str);
    }
  }

  void rotate(double? x, double? y, VoidCallback callback) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas!.save();
    //canvas!.translate(_x, _y);

    canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
