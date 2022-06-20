import 'dart:core';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/LetterParticle.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/Star.dart';
import 'package:flutter_shaders/game_classes/maze/maze_builder.dart';
import 'package:flutter_shaders/game_classes/pathfinding/MazeLocation.dart' as ML;
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:bezier/bezier.dart";
import "../../helpers/utils.dart";

class MazeDrawCanvas extends CustomPainter {
  List<Map<String, dynamic>> points = [];

  Color color = Colors.black;
  var index = 0;
  var offset = 0;
  AnimationController? controller;
  Canvas? canvas;
  Paint _paint = Paint();
  double radius = 10.0;
  int delay = 500;
  int currentTime = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  int timeDecay = 0;
  double? rate = 0.001;
  double endT = 0.0;
  final _random = new Random();
  int timeAlive = 0;
  int timeToLive = 24;
  int blockSize = 8;
  List<List<Cell>> maze = [];
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;
  bool isMazeDrawn = false;
  List<ML.MazeLocation> solution = [];

  /// Constructor
  MazeDrawCanvas({
    /// <-- Color of the particles
    required this.color,
    required this.maze,

    /// <-- The delay until the animation starts
    required this.blockSize,
    solution,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,

    /// <-- Custom callback to call after Delay has passed
    this.animate,
  }) {
    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();

    /// default painter

    var painter = Paint()
      ..color = this.color.withAlpha(1)
      //..blendMode = this.blendMode ?? ui.BlendMode.src
      ..style = PaintingStyle.fill;

    if (solution != null) {
      this.solution = solution;
    }

    /// fire the animate after a delay
    if (this.delay > 0 && this.animate != null) {
      Future.delayed(Duration(milliseconds: this.delay), () => {this.animate!()});
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill;
    this.canvas = canvas;
    //paintImage(canvas, size);
    //if (isMazeDrawn == false) {
    makeBlocks();
    drawPath();
    //}
  }

  void paintImage(Canvas canvas, Size size) async {
    draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void draw(Canvas canvas, Size size) {
    /// nothing to do
  }

  makeBlocks() {
    int mazeLength = maze.length;
    for (var i = 0; i < mazeLength; i++) {
      for (var j = 0; j < maze[i].length; j++) {
        getBlockLines(maze[i][j], i);
      }
    }

    isMazeDrawn = true;
  }

  getBlockLines(Cell cell, int index) {
    //var lines = [];
    //print(cell);
    int size = this.blockSize;
    if (cell.top) {
      double x1 = cell.x * size;
      double y1 = cell.y * size;
      double x2 = cell.x * size + size;
      double y2 = cell.y * size;
      drawLine(x1, y1, x2, y2, _paint);
    }
    if (cell.bottom) {
      double x1 = cell.x * size;
      double y1 = cell.y * size + size;
      double x2 = cell.x * size + size;
      double y2 = cell.y * size + size;

      drawLine(x1, y1, x2, y2, _paint);
    }
    if (cell.left) {
      double x1 = cell.x * size;
      double y1 = cell.y * size;
      double x2 = cell.x * size;
      double y2 = cell.y * size + size;

      drawLine(x1, y1, x2, y2, _paint);
    }
    if (cell.right) {
      double x1 = cell.x * size + size;
      double y1 = cell.y * size;
      double x2 = cell.x * size + size;
      double y2 = cell.y * size + size;

      drawLine(x1, y1, x2, y2, _paint);
    }
  }

  void drawPath() {
    if (this.solution.length > 0) {
      this.radius = 4;
      for (var i = 0; i < this.solution.length; i++) {
        drawCircle((this.solution[i].getRow() * this.blockSize + this.blockSize * 0.5).toDouble(),
            (this.solution[i].getCol() * this.blockSize + this.blockSize * 0.5).toDouble(), _paint);
      }
    }
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

      //path.relativeCubicTo(x1, y1, x2, y2)
      path.cubicTo(curve[1].x, curve[1].y, curve[2].x, curve[2].y, curve[3].x, curve[3].y);

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
