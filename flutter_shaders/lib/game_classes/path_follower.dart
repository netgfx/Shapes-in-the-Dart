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
import "package:bezier/bezier.dart";
import "../helpers//utils.dart";

class PathFollowerCanvas extends CustomPainter {
  List<Map<String, dynamic>> points = [];

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
  int timeDecay = 0;
  double? rate = 0.005;
  double endT = 0.0;
  final _random = new Random();
  int timeAlive = 0;
  int timeToLive = 24;
  double width = 100;
  double height = 100;
  int curveIndex = 0;
  var computedPoint = vectorMath.Vector2(0, 0);
  double computedAngle = 0.0;
  List<List<vectorMath.Vector2>> curve = [];
  List<QuadraticBezier> quadBeziers = [];

  BoxConstraints sceneSize = BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;

  /// Constructor
  PathFollowerCanvas({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,

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

    this.curve = [
      [
        vectorMath.Vector2(50, height - 100),
        vectorMath.Vector2(50, height - 250),
        vectorMath.Vector2(150, height - 250),
      ],
      [
        vectorMath.Vector2(150, height - 250),
        vectorMath.Vector2(350, height - 250),
        vectorMath.Vector2(350, height - 400),
      ],
      [
        vectorMath.Vector2(350, height - 400),
        vectorMath.Vector2(150, height - 350),
        vectorMath.Vector2(150, height - 500),
      ]
    ];

    quadBeziers = [];
    for (var i = 0; i < this.curve.length; i++) {
      quadBeziers.add(QuadraticBezier(this.curve[i]));
    }

    /// fire the animate after a delay
    if (this.delay > 0 && this.animate != null) {
      Future.delayed(Duration(milliseconds: this.delay), () => {this.animate!()});
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill;
    this.canvas = canvas;
    paintImage(canvas, size);
    //computedPoint = getCurvePoint(0.0);
    //vectorMath.Vector2 nextPoint = getNextPoint(this.endT);
    //computedAngle = Utils.shared.radToDeg(Utils.shared.angleBetween(computedPoint.x, computedPoint.y, nextPoint.x, nextPoint.y));
    //drawPolygon(computedPoint.x, computedPoint.y, 3, _paint, initialAngle: computedAngle);
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
      ..style = PaintingStyle.stroke;

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
          if (endT >= 1.0 && this.curveIndex < this.curve.length) {
            endT = 0.0;
            this.curveIndex += 1;
            //offset = offset == 0 ? 1 : 0;
          }
          if (this.curveIndex >= this.curve.length) {
            endT = 1.0;
            this.curveIndex = this.curve.length;
          }

          for (var i = 0; i < this.curve.length; i++) {
            drawCurve(this.curve[i], width, height, _paint);
          }

          // paint the ball
          vectorMath.Vector2 oldValues = computedPoint;
          computedPoint = getCurvePoint(this.endT);
          //vectorMath.Vector2 nextPoint = getNextPoint(this.endT);
          computedAngle = Utils.shared.radToDeg(Utils.shared.angleBetween(oldValues.x, oldValues.y, computedPoint.x, computedPoint.y));
          //delayedPrint("Angle: $computedAngle ${oldValues.x}, ${oldValues.y}, ${computedPoint.x}, ${computedPoint.y}");
          if (computedAngle == 0.0 && this.curveIndex == this.curve.length) {
            computedAngle = -90.0;
          }
          drawPolygon(computedPoint.x, computedPoint.y, 3, _paint..style = PaintingStyle.fill, initialAngle: computedAngle);
          //drawCircle(computedPoint.x, computedPoint.y, _paint);
        } else {
          for (var i = 0; i < this.curve.length; i++) {
            drawCurve(this.curve[i], width, height, _paint);
          }
          drawPolygon(computedPoint.x, computedPoint.y, 3, _paint..style = PaintingStyle.fill, initialAngle: computedAngle);
          //drawCircle(computedPoint.x, computedPoint.y, _paint);
        }
      }
    } else {
      print("no controller running");
    }
  }

  vectorMath.Vector2 getNextPoint(double perc) {
    vectorMath.Vector2 nextPoint = vectorMath.Vector2(0, 0);
    if (perc + 0.05 > 1) {
      nextPoint = this.quadBeziers[(this.curveIndex + 1).clamp(0, this.curve.length - 1)].pointAt(0);
    } else {
      nextPoint = this.quadBeziers[(this.curveIndex + 1).clamp(0, this.curve.length - 1)].pointAt(perc + 0.1);
    }

    return nextPoint;
  }

  vectorMath.Vector2 getCurvePoint(double perc, {int? index: null}) {
    int _index = index ?? this.curveIndex.clamp(0, this.curve.length - 1);
    //delayedPrint('>>> ${(perc.clamp(0, 1)).toString()} ${curveIndex}');
    var _perc = perc;
    if (perc < 0) {
      _perc = 0;
    } else if (perc > 1) {
      _perc = 1;
    } else {
      _perc = perc.clamp(0, 1);
    }
    return quadBeziers[_index].pointAt(_perc);
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
        //delayedPrint("$x, $y, $radian");
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas!.drawPath(path, paint);
    }, translate: true);
  }

  void drawCurve(List<vectorMath.Vector2> curve, double width, double height, Paint paint) {
    rotate(curve[0].x, curve[0].y, () {
      final Path path = Path();

      path.moveTo(curve[0].x, curve[0].y);

      path.cubicTo(curve[0].x, curve[0].y, curve[1].x, curve[1].y, curve[2].x, curve[2].y);

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
    if (DateTime.now().millisecondsSinceEpoch - this.printTime > 10) {
      this.printTime = DateTime.now().millisecondsSinceEpoch;
      print(str);
    }
  }

  void rotate(double? x, double? y, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas!.save();
    if (translate) {
      canvas!.translate(_x, _y);
    }
    canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
