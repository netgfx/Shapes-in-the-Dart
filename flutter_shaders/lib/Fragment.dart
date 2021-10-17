import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/Shard.dart';
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
  int currentTime = 0;
  ui.Image image;
  int fps = 24;
  int timeDecay = 250;
  double rate = 0.042;
  late Shard shard;

  Map<String, dynamic> box = {};
  Point<double> centroid = Point(0.0, 0.0);

  Fragment({
    required this.p0,
    required this.p1,
    required this.p2,
    required this.controller,
    required this.image,
    required this.fps,
    required this.delay,
  }) : super(repaint: controller) {
    print("draw");

    this.timeDecay = (1 / this.fps * 1000).round();

    /// make the shard
    this.shard = Shard(
        a: this.p0,
        b: this.p1,
        c: this.p2,
        speed: this.fps.toDouble(),
        color: Colors.orange,
        painter: new Paint()..color = Color.fromRGBO(0, 0, 0, 1),
        renderDelay: 0,
        opacity: 255,
        timeAlive: 0,
        timeToLive: 24);
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
    if (shard.timeAlive > shard.timeToLive) {
      return;
    }

    if (this.controller!.lastElapsedDuration != null) {
      //print("${this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime},$delay");
      if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= delay && shard.timeAlive == 0) {
        this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;
        shard.timeAlive += 1;
        this.rate += 0.05;
        if (this.rate > 1.0) {
          this.rate = 1.0;
        }
        //print("ROUND: ${shard.timeAlive}");
        // check if it has ended running

        drawPolygon(shard, false);
      } else if (shard.timeAlive > 0) {
        this.currentTime = DateTime.now().millisecondsSinceEpoch;
        shard.timeAlive += 1;
        this.rate += 0.05;
        if (this.rate > 1.0) {
          this.rate = 1.0;
        }
        //print("ROUND: ${shard.timeAlive}");
        // check if it has ended running

        drawPolygon(shard, false);
      } else {
        drawPolygon(shard, true);
      }
    } else {
      drawPolygon(shard, true);
    }
  }

  void computeBoundingBox() {
    var xMin = [this.p0.x, this.p1.x, this.p2.x].reduce(min),
        xMax = [this.p0.x, this.p1.x, this.p2.x].reduce(max),
        yMin = [this.p0.y, this.p1.y, this.p2.y].reduce(min),
        yMax = [this.p0.y, this.p1.y, this.p2.y].reduce(max);

    this.box = {"x": xMin, "y": yMin, "w": xMax - xMin, "h": yMax - yMin};
    //print(this.box);
  }

  void computeCentroid() {
    double x = (this.p0.x + this.p1.x + this.p2.x) / 3;
    double y = (this.p0.y + this.p2.y + this.p2.y) / 3;

    this.centroid = Point(x, y);
  }

  void drawPolygon(Shard shard, bool static) {
    double _scale = shard.getScale();
    double _rotationX = shard.getRotationX();
    double _rotationY = shard.getRotationY();
    int _opacity = shard.getOpacity();

    if (static != true) {
      _scale = 1.0 - this.rate;
      _opacity = (255 - (255 * this.rate)).round();
      _rotationX = (30 * this.rate).toDouble();
      _rotationY = (-30 * this.rate).toDouble();

      shard.opacity = _opacity;
      shard.rotateX = _rotationX;
      shard.rotateY = _rotationY;
      shard.scale = _scale;
    }

    //print("OPACITY: ${shard.getOpacity()} ${255 * this.controller!.value}");
    rotate(_scale, 0, 0, () {
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
      canvas!.drawPath(path, shard.getPainter());
      canvas!.clipPath(path);
      canvas!.drawImage(image, new Offset(0.0, 0.0), Paint()..color = shard.getColor().withAlpha(_opacity));
    });
  }

  void rotate(double scale, double angleX, double angleY, VoidCallback callback) {
    double _x = this.box["w"] / 2;
    double _y = this.box["h"] / 2;
    canvas!.save();

    if (angleX != 0 || angleY != 0) {
      // canvas!.rotate(angle);
      var matrix = Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
        ..rotateX(angleX)
        ..rotateY(angleY);
      //canvas!.transform(matrix.storage);
      canvas!.rotate(angleX);
    }

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
