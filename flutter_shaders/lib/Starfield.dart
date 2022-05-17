import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/LetterParticle.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/Star.dart';
import 'dart:ui' as ui;
import 'game_classes/alphabet_paths.dart';
import 'game_classes/number_paths.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;

class Starfield extends CustomPainter {
  List<Point<double>> points = [];

  Color color = Colors.black;
  List<Star> stars = [];
  AnimationController? controller;
  Canvas? canvas;
  double radius = 1.0;
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
  BoxConstraints sceneSize = BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;

  /// Constructor
  Starfield({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,

    /// <-- Color of the particles
    required this.color,

    /// <-- Type of particle shape (circle, rectangle, etc...)
    required this.type,

    /// <-- The delay until the animation starts
    required this.delay,

    /// <-- The rate at which the ticker runs
    this.rate,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,

    /// <-- Custom callback to call after Delay has passed
    this.animate,

    ///
    required this.sceneSize,
  }) : super(repaint: controller) {
    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();

    /// default painter

    var painter = Paint()
      ..color = this.color.withAlpha(1)
      //..blendMode = this.blendMode ?? ui.BlendMode.src
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 1200; i++) {
      Star s = Star(
        x: this._random.nextDouble() * sceneSize.maxWidth - sceneSize.maxWidth * 0.5,
        y: this._random.nextDouble() * sceneSize.maxHeight - sceneSize.maxHeight * 0.5,
        z: this._random.nextDouble() * zDecay,
        opacity: 1,
        timeAlive: 0,
        timeToLive: 500,
        currentTime: 0,
        progress: 0,
        color: Colors.white,
        radius: 1,
        painter: painter,
      );

      stars.add(s);
    }

    /// fire the animate after a delay
    if (this.delay > 0 && this.animate != null) {
      Future.delayed(Duration(milliseconds: this.delay), () => {this.animate!()});
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    canvas.drawColor(Colors.black, BlendMode.src);
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

          int elapsed = (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime);
          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;

          /// manual ticker
          // endT += this.rate ?? 0.009;
          // if (endT >= 1.0) {
          //   endT = 1.0;
          // }

          moveStars(elapsed * 0.1);

          renderStars(cx, cy, size);
        } else {
          renderStars(cx, cy, size);
        }
      }
    } else {
      print("re-rendering points with no changes");
    }
  }

  /// Render the letter particles
  void renderStars(double cx, double cy, Size size) {
    if (stars.length >= 0) {
      double x = 0;
      double y = 0;
      for (var i = 0; i < stars.length; i++) {
        x = cx + stars[i].getX() / (stars[i].getZ() * 0.001);
        y = cy + stars[i].getY() / (stars[i].getZ() * 0.001);

        if (x < 0 || x >= this.sceneSize.maxWidth || y < 0 || y >= this.sceneSize.maxHeight) {
          continue;
        }

        double d = (stars[i].z / zDecay);
        double b = 1 - d * d;

        putPixel(x, y, b);

        //drawType(0, 0, this.type, painter);
      }
    }
  }

  void putPixel(double x, double y, double brightness) {
    int intensity = (brightness * 255).round();

    var painter = Paint()
      ..color = Color.fromARGB(255, intensity, intensity, intensity)
      //..blendMode = this.blendMode ?? ui.BlendMode.src
      ..style = PaintingStyle.fill;
    drawRect(x, y, painter);
  }

  void moveStars(distance) {
    int count = stars.length;
    for (var i = 0; i < count; i++) {
      stars[i].z -= distance;

      while (stars[i].z <= 1) {
        stars[i].z += zDecay;
      }
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
      case ShapeType.Star5:
        drawStar(x, y, 10, painter, initialAngle: 15);
        break;
      case ShapeType.Star6:
        drawStar(x, y, 12, painter, initialAngle: 0);
        break;
      case ShapeType.Star7:
        drawStar(x, y, 14, painter, initialAngle: 0);
        break;
      case ShapeType.Star8:
        drawStar(x, y, 16, painter, initialAngle: 0);
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

  void drawHeart(double x, double y, Paint paint) {
    rotate(x, y, () {
      final Path path = Path();

      path.moveTo(0, radius);

      path.cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0, -radius * 0.5);
      path.cubicTo(radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);

      canvas!.drawPath(path, paint);
    });
  }

  void drawStar(double x, double y, int num, Paint paint, {double initialAngle = 0}) {
    rotate(x, y, () {
      final Path path = Path();
      for (int i = 0; i < num; i++) {
        final double radian = vectorMath.radians(initialAngle + 360 / num * i.toDouble());
        final double x = radius * (i.isEven ? 0.5 : 1) * cos(radian);
        final double y = radius * (i.isEven ? 0.5 : 1) * sin(radian);
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
    canvas!.translate(_x, _y);

    //canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
