import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_shaders/game_classes/maze/maze_builder.dart';
import 'package:flutter_shaders/game_classes/pathfinding/MazeLocation.dart' as ML;
import 'package:flutter_shaders/helpers/MazePlayer.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;

class MazePlayerDrawer {
  Color color = Colors.red;
  Canvas? canvas;
  Paint _paint = Paint();
  double radius = 5.0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  final _random = new Random();
  int blockSize = 8;
  List<List<Cell>> maze = [];
  ui.BlendMode? blendMode = ui.BlendMode.src;
  List<ML.MazeLocation> solution = [];
  Point playerXY = Point(0, 0);

  bool maxRightReached = false;

  /// Constructor
  MazePlayerDrawer({
    /// <-- The delay until the animation starts
    required this.blockSize,
    solution,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,
  }) {
    /// default painter

    _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill;

    if (solution != null) {
      this.solution = solution;
    }
  }

  void update(Canvas canvas, MazePlayer playerData) {
    this.canvas = canvas;
    this.playerXY = Point(playerData.x, playerData.y);
    drawCircle(this.playerXY.x.toDouble() + this.blockSize / 2, this.playerXY.y.toDouble() + this.blockSize / 2);
  }

  void drawCircle(double x, double y) {
    updateCanvas(0, 0, () {
      canvas!.drawCircle(Offset(x, y), this.radius, _paint);
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
      //print(str);
    }
  }

  void updateCanvas(double? x, double? y, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas!.save();
    if (translate) {
      canvas!.translate(_x, _y);
    }
    //canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
