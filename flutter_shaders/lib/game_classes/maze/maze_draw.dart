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
import 'package:flutter_shaders/helpers/Camera.dart';
import 'package:flutter_shaders/helpers/MazePlayer.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:bezier/bezier.dart";
import "../../helpers/utils.dart";

class MazeDrawer {
  Color color = Colors.black;
  Canvas? canvas;
  Paint _paint = Paint();
  double radius = 10.0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  final _random = new Random();
  int blockSize = 8;
  List<List<Cell>> maze = [];
  ui.BlendMode? blendMode = ui.BlendMode.src;
  bool isMazeDrawn = false;
  List<ML.MazeLocation> solution = [];
  Rect _bounds = Rect.fromLTWH(0, 0, 0, 0);

  bool maxRightReached = false;

  /// Constructor
  MazeDrawer({
    required this.maze,

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

  void update(Canvas canvas, Rect bounds) {
    this.canvas = canvas;
    this._bounds = bounds;
    makeBlocks();
    drawPath();
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

  void drawCircle(double x, double y, Paint paint) {
    updateCanvas(0, 0, () {
      canvas!.drawCircle(Offset(x, y), this.radius, paint);
    });
  }

  // DRAW LINE ///////////////////////////////
  void drawLine(double x, double y, double targetX, double targetY, Paint paint) {
    //Rect bounds = _camera!.getCameraBounds();

    updateCanvas(this._bounds.left * -1, this._bounds.top, () {
      //print("$x, $y, $signX, $signY");
      canvas!.drawLine(
        Offset(x, y),
        Offset(targetX, targetY),
        paint,
      );
    }, translate: true);
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
