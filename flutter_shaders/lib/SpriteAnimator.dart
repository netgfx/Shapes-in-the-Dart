import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum LoopMode {
  Single,
  Repeat,
}

class SpriteAnimator extends CustomPainter {
  List<ui.Image> images = [];
  AnimationController controller;
  Canvas? canvas;
  int timeDecay = 250;
  int currentTime = 0;
  late ui.Image currentImage;
  int currentImageIndex = 0;
  int fps = 250;
  bool static = true;
  LoopMode loop;
  SpriteAnimator({required this.images, required this.static, required this.currentImageIndex, required this.fps, required this.controller, required this.loop}) : super(repaint: controller) {
    print("draw");
    this.fps = (1 / this.fps * 1000).round();
    this.timeDecay = this.fps;
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
    if (static == false) {
      // print("${this.controller}");
      if (this.controller.lastElapsedDuration != null) {
        if (this.controller.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay) {
          this.currentTime = this.controller.lastElapsedDuration!.inMilliseconds;
          canvas.drawImage(images[currentImageIndex], new Offset(0.0, 0.0), new Paint());
          currentImageIndex++;
          if (currentImageIndex >= images.length) {
            currentImageIndex = 0;
            if (this.loop == LoopMode.Single) {
              this.controller.stop();
            }
          }
          this.currentTime = this.controller.lastElapsedDuration!.inMilliseconds;
        } else {
          // do nothing?
          canvas.drawImage(images[currentImageIndex], new Offset(0.0, 0.0), new Paint());
        }
      }
    } else {
      //print("no loop");
      canvas.drawImage(images[this.currentImageIndex], new Offset(0.0, 0.0), new Paint());
    }
  }
}
