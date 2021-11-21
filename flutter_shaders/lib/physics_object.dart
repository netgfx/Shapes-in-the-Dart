import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:image/image.dart';
import 'dart:ui' as ui;

class Square {
  Canvas? canvas;
  double x;
  double y;
  double vx;
  double vy;
  Paint paint;
  ShapeType type;
  bool isColliding = false;
  int? radius = 20;
  int mass = 1;
  double restitution = 0.90;
  double gravity = 9.81;
  bool gravityEnabled = true;
  Square({
    required this.canvas,
    required this.paint,
    required this.type,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.mass,
    this.radius,
  }) {
    this.radius = this.radius ?? 20;
  }

  draw(Canvas canvas) {
    this.canvas = canvas;
    var painter = Paint()
      ..color = this.isColliding ? Colors.red : Colors.green
      ..style = PaintingStyle.fill;

    if (this.type == ShapeType.Rect) {
      drawRect(x, y, painter);
    } else {
      drawCircle(x, y, painter);
    }
  }

  void drawCircle(double x, double y, Paint paint) {
    if (this.canvas != null) {
      rotate(0, 0, () {
        canvas!.drawCircle(Offset(x, y), this.radius!.toDouble(), paint);
      });
    }
  }

  void drawRect(double x, double y, Paint paint) {
    if (this.canvas != null) {
      rotate(x, y, () {
        canvas!.drawRect(rect(), paint);
      });
    }
  }

  Rect rect() => Rect.fromCircle(center: Offset.zero, radius: radius!.toDouble());

  void rotate(double? x, double? y, VoidCallback callback) {
    if (this.canvas != null) {
      double _x = x ?? 0;
      double _y = y ?? 0;
      canvas!.save();
      canvas!.translate(_x, _y);

      //canvas!.translate(0, 0);
      callback();
      canvas!.restore();
    }
  }

  int getWidth() {
    return radius!;
  }

  int getHeight() {
    return radius!;
  }

  int getMass() {
    return mass;
  }

  double getRestitution() {
    return this.restitution;
  }

  update(double secondsPassed) {
    if (gravityEnabled) {
      this.vy += this.gravity * secondsPassed;
    }
    this.x += this.vx * secondsPassed;
    this.y += this.vy * secondsPassed;
  }
}
