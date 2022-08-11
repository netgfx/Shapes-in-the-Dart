// TODO: WiP
import 'dart:math';

import 'package:flutter/rendering.dart';

class PluginTemplate {
  // position, size, alive, body, scale, zIndex, interactive
  // fns: update, onEvent
  double scale = 1.0;
  bool _alive = false;
  String _id = "";
  String textureName = "";
  Point<double> _position = Point(0, 0);
  Size _size = Size(0, 0);
  bool _interactive = false;
  Function? _onEvent;
  int _zIndex = 0;

  PluginTemplate({position, startAlive, zIndex}) {
    this.position = position ?? Point(0, 0);
    if (startAlive == true) {
      this.alive = true;
    }
    this.zIndex = zIndex ?? 0;
  }

  void update(Canvas canvas, {double elapsedTime = 0.0, bool shouldUpdate = true}) {}

  String get id {
    return this._id;
  }

  set id(String value) {
    this._id = value;
  }

  bool get alive {
    return _alive;
  }

  set alive(bool value) {
    _alive = value;
  }

  bool get interactive {
    return _interactive;
  }

  void set interactive(bool value) {
    this._interactive = value;
  }

  void set onEvent(Function? value) {
    this._onEvent = value;
  }

  Function? get onEvent {
    return this._onEvent;
  }

  void set size(Size value) {
    this._size = value;
  }

  Size get size {
    return this._size;
  }

  void set zIndex(int value) {
    this._zIndex = value;
  }

  int get zIndex {
    return this._zIndex;
  }

  void set position(Point<double> value) {
    this._position = value;
  }

  Point<double> get position {
    return this._position;
  }

  void updateCanvas(Canvas canvas, double? x, double? y, double? scale, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas.save();

    if (translate) {
      canvas.translate(_x, _y);
    }

    if (scale != null) {
      canvas.translate(_x, _y);
      canvas.scale(scale);
    }
    callback();
    canvas.restore();
  }
}
