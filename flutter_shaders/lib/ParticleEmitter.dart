import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import 'ShapeMaster.dart';

class ParticleEmitter extends CustomPainter {
  final Animation listenable;
  ShapeType type = ShapeType.Rect;
  Size size = Size(20, 20);
  double radius = 0.0;
  Canvas? canvas;
  Offset center = Offset(0, 0);
  double? angle = 0;
  List<Map<String, dynamic>> particles = [];
  Color color = Colors.orange;
  int minParticles = 50;
  final _random = new Random();
  bool running = true;
  double rof = 40;
  int maxDistance = 200;
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  ParticleEmitter({required this.type, required this.size, required this.radius, required this.center, required this.color, required this.listenable}) : super(repaint: listenable);

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    double value = listenable.value; // get its value here

    // if ((DateTime.now().millisecondsSinceEpoch - currentTime) > rof) {
    //   if (particles.length > 0) {
    //     //print("Animation value: $value ${particles.length} ${particles[0]} ${(DateTime.now().millisecondsSinceEpoch - currentTime)}");
    //   }
    //   currentTime = DateTime.now().millisecondsSinceEpoch;
    //   //print("paint was called");
    //   draw(false);
    // } else {
    draw(false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void draw(bool static) {
    //print("making a $type");
    drawType(type, static);
  }

  void drawType(ShapeType type, bool static) {
    final Paint painter = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;

    if (this.running == false) {
      print("stopping...");
      return;
    }

    switch (type) {
      case ShapeType.Circle:
        drawCircle(null, this.radius, painter);
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

    // then create some particles
    if (particles.length == 0) {
      for (var i = 0; i < minParticles; i++) {
        double delay = randomDelay();
        double rand = 0;
        double randX = randomX();
        double _radius = randomizeRadius();
        drawCircle(Offset(randX, -rand), _radius.toDouble(), painter);
        particles.add({"x": randX, "y": -rand, "radius": _radius, "delay": delay});
      }
    }

    if (particles.length > 0 && particles.length < minParticles) {
      // add more
      for (var i = 0; i < (minParticles - particles.length); i++) {
        double delay = randomDelay();
        double rand = 0;
        double randX = randomX();
        double _radius = randomizeRadius();
        drawCircle(Offset(0, -rand), _radius.toDouble(), painter);
        particles.add({"x": randX, "y": -rand, "radius": _radius, "delay": delay});
      }
    }

    List<Map<String, dynamic>> tempArr = [];
    for (var i = 0; i < particles.length; i++) {
      if ((particles[i]["y"]) < (maxDistance * -1)) {
        //print("removing $i");
        particles.removeAt(i);
      } else {
        tempArr.add(particles[i]);
      }
    }

    particles.clear();
    particles = tempArr;

    for (var j = 0; j < particles.length; j++) {
      double rand = particles[j]["y"] - (maxDistance * particles[j]["delay"]).toDouble();

      particles[j]["x"] = particles[j]["x"];
      particles[j]["y"] = rand.abs() * -1;
      drawCircle(Offset(particles[j]["x"].toDouble(), rand), particles[j]["radius"], painter);
    }
  }

  void stop() {
    //stopping particles
    this.running = false;
  }

  double randomDelay() {
    return doubleInRange(0.01, 0.05);
  }

  double doubleInRange(double start, double end) {
    return _random.nextDouble() * (end - start) + start;
  }

  double randomX() {
    double _rnd = _random.nextDouble();
    bool sign = _random.nextBool();
    return sign == true ? (_rnd * 40) * -1 : (_rnd * 40);
  }

  double randomizeRadius() {
    double rnd = doubleInRange(0.1, 0.25);

    return rnd * radius;
  }

  void changeColor(Color color) {}

  void drawCircle(Offset? offset, double r, Paint paint) {
    Offset _offset = offset ?? Offset.zero;
    //rotate(() {
    canvas!.drawCircle(_offset, r, paint);
    //});
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

  void rotate(VoidCallback callback) {
    canvas!.save();
    canvas!.translate(center.dx, center.dy);

    if (angle! > 0) {
      canvas!.rotate(angle!);
    }
    callback();
    canvas!.restore();
  }
}
