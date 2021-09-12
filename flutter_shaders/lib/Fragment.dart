import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;

class Fragment extends CustomPainter {
  Point<double> p0;
  Point<double> p1;
  Point<double> p2;
  AnimationController? controller;
  Canvas? canvas;
  double angle = 0;
  int delay = 0;
  ui.Image image;
  Map<String, dynamic> box = {};
  Point<double> centroid = Point(0.0, 0.0);

  Fragment({
    required this.p0,
    required this.p1,
    required this.p2,
    required this.controller,
    required this.image,
  }) : super(repaint: controller) {
    print("draw");
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    paintImage(canvas, size);
  }

  void paintImage(Canvas canvas, Size size) async {
    computeBoundingBox();
    computeCentroid();

    draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void draw(Canvas canvas, Size size) {
    drawPolygon(Paint());
    //..color = Colors.orange
    //..blendMode = BlendMode.src);
    //..style = PaintingStyle.fill);
  }

  void computeBoundingBox() {
    var xMin = [this.p0.x, this.p1.x, this.p2.x].reduce(min),
        xMax = [this.p0.x, this.p1.x, this.p2.x].reduce(max),
        yMin = [this.p0.y, this.p1.y, this.p2.y].reduce(min),
        yMax = [this.p0.y, this.p1.y, this.p2.y].reduce(max);

    this.box = {"x": xMin, "y": yMin, "w": xMax - xMin, "h": yMax - yMin};
  }

  void computeCentroid() {
    double x = (this.p0.x + this.p1.x + this.p2.x) / 3;
    double y = (this.p0.y + this.p2.y + this.p2.y) / 3;

    this.centroid = Point(x, y);
  }

  void drawPolygon(Paint paint, {double initialAngle = 0}) {
    rotate(() {
      final Path path = Path();
      for (int i = 0; i < 3; i++) {
        //final double radian = vectorMath.radians(initialAngle + 360 / 3 * i.toDouble());

        double x = 0; //radius * cos(radian);
        double y = 0; //radius * sin(radian);
        if (i == 0) {
          x = this.p0.x;
          y = this.p0.y;
        } else if (i == 1) {
          x = this.p1.x;
          y = this.p1.y;
        } else {
          x = this.p2.x;
          y = this.p2.y;
        }

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas!.drawPath(path, paint);
      canvas!.clipPath(path);
      canvas!.drawImage(image, new Offset(0.0, 0.0), new Paint());
    });
  }

  void rotate(VoidCallback callback) {
    double _x = this.box["x"] * -1;
    double _y = this.box["y"] * -1;
    canvas!.save();
    //canvas!.translate(_x, _y);

    if (this.angle > 0) {
      canvas!.rotate(this.angle);
    }
    callback();
    canvas!.restore();
  }
}
