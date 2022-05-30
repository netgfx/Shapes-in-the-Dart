import 'dart:core';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/LetterParticle.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/Star.dart';
import 'package:flutter_shaders/game_classes/TDEnemy.dart';
import 'package:flutter_shaders/game_classes/TDTower.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:bezier/bezier.dart";
import "package:flutter/painting.dart" as painter;
import "../helpers//utils.dart";

class EnemyDriverCanvas extends CustomPainter {
  List<Map<String, dynamic>> points = [];

  Color color = Colors.black;
  var index = 0;
  var offset = 0;
  AnimationController? controller;
  Canvas? canvas;
  int delay = 500;
  int currentTime = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  int timeDecay = 0;
  final _random = new Random();
  int timeAlive = 0;
  int timeToLive = 24;
  double width = 100;
  double height = 100;
  int curveIndex = 0;
  var computedPoint = vectorMath.Vector2(0, 0);
  double computedAngle = 0.0;
  List<List<vectorMath.Vector2>> curve = [];
  List<CubicBezier> quadBeziers = [];
  Function? update;
  Paint _paint = new Paint();
  List<TDEnemy> enemies = [];
  List<TDTower> towers = [];
  BoxConstraints sceneSize = BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;

  /// Constructor
  EnemyDriverCanvas({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,
    required this.enemies,
    required this.towers,
    required this.curve,
    required this.quadBeziers,

    /// <--- Update Fn
    required this.update,

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
    this._paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    /// fire the animate after a delay
    if (this.delay > 0 && this.animate != null) {
      Future.delayed(Duration(milliseconds: this.delay), () => {this.animate!()});
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    paintImage(canvas, size);

    for (var i = 0; i < this.curve.length; i++) {
      drawCurve(this.curve[i], width, height, this._paint);
    }

    for (var j = 0; j < this.towers.length; j++) {
      this.towers[j].update(canvas, enemies);
    }
  }

  void paintImage(Canvas canvas, Size size) async {
    draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void draw(Canvas canvas, Size size) {
    /// check if the controller is running
    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        /// in order to run in our required frames per second
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay && this.timeAlive == 0) {
          /// reset the time

          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;

          createEnemies(canvas, true);
        } else {
          createEnemies(canvas, true);
        }
      } else {
        print("no elapsed duration");
      }
    } else {
      print("no controller running");
    }
  }

  void drawCircle(double x, double y) {
    var _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    rotate(x, y, null, () {
      canvas!.drawCircle(Offset(0, 0), 5, _paint);
    }, translate: true);
  }

  void createEnemies(Canvas canvas, bool shouldUpdate) {
    var paint = new Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = false;

    for (var i = 0; i < this.enemies.length; i++) {
      Size enemySize = this.enemies[i].getEnemySize();
      Point<double> enemyCenter = this.enemies[i].enemyCenter;
      Point<double> enemyPos = this.enemies[i].enemyPosition;
      //Utils.shared.delayedPrint(enemyPos.toString());
      if (this.enemies[i].imageState == "done") {
        /// update the enemy
        if (shouldUpdate) {
          this.enemies[i].update(canvas);
        }
      }
    }
  }

  void drawCurve(List<vectorMath.Vector2> curve, double width, double height, Paint paint) {
    rotate(curve[0].x, curve[0].y, null, () {
      final Path path = Path();

      path.moveTo(curve[0].x, curve[0].y);

      //path.relativeCubicTo(x1, y1, x2, y2)
      path.cubicTo(curve[1].x, curve[1].y, curve[2].x, curve[2].y, curve[3].x, curve[3].y);

      canvas!.drawPath(path, paint);
    });
  }

  void rotate(double? x, double? y, double? angle, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas!.save();

    if (translate) {
      canvas!.translate(_x, _y);
    }

    if (angle != null) {
      // double x1 = (_x * cos(angle)) - (_y * sin(angle));
      // double y1 = (_x * sin(angle)) + (_y * cos(angle));

      canvas!.translate(_x, _y);
      canvas?.rotate(angle);
    } else {
      //canvas?.rotate(0);
    }
    //canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}