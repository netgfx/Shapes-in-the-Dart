import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/LetterParticle.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/helpers/utils.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;

class FlipImage extends CustomPainter {
  Map<String, dynamic> imageData = {};
  Color color = Colors.black;
  double radius = 20.0;
  AnimationController? controller;
  Canvas? canvas;
  double angle = 0;
  final int delay;
  int runningDelay = 500;
  int currentTime = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  ShapeType type = ShapeType.Circle;
  int timeDecay = 0;
  double finalFlipY = 0;
  double? rate = 40 / 1000;
  double endT = 0.0;
  final _random = new Random();
  int timeAlive = 0;
  int timeToLive = 24;
  Map<String, dynamic> metadata = {};
  String front = "";
  String back = "";
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;
  Easing ease = Easing.LINEAR;
  double translateX = 0;
  int start = 0;
  int end = 1;
  int timesFlipped = 0;

  /// Constructor
  FlipImage({
    /// <-- The type character to display
    required this.imageData,
    required this.front,
    required this.back,

    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,

    /// <-- The delay until the animation starts
    required this.delay,

    /// <-- The animation easing function
    required this.ease,

    /// <-- Custom callback to call after Delay has passed
    this.animate,
  }) : super(repaint: controller) {
    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();

    /// setting a temp delay which is mutable
    this.runningDelay = this.delay;

    /// default painter
    Paint fill = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;

    this.metadata = this.imageData["data"];

    /// fire the animate after a delay
    if (this.delay > 0 && this.animate != null) {
      Future.delayed(Duration(milliseconds: this.delay), () => {this.animate!()});
    }
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
    /// check if the controller is running
    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        if (this.runningDelay > 0) {
          this.runningDelay -= this.timeDecay;
          //print(this.runningDelay);
        }

        if (this.delay > 0) {
          if (this.runningDelay > 0) {
            drawImage(
              canvas,
              this.imageData["texture"],
            );

            return;
          }
        }

        /// in order to run in our required frames per second
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay && this.timeAlive == 0 && this.timesFlipped <= 1) {
          /// reset the time
          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;

          /// manual ticker
          if (endT < 1.0) {
            endT += this.rate ?? 0.009;
          }

          if (endT >= 1.0) {
            if (this.timesFlipped == 0) {
              endT = 0.0;
              this.runningDelay = this.delay;
              this.start = 1;
              this.end = 0;
            }
            this.timesFlipped += 1;
          } else if (endT <= 0) {
            //endT = 0.0;
            this.finalFlipY = 0;
          }

          drawImage(
            canvas,
            this.imageData["texture"],
          );
        } else {
          drawImage(canvas, this.imageData["texture"], skip: true);
        }
      } else {
        print("re-rendering points with no changes");
        drawImage(canvas, this.imageData["texture"], skip: true);
      }
    } else {
      drawImage(canvas, this.imageData["texture"], skip: true);
      print("no controller");
    }
  }

  void drawImage(Canvas canvas, ui.Image texture, {bool? skip = false}) {
    var side = this.finalFlipY <= 0.5 ? this.front : this.back;
    var img = this.metadata[side]![0];
    delayedPrint("$side $endT ${this.finalFlipY} ${this.start} ${this.end}");

    if (skip == false) {
      /// flip the canvas
      this.canvas!.save();
      this.finalFlipY = ui.lerpDouble(this.start.toDouble(), this.end.toDouble(), getStagger(endT))!;

      this.canvas!.scale(0.5);
      this.canvas!.translate(img["width"].toDouble() / 2, img["height"].toDouble() / 2);
      var matrix = Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(pi * this.finalFlipY);
      //..translate(this.p0.x - _x, this.p0.y - _y);
      this.canvas!.transform(matrix.storage);

      this.canvas!.translate(-img["width"].toDouble() / 2, -img["height"].toDouble() / 2);

      /// draw the image on the flipped canvas
      this.canvas!.drawImageRect(
            texture,
            Rect.fromLTWH(img["x"].toDouble(), img["y"].toDouble(), img["width"].toDouble(), img["height"].toDouble()),
            Rect.fromLTWH(0, 0, img["width"].toDouble(), img["height"].toDouble()),
            new Paint(),
          );

      this.canvas!.restore();
    } else {
      this.canvas!.save();
      this.canvas!.scale(0.5);
      this.canvas!.translate(img["width"].toDouble() / 2, img["height"].toDouble() / 2);
      var matrix = Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(pi * this.finalFlipY);
      //..translate(this.p0.x - _x, this.p0.y - _y);
      this.canvas!.transform(matrix.storage);
      //this.canvas!.scale(this.finalFlipY, 1);
      this.canvas!.translate(-img["width"].toDouble() / 2, -img["height"].toDouble() / 2);
      this.canvas!.drawImageRect(
            texture,
            Rect.fromLTWH(img["x"].toDouble(), img["y"].toDouble(), img["width"].toDouble(), img["height"].toDouble()),
            Rect.fromLTWH(0, 0, img["width"].toDouble(), img["height"].toDouble()),
            new Paint(),
          );
      this.canvas!.restore();
    }
  }

  double getStagger(double progress) {
    /// linear
    double easeResult = progress;

    /// easings
    switch (this.ease) {
      case Easing.EASE_OUT_SINE:
        {
          easeResult = Utils.shared.easeOutSine(progress);
        }
        break;

      case Easing.EASE_OUT_QUART:
        {
          easeResult = Utils.shared.easeOutQuart(progress);
        }
        break;
      case Easing.EASE_OUT_QUAD:
        {
          easeResult = Utils.shared.easeOutQuad(progress);
        }
        break;
      case Easing.EASE_OUT_CUBIC:
        {
          easeResult = Utils.shared.easeOutCubic(progress);
        }
        break;
      case Easing.EASE_OUT_CIRC:
        {
          easeResult = Utils.shared.easeOutCirc(progress);
        }
        break;
      case Easing.EASE_OUT_BACK:
        {
          easeResult = Utils.shared.easeOutBack(progress);
        }
        break;
      case Easing.EASE_IN_OUT_BACK:
        {
          easeResult = Utils.shared.easeInOutBack(progress);
        }
        break;
      default:
        {
          easeResult = progress;
        }
        break;
    }

    return easeResult;
  }

  void delayedPrint(String str) {
    if (DateTime.now().millisecondsSinceEpoch - this.printTime > 100) {
      this.printTime = DateTime.now().millisecondsSinceEpoch;
      print(str);
    }
  }

  void rotate(double? x, double? y, VoidCallback callback) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    var scale = 1.0;
    canvas!.save();
    canvas!.translate(_x, _y);

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
