import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/TDWorld.dart';
import 'package:flutter_shaders/helpers/GameObject.dart';
import 'package:flutter_shaders/helpers/sprite_cache.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:bezier/bezier.dart";
import "../../helpers/utils.dart";
import "../../helpers/Rectangle.dart";
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

mixin SpriteArchetype {
  double scale = 1.0;
  ui.Image? texture;
  Canvas? canvas;
  bool _alive = false;
  SpriteCache? cache;
  String _id = "";
  String textureName = "";
  Point<double> position = Point(0, 0);

  // SpriteArchetype({
  //   required this.position,
  //   required this.textureName,
  //   required this.cache,
  //   scale,
  // }) {}

  void update(Canvas canvas, {bool shouldUpdate = true}) {}

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
