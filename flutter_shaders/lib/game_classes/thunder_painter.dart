import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/Star.dart';
import 'package:flutter_shaders/helpers/utils.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;

class ThunderPainter extends CustomPainter {
  Color color = Colors.black;
  List<Star> stars = [];
  AnimationController? controller;
  Canvas? canvas;
  double radius = 100.0;
  int delay = 500;
  int currentTime = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  ShapeType type = ShapeType.Circle;
  int timeDecay = 0;
  double? rate = 10;
  double endT = 0.0;
  final _random = new Random();
  int timeAlive = 0;
  int timeToLive = 24;
  int zDecay = 1000;
  List<Point> walls = [];
  BoxConstraints sceneSize = BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;
  Paint? painter;
  Paint? wallPaint;
  Paint? paintStroke;
  Size size = Size(200, 338);
  int segments = 20;
  int boltWidth = 3;
  List<Point> stageCorners = [];
  Path path = Path();

  /// Constructor
  ThunderPainter({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,

    /// <-- Color of the particles
    required this.color,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,

    /// <-- Custom callback to call after Delay has passed
    this.animate,
  }) : super(repaint: controller) {
    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();

    /// default painter

    painter = Paint()
      ..color = Colors.white
      ..blendMode = ui.BlendMode.overlay
      ..style = PaintingStyle.fill;

    paintStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    stageCorners = [
      Point(0, 0),
      Point(this.sceneSize.maxWidth, 0),
      Point(this.sceneSize.maxWidth, this.sceneSize.maxHeight),
      Point(0, this.sceneSize.maxHeight)
    ];
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

    /// check if the controller is running
    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        /// in order to run in our required frames per second
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay && this.timeAlive == 0) {
          /// reset the time

          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;

          this.makeThunder(this.size.width / 2, 0, 20, 3, false);
        } else {}
      }
    } else {
      print("re-rendering points with no changes");
    }
  }

  void makeThunder(double x, double y, int segments, double boltWidth, bool isNew) {
    painter = Paint()
      ..color = Colors.white
      ..blendMode = ui.BlendMode.overlay
      ..style = PaintingStyle.fill;
    double x = sceneSize.maxWidth / 2;
    double y = 0;

    var paintStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (isNew == true) {
      this.path = Path();
    }
    // Draw each of the segments
    for (var i = 0; i < segments; i++) {
      // Set the lightning color and bolt width
      //ctx.strokeStyle = 'rgb(255, 255, 255)';
      //ctx.lineWidth = boltWidth;

      path.moveTo(x, y);

      // Calculate an x offset from the end of the last line segment and
      // keep it within the bounds of the bitmap
      if (isNew) {
        // For a branch
        x += Utils.shared.doubleInRange(-10, 10);
      } else {
        // For the main bolt
        x += Utils.shared.doubleInRange(-30, 30);
      }
      if (x <= 10) x = 10;
      if (x >= -10) x = this.size.width - 10;

      // Calculate a y offset from the end of the last line segment.
      // When we've reached the ground or there are no more segments left,
      // set the y position to the height of the bitmap. For branches, we
      // don't care if they reach the ground so don't set the last coordinate
      // to the ground if it's hanging in the air.
      if (isNew) {
        // For a branch
        y += Utils.shared.doubleInRange(10, 20);
      } else {
        // For the main bolt
        y += Utils.shared.doubleInRange(20, this.size.height / this.segments);
      }
      if ((!isNew && i == segments - 1) || y > this.size.height) {
        y = this.size.height;
      }

      // Draw the line segment
      path.lineTo(x, y);
      //path.close();
      canvas!.drawPath(path, paintStroke);
      //ctx.stroke();

      // Quit when we've reached the ground
      if (y >= this.size.height) break;

      // Draw a branch 20% of the time off the main bolt only
      if (!isNew) {
        if (Utils.shared.chanceRoll(20)) {
          // Draws another, thinner, bolt starting from this position
          this.makeThunder(x, y, 10, 1, true);
        }
      }
    }
  }

  int getSign() {
    return _random.nextBool() == false ? 1 : -1;
  }

  Point midPoint(Point start, Point end) {
    Point out = Point(0, 0);
    out = Point((start.x + end.x) / 2, (start.y + end.y) / 2);
    return out;
  }

  double distance(x1, y1, x2, y2) {
    var dx = x1 - x2;
    var dy = y1 - y2;

    return sqrt(dx * dx + dy * dy);
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
    canvas!.translate(_x, _y);

    //canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
