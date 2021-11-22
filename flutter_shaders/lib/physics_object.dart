import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:image/image.dart';
import 'dart:ui' as ui;

class ObjectFX {
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
  double restitution = 0.99;
  double gravity = 9.81;
  bool gravityEnabled = false;
  bool staticBody = false;
  Size? size = Size(100, 100);
  ObjectFX({
    required this.canvas,
    required this.paint,
    required this.type,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.mass,
    required this.staticBody,
    this.size,
    this.radius,
  }) {
    this.size = this.size ?? Size(100, 100);
    this.radius = this.radius ?? 20;
    paint = Paint()
      ..color = this.isColliding ? Colors.red : Colors.green
      ..style = PaintingStyle.fill;
  }

  draw(Canvas canvas) {
    this.canvas = canvas;

    paint.color = this.isColliding ? Colors.red : Colors.green;
    if (this.type == ShapeType.Rect) {
      drawRect(x, y, paint);
    } else {
      drawCircle(x, y, paint);
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
      rotate(0, 0, () {
        Rect rect = Rect.fromLTWH(x, y, this.size!.width, this.size!.height);
        canvas!.drawRect(rect, paint);
      });
    }
  }

  void setSize(Size size) {}

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
    return this.staticBody == true || this.type == ShapeType.Rect ? this.size!.width.round() : radius!;
  }

  int getHeight() {
    return this.staticBody == true || this.type == ShapeType.Rect ? this.size!.height.round() : radius!;
  }

  int getMass() {
    return mass;
  }

  double getRestitution() {
    return this.restitution;
  }

  update(double secondsPassed) {
    if (gravityEnabled == true && staticBody == false) {
      this.vy += this.gravity * secondsPassed;
    }

    if (this.staticBody == false) {
      this.x += this.vx * secondsPassed;
      this.y += this.vy * secondsPassed;
    }
  }
}
