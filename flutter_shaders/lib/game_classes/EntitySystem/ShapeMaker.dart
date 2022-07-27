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

class ShapeMaker {
  ShapeType type = ShapeType.Rect;
  Size size = Size(20, 20);
  double radius = 0.0;
  double? angle = 0;
  material.Color color = material.Colors.black;
  Paint paint = Paint();
  Point<double> position = Point(0, 0);

  ShapeMaster({type, size, radius, position, angle, color}) {
    this.type = type;
    this.size = size ?? Size(20, 20);
    this.color = color ?? material.Colors.black;
    this.radius = radius ?? 50.0;
    this.position = position;
    this.angle = angle ?? 0.0;

    this.paint = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;
  }

  void update(Canvas canvas, {shouldUpdate: false}) {
    //print("making a $type");
    drawType(canvas, type);
  }

  void drawType(Canvas canvas, ShapeType type) {
    switch (type) {
      case ShapeType.Circle:
        drawCircle(canvas);
        break;
      case ShapeType.Rect:
        drawRect(canvas);
        break;
      case ShapeType.RoundedRect:
        drawRRect(canvas);
        break;
      case ShapeType.Triangle:
        drawPolygon(canvas, 3, initialAngle: 30);
        break;
      case ShapeType.Diamond:
        drawPolygon(canvas, 4, initialAngle: 0);
        break;
      case ShapeType.Pentagon:
        drawPolygon(canvas, 5, initialAngle: -18);
        break;
      case ShapeType.Hexagon:
        drawPolygon(canvas, 6, initialAngle: 0);
        break;
      case ShapeType.Octagon:
        drawPolygon(canvas, 8, initialAngle: 0);
        break;
      case ShapeType.Decagon:
        drawPolygon(canvas, 10, initialAngle: 0);
        break;
      case ShapeType.Dodecagon:
        drawPolygon(canvas, 12, initialAngle: 0);
        break;
      // case ShapeType.Heart:
      //   drawHeart(painter);
      //   break;
      case ShapeType.Star5:
        drawStar(canvas, 10, initialAngle: 15);
        break;
      case ShapeType.Star6:
        drawStar(canvas, 12, initialAngle: 0);
        break;
      case ShapeType.Star7:
        drawStar(canvas, 14, initialAngle: 0);
        break;
      case ShapeType.Star8:
        drawStar(canvas, 16, initialAngle: 0);
        break;
    }
  }

  void drawCircle(Canvas canvas) {
    updateCanvas(canvas, 0, 0, 0, () {
      canvas!.drawCircle(Offset.zero, radius, paint);
    });
  }

  void drawRRect(Canvas canvas, {double? cornerRadius}) {
    updateCanvas(canvas, 0, 0, 0, () {
      Rect rect = Rect.fromLTWH(0, 0, this.size.width, this.size.height);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius ?? radius * 0.2)), this.paint);
    });
  }

  void drawPolygon(Canvas canvas, int num, {double initialAngle = 0}) {
    updateCanvas(canvas, 0, 0, 0, () {
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
      canvas!.drawPath(path, this.paint);
    });
  }

  // void drawHeart(Paint paint) {
  //   rotate(() {
  //     final Path path = Path();

  //     path.moveTo(0, radius);

  //     path.cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0, -radius * 0.5);
  //     path.cubicTo(radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);

  //     canvas!.drawPath(path, paint);
  //   });
  // }

  void drawStar(Canvas canvas, int num, {double initialAngle = 0}) {
    updateCanvas(canvas, 0, 0, 0, () {
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
      canvas!.drawPath(path, this.paint);
    });
  }

  void drawRect(Canvas canvas) {
    updateCanvas(canvas, this.position.x, this.position.y, this.angle, () {
      canvas!.drawRect(Rect.fromLTWH(0, 0, this.size.width, this.size.height), this.paint);
    });
  }

  void updateCanvas(Canvas canvas, double? x, double? y, double? rotate, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas.save();

    if (translate) {
      canvas.translate(_x, _y);
    }

    if (rotate != null) {
      canvas.translate(_x, _y);
      canvas.rotate(rotate);
    }
    callback();
    canvas.restore();
  }
}
