import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import '../helpers/Rectangle.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import 'package:flutter_shaders/helpers/utils.dart';

class TDBullet {
  double x = 0;
  double y = 0;
  double ticker = 0;
  double velocity = 0;
  // for recycle
  bool _alive = false;
  double _angle = 0;
  Point _target = Point(0, 0);
  Point<double> _origin = Point(0, 0);

  TDBullet({required this.x, required this.y, required this.velocity}) {
    _origin = Point(this.x, this.y);
  }

  set origin(Point<double> value) {
    this._origin = value;
  }

  Point<double> get origin {
    return this._origin;
  }

  set alive(bool value) {
    this._alive = value;
    if (value == false) {
      this.x = origin.x;
      this.y = origin.y;
    }
  }

  bool get alive {
    return _alive;
  }

  set angle(double value) {
    this._angle = value;
  }

  double get angle {
    return this._angle;
  }

  set target(Point value) {
    this._target = value;
  }

  Point get target {
    return this._target;
  }

  /// end of properties

  void update(Canvas canvas) {
    ticker += this.velocity;

    if (alive == true) {
      moveToTarget();
      drawCircle(canvas);
    }
  }
  //TODO: Add image draw

  void drawCircle(Canvas canvas) {
    var _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.black.withAlpha(this.alive == true ? 255 : 0)
      ..style = PaintingStyle.fill;

    rotate(canvas, this.x, this.y, null, () {
      canvas.drawCircle(Offset(0, 0), 5, _paint);
    }, translate: true);
  }

  void rotate(Canvas canvas, double? x, double? y, double? angle, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas.save();

    if (translate) {
      canvas.translate(_x, _y);
    }

    if (angle != null) {
      canvas.translate(_x, _y);
      canvas.rotate(angle);
    }
    callback();
    canvas.restore();
  }

  void moveToTarget() {
    this.x = ui.lerpDouble(this.x, target.x, getStagger(velocity, Easing.LINEAR))!;
    this.y = ui.lerpDouble(this.y, target.y, getStagger(velocity, Easing.LINEAR))!;

    //print("${this.x}, ${this.target.x}, ${this.velocity}");
    if (this.x >= target.x - 0.11 && this.y >= target.y - 0.11) {
      print("reached destination, recycling");

      alive = false;
    }
  }

  Rectangle getBounds() {
    return Rectangle(x: this.x, y: this.y, width: 10, height: 10);
  }

  double getStagger(double progress, Easing ease) {
    /// linear
    double easeResult = progress;

    /// easings
    switch (ease) {
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
}
