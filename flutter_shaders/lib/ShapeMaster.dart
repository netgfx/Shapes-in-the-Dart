import "dart:math";
import "dart:ui";

import 'package:flutter/material.dart' as material;
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math.dart';

enum ShapeType {
  Circle,
  Rect,
  RoundedRect,
  Triangle,
  Diamond,
  Pentagon,
  Hexagon,
  Octagon,
  Decagon,
  Dodecagon,
  Heart,
  Star5,
  Star6,
  Star7,
  Star8,
}

class ShapeMaster extends CustomPainter {
  ShapeType type = ShapeType.Rect;
  Size size = Size(20, 20);
  double radius = 0.0;
  Canvas? canvas;
  Offset center = Offset(0, 0);
  double? angle = 0;
  material.Color color = material.Colors.black;

  ShapeMaster({type, size, radius, center, angle, color}) {
    this.type = type;
    this.size = size ?? Size(20, 20);
    this.color = color ?? material.Colors.black;
    this.radius = radius ?? 50.0;
    this.center = center;
    this.angle = angle ?? 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    //print("paint was called");
    draw();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void draw() {
    final Paint fill = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;
    //print("making a $type");
    drawType(type, fill);
  }

  void drawType(ShapeType type, Paint painter) {
    switch (type) {
      case ShapeType.Circle:
        drawCircle(painter);
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

  void changeColor(Color color) {}

  void drawCircle(Paint paint) {
    rotate(() {
      canvas!.drawCircle(Offset.zero, radius, paint);
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
        final double radian = radians(initialAngle + 360 / num * i.toDouble());
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
        final double radian = radians(initialAngle + 360 / num * i.toDouble());
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

    canvas!.rotate(angle!);
    callback();
    canvas!.restore();
  }
}
