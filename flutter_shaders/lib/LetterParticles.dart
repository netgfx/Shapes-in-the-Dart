import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/LetterParticle.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'dart:ui' as ui;
import 'alphabet_paths.dart';
import 'number_paths.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;

enum CharacterParticleEffect { NONE, JITTER, SPREAD, FADEIN, FADEOUT, EXPLODE, MATRIX, TREX }

class LetterParticles extends CustomPainter {
  List<Point<double>> points = [];
  String character;
  Color color = Colors.black;
  double radius = 20.0;
  AnimationController? controller;
  Canvas? canvas;
  double angle = 0;
  double delay = 500;
  int currentTime = 0;
  int fps = 24;
  ShapeType type = ShapeType.Circle;
  int timeDecay = 250;
  double rate = 0.042;
  final _random = new Random();
  int timeAlive = 0;
  int timeToLive = 24;
  bool jitter = false;
  CharacterParticleEffect effect = CharacterParticleEffect.NONE;
  Map<String, dynamic> box = {};
  Point<double> centroid = Point(0.0, 0.0);
  List<LetterParticle> particles = [];
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;
  LetterParticles(
      {required this.character,
      required this.controller,
      required this.fps,
      required this.color,
      required this.radius,
      required this.type,
      required this.effect,
      required this.delay,
      this.blendMode,
      this.animate})
      : super(repaint: controller) {
    print("draw");

    /// safeguard
    this.character = this.character.toUpperCase();
    this.timeDecay = (1 / this.fps * 1000).round();
    Paint fill = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;
    List<double>? points = [];

    if (int.tryParse(this.character) == null) {
      points = alphabetPaths[this.character];
    } else {
      points = numberPaths[this.character];
    }
    print("CHARACTER: $character POINTS: ${points?.length}");
    double maxX = 0;
    double minX = 10000;
    double maxY = 0;
    double minY = 10000;
    for (var i = 0; i < points!.length; i += 2) {
      /// find the max and min

      if (points[i] < minX) {
        minX = points[i];
      }
      if (points[i] > maxX) {
        maxX = points[i];
      }
      if (points[i + 1] < minY) {
        minY = points[i + 1];
      }
      if (points[i + 1] > maxY) {
        maxY = points[i + 1];
      }
    }

    /// calculate the offset position and assign to `ParticleLetter`
    for (var i = 0; i < points.length; i += 2) {
      double offsetX = minX - 4;
      double offsetY = minY - 3;

      double finalX = points[i] - offsetX;
      double finalY = points[i + 1] - offsetY;
      if (finalX < 0) {
        finalX = 0;
      }
      if (finalY < 0) {
        finalY = 0;
      }
      double randX = 0;
      double randY = 0;
      if (this.effect == CharacterParticleEffect.SPREAD) {
        randX = doubleInRange(-200, 200);
        randY = doubleInRange(-200, 200);
      } else if (this.effect == CharacterParticleEffect.FADEIN) {
        fill = Paint()
          ..color = this.color.withAlpha(0)
          //..blendMode = this.blendMode ?? ui.BlendMode.src
          ..style = PaintingStyle.fill;
      }

      if (character == "I") {
        print("$finalX, $finalY - ${points[i]} ${points[i + 1]} $offsetY, $i");
      }

      particles.add(
        LetterParticle(
            color: this.color,
            x: randX,
            y: randY,
            renderDelay: 0,
            opacity: 1.0,
            radius: this.radius,
            timeToLive: this.timeToLive.toDouble(),
            speed: this.rate,
            painter: fill,
            timeAlive: 0,
            currentTime: 0,
            endPath: Point(finalX, finalY)),
      );
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
    if (this.timeAlive > this.timeToLive) {
      return;
    }

    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= delay && this.timeAlive == 0) {
          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;
          //this.timeAlive += 1;
          this.rate += 0.05;
          if (this.rate > 1.0) {
            this.rate = 1.0;
          }

          // check if it has ended running

          print("making a $type");

          renderLetter(particles);
        } else if (this.timeAlive > 0) {
          this.currentTime = DateTime.now().millisecondsSinceEpoch;
          //this.timeAlive += 1;
          this.rate += 0.05;
          if (this.rate > 1.0) {
            this.rate = 1.0;
          }

          // check if it has ended running
          //print("making a $type timeAlive > 0");
          renderLetter(particles);
        } else {
          renderLetter(particles);
        }
      } else {
        print("re-rendering points");
        renderLetter(particles);
      }
    } else {
      print("no controller");
      renderLetter(particles);
    }
  }

  void renderLetter(List<LetterParticle>? points) {
    if (points != null) {
      ///

      for (var i = 0; i < points.length; i++) {
        double finalX = points[i].getEndPath().x.toDouble();
        double finalY = points[i].getEndPath().y.toDouble();
        if (this.effect == CharacterParticleEffect.TREX) {
          double randX = doubleInRange(finalX - 1.5, finalX + 1.5);
          double randY = doubleInRange(finalY - 1.5, finalY + 1.5);
          finalX = ui.lerpDouble(randX, finalX, this.controller!.value)!;
          finalY = ui.lerpDouble(randY, finalY, this.controller!.value)!;
          //finalY + doubleInRange(finalY - 0.2 * getSign(), finalY + 0.2 * getSign());
        } else if (this.effect == CharacterParticleEffect.JITTER) {
          double randX = doubleInRange(finalX - 1.5, finalX + 1.5);
          double randY = doubleInRange(finalY - 1.5, finalY + 1.5);
          print(this.controller!.value);
          finalX = doubleInRange(randX, finalX);
          finalY = doubleInRange(randY, finalY);
        } else if (this.effect == CharacterParticleEffect.SPREAD) {
          finalX = ui.lerpDouble(points[i].getX(), finalX, this.controller!.value)!;
          finalY = ui.lerpDouble(points[i].getY(), finalY, this.controller!.value)!;
        } else if (this.effect == CharacterParticleEffect.FADEIN) {
          int newAlpha = ui.lerpDouble(0, 255, this.controller!.value)!.round();
          points[i].painter = Paint()
            ..color = this.color.withAlpha(newAlpha)
            //..blendMode = this.blendMode ?? ui.BlendMode.src
            ..style = PaintingStyle.fill;
        }

        drawType(finalX, finalY, this.type, points[i].painter!);
      }
    }
  }

  int getSign() {
    return _random.nextBool() == false ? 1 : -1;
  }

  void drawType(double x, double y, ShapeType type, Paint painter) {
    switch (type) {
      case ShapeType.Circle:
        drawCircle(x, y, painter);
        break;
      case ShapeType.Rect:
        drawRect(painter);
        break;
      case ShapeType.RoundedRect:
        drawRRect(painter);
        break;
      case ShapeType.Triangle:
        drawPolygon(3, painter, initialAngle: 30);
        break;
      case ShapeType.Diamond:
        drawPolygon(4, painter, initialAngle: 0);
        break;
      case ShapeType.Pentagon:
        drawPolygon(5, painter, initialAngle: -18);
        break;
      case ShapeType.Hexagon:
        drawPolygon(6, painter, initialAngle: 0);
        break;
      case ShapeType.Octagon:
        drawPolygon(8, painter, initialAngle: 0);
        break;
      case ShapeType.Decagon:
        drawPolygon(10, painter, initialAngle: 0);
        break;
      case ShapeType.Dodecagon:
        drawPolygon(12, painter, initialAngle: 0);
        break;
      case ShapeType.Heart:
        drawHeart(painter);
        break;
      case ShapeType.Star5:
        drawStar(10, painter, initialAngle: 15);
        break;
      case ShapeType.Star6:
        drawStar(12, painter, initialAngle: 0);
        break;
      case ShapeType.Star7:
        drawStar(14, painter, initialAngle: 0);
        break;
      case ShapeType.Star8:
        drawStar(16, painter, initialAngle: 0);
        break;
    }
  }

  void drawCircle(double x, double y, Paint paint) {
    rotate(() {
      canvas!.drawCircle(Offset(x, y), this.radius, paint);
    });
  }

  void drawRect(Paint paint) {
    rotate(() {
      canvas!.drawRect(rect(), paint);
    });
  }

  void drawRRect(Paint paint, {double? cornerRadius}) {
    rotate(() {
      canvas!.drawRRect(RRect.fromRectAndRadius(rect(), Radius.circular(cornerRadius ?? radius * 0.2)), paint);
    });
  }

  void drawPolygon(int num, Paint paint, {double initialAngle = 0}) {
    rotate(() {
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

  void drawHeart(Paint paint) {
    rotate(() {
      final Path path = Path();

      path.moveTo(0, radius);

      path.cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0, -radius * 0.5);
      path.cubicTo(radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);

      canvas!.drawPath(path, paint);
    });
  }

  void drawStar(int num, Paint paint, {double initialAngle = 0}) {
    rotate(() {
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

  void rotate(VoidCallback callback) {
    var scale = 1.0;
    canvas!.save();

    if (scale != 1.0) {
      //canvas!.translate(this.p0.x + _x, this.p0.y + _y);
      var matrix = Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)..scale(scale);
      //..translate(this.p0.x - _x, this.p0.y - _y);
      canvas!.transform(matrix.storage);
      //canvas!.scale(scale);
    }

    //canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
