import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum LoopMode {
  Single,
  Repeat,
}

class SpriteAnimator extends CustomPainter {
  Map<String, List<Map<String, dynamic>>> images = {};
  AnimationController controller;
  Canvas? canvas;
  int timeDecay = 250;
  int currentTime = 0;
  late ui.Image currentImage;
  String currentFrame = "";
  int fps = 250;
  bool static = true;
  LoopMode loop;
  ui.Image texture;
  int currentIndex = 0;
  SpriteAnimator({
    required this.images,
    required this.texture,
    required this.static,
    required this.currentFrame,
    required this.fps,
    required this.controller,
    required this.loop,
  }) : super(repaint: controller) {
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
    var img = images[currentFrame]![currentIndex];
    if (static == false) {
      // print("${this.controller}");
      if (this.controller.lastElapsedDuration != null) {
        if (this.controller.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay) {
          this.currentTime = this.controller.lastElapsedDuration!.inMilliseconds;
          canvas.drawImageRect(
            this.texture,
            Rect.fromLTWH(img["x"].toDouble(), img["y"].toDouble(), img["width"].toDouble(), img["height"].toDouble()),
            Rect.fromLTWH(0, 0, img["width"].toDouble(), img["height"].toDouble()),
            new Paint(),
          );
          currentIndex++;
          if (currentIndex >= images[currentFrame]!.length) {
            currentIndex = 0;
            if (this.loop == LoopMode.Single) {
              this.controller.stop();
            }
          }
        } else {
          // do nothing?
          canvas.drawImageRect(
            this.texture,
            Rect.fromLTWH(img["x"].toDouble(), img["y"].toDouble(), img["width"].toDouble(), img["height"].toDouble()),
            Rect.fromLTWH(0, 0, img["width"].toDouble(), img["height"].toDouble()),
            new Paint(),
          );
        }
      }
    } else {
      //print("no loop");
      canvas.drawImageRect(
        this.texture,
        Rect.fromLTWH(img["x"], img["y"], img["width"], img["height"]),
        Rect.fromLTWH(0, 0, img["width"], img["height"]),
        new Paint(),
      );
    }
  }
}
