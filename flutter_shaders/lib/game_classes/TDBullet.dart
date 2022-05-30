import 'dart:math' as math;
import 'dart:ui' as ui;
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

  TDBullet({required this.x, required this.y, required this.velocity}) {}

  set alive(bool value) {
    this._alive = value;
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

  /// end of properties

  void update(math.Point? point) {
    ticker += this.velocity;

    if (point != null) {
      moveToPoint(point);
    }
  }

  void moveToPoint(math.Point point) {
    this.x = ui.lerpDouble(this.x, point.x, getStagger(velocity, Easing.EASE_OUT_CIRC))!;
    this.y = ui.lerpDouble(this.y, point.y, getStagger(velocity, Easing.EASE_OUT_CIRC))!;
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
