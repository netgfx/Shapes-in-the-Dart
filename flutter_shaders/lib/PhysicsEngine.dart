import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/LetterParticle.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/Star.dart';
import 'package:flutter_shaders/physics_object.dart';
import 'dart:ui' as ui;
import 'alphabet_paths.dart';
import 'number_paths.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;

class PhysicsEngine extends CustomPainter {
  List<Square> gameObjects = [];

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
  PhysicsEngine({
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
    double cx = this.sceneSize.maxWidth / 2;
    double cy = this.sceneSize.maxHeight / 2;

    for (var i = 0; i < 10; i++) {
      this.gameObjects.add(Square(
          canvas: canvas,
          paint: painter,
          type: ShapeType.Circle,
          x: cx,
          y: this._random.nextDouble() * sceneSize.maxHeight - sceneSize.maxHeight * 0.15,
          vx: this._random.nextInt(50).toDouble(),
          vy: doubleInRange(-50, 50),
          mass: 1));
    }

    this.gameObjects.add(Square(
        canvas: canvas,
        paint: painter,
        type: ShapeType.Circle,
        x: cx,
        y: this._random.nextDouble() * sceneSize.maxHeight - sceneSize.maxHeight * 0.15,
        vx: this._random.nextInt(50).toDouble(),
        vy: doubleInRange(-50, 50),
        mass: 100,
        radius: 40));

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
    /// check if the controller is running
    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        /// in order to run in our required frames per second
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay && this.timeAlive == 0) {
          /// reset the time

          int elapsed = (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime);
          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;

          for (var i = 0; i < gameObjects.length; i++) {
            gameObjects[i].update(endT);
          }

          detectCollisions();

          detectEdgeCollisions();

          for (var i = 0; i < this.gameObjects.length; i++) {
            this.gameObjects[i].draw(this.canvas!);
          }

          /// manual ticker
          endT = this.rate ?? 0.1;

          //delayedPrint("$elapsed - $endT");
        } else {
          for (var i = 0; i < gameObjects.length; i++) {
            gameObjects[i].update(endT);
            gameObjects[i].draw(this.canvas!);
          }
        }
      }
    } else {
      print("re-rendering points with no changes");
    }
  }

  void detectCollisions() {
    Square obj1;
    Square obj2;

    for (var i = 0; i < this.gameObjects.length; i++) {
      this.gameObjects[i].isColliding = false;
    }

    for (var i = 0; i < this.gameObjects.length; i++) {
      obj1 = this.gameObjects[i];
      for (var j = i + 1; j < this.gameObjects.length; j++) {
        obj2 = this.gameObjects[j];

        if (this.circleIntersect(obj1.x, obj1.y, obj1.getWidth(), obj2.x, obj2.y, obj2.getWidth())) {
          //this.rectIntersect(obj1.x, obj1.y, obj1.getWidth(), obj1.getHeight(), obj2.x, obj2.y, obj2.getWidth(), obj2.getHeight())) {
          obj1.isColliding = true;
          obj2.isColliding = true;

          var vCollision = {"x": obj2.x - obj1.x, "y": obj2.y - obj1.y};
          var distance = sqrt((obj2.x - obj1.x) * (obj2.x - obj1.x) + (obj2.y - obj1.y) * (obj2.y - obj1.y));
          var vCollisionNorm = {"x": vCollision["x"]! / distance, "y": vCollision["y"]! / distance};
          var vRelativeVelocity = {"x": obj1.vx - obj2.vx, "y": obj1.vy - obj2.vy};
          var speed = vRelativeVelocity["x"]! * vCollisionNorm["x"]! + vRelativeVelocity["y"]! * vCollisionNorm["y"]!;

          speed *= min(obj1.restitution, obj2.restitution);
          delayedPrint(speed.toString());
          if (speed < 0) {
            break;
          }

          var impulse = 2 * speed / (obj1.getMass() + obj2.getMass());
          obj1.vx -= (impulse * obj2.mass * vCollisionNorm["x"]!);
          obj1.vy -= (impulse * obj2.mass * vCollisionNorm["y"]!);
          obj2.vx += (impulse * obj1.mass * vCollisionNorm["x"]!);
          obj2.vy += (impulse * obj1.mass * vCollisionNorm["y"]!);
        }
      }
    }
  }

  void detectEdgeCollisions() {
    Square obj;
    for (var i = 0; i < gameObjects.length; i++) {
      obj = gameObjects[i];

      // Check for left and right
      if (obj.x < obj.radius!) {
        obj.vx = (obj.vx).abs() * obj.getRestitution();
        obj.x = obj.getWidth().toDouble();
      } else if (obj.x > sceneSize.maxWidth - obj.getHeight().toDouble()) {
        obj.vx = -(obj.vx).abs() * obj.getRestitution();
        obj.x = sceneSize.maxWidth - obj.radius!;
      }

      // Check for bottom and top
      if (obj.y < obj.radius!) {
        obj.vy = (obj.vy).abs() * obj.getRestitution();
        obj.y = obj.getHeight().toDouble();
      } else if (obj.y > sceneSize.maxHeight - obj.getHeight().toDouble()) {
        obj.vy = -(obj.vy).abs() * obj.getRestitution();
        obj.y = sceneSize.maxHeight - obj.getHeight().toDouble();
      }
    }
  }

  rectIntersect(x1, y1, w1, h1, x2, y2, w2, h2) {
    // Check x and y for overlap
    if (x2 > w1 + x1 || x1 > w2 + x2 || y2 > h1 + y1 || y1 > h2 + y2) {
      return false;
    }
    return true;
  }

  circleIntersect(x1, y1, r1, x2, y2, r2) {
    // Calculate the distance between the two circles
    var squareDistance = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);

    // When the distance is smaller or equal to the sum
    // of the two radius, the circles touch or overlap
    return squareDistance <= ((r1 + r2) * (r1 + r2));
  }

  double doubleInRange(double start, double end) {
    if (start == end) {
      return start;
    } else {
      return _random.nextDouble() * (end - start) + start;
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

  double randomDelay({double min = 0.005, double max = 0.05}) {
    if (min == max) {
      return min;
    } else {
      return doubleInRange(min, max);
    }
  }

  double easeOutBack(double x) {
    const c1 = 1.70158;
    const c3 = c1 + 1;

    return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2);
  }

  double easeOutCirc(double x) {
    return sqrt(1 - pow(x - 1, 2));
  }

  double easeOutQuart(double x) {
    return 1 - pow(1 - x, 4).toDouble();
  }

  double easeOutQuad(double x) {
    return 1 - (1 - x) * (1 - x);
  }

  double easeOutCubic(double x) {
    return 1 - pow(1 - x, 3).toDouble();
  }

  double easeOutSine(double x) {
    return sin((x * pi) / 2);
  }

  double easeOutQuint(double x) {
    return 1 - pow(1 - x, 5).toDouble();
  }

  double easeInOutBack(double x) {
    const c1 = 1.70158;
    const c2 = c1 * 1.525;

    return x < 0.5 ? (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2 : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
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
