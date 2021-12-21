import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum LoopMode {
  Single,
  Repeat,
}

enum Direction {
  Horizontal,
  Vertical,
}

class BGAnimator extends CustomPainter {
  ui.Image image;
  AnimationController controller;
  Canvas? canvas;
  int timeDecay = 250;
  int currentTime = 0;
  int fps;
  bool static = true;
  BoxConstraints constraints;
  double innitialOffset = -50;
  Size imageSize;
  Offset offset;
  Direction scrollDirection;
  BGAnimator({
    required this.image,
    required this.constraints,
    required this.static,
    required this.fps,
    required this.controller,
    required this.imageSize,
    required this.offset,
    required this.scrollDirection,
  }) : super(repaint: controller) {
    print("draw");
    this.fps = (1 / this.fps * 1000).round();
    this.timeDecay = this.fps;
    innitialOffset = this.offset.dy.toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    paintImage(canvas, size);
  }

  void paintImage(Canvas canvas, Size size) async {
    draw(canvas, size);
  }

  int calculateMaxOffset() {
    int finalCalc = 0;
    if (this.scrollDirection == Direction.Vertical) {
      double ratio = (imageSize.height / 3);
      finalCalc = ((imageSize.height - ratio) + this.offset.dy.abs()).round();
    } else {
      double ratio = (imageSize.width / 3);
      finalCalc = ((imageSize.width - ratio) + this.offset.dx.abs()).round();
    }
    return finalCalc;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void draw(Canvas canvas, Size size) {
    if (static == false) {
      // print("${this.controller}");
      if (this.controller.lastElapsedDuration != null) {
        if (this.controller.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay) {
          this.currentTime = this.controller.lastElapsedDuration!.inMilliseconds;
          canvas.drawImage(image, new Offset(0.0, innitialOffset), new Paint());
          innitialOffset -= 5;
          int maxHeight = calculateMaxOffset();
          if (innitialOffset <= (maxHeight * -1)) {
            innitialOffset = this.offset.dy.abs() * -1;
          }

          this.currentTime = this.controller.lastElapsedDuration!.inMilliseconds;
        } else {
          // do nothing?
          canvas.drawImage(image, new Offset(0.0, innitialOffset), new Paint());
        }
      } else {
        canvas.drawImage(image, new Offset(0.0, innitialOffset), new Paint());
      }
    } else {
      //print("no loop");
      canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
    }
  }
}
