import 'package:flutter_shaders/game_classes/TDWorld.dart';
import 'dart:ui' as ui;

import 'package:flutter_shaders/helpers/math/CubicBezier.dart';

class GameObject {
  static GameObject shared = GameObject._();
  GameObject._();

  static GameObject get instance => shared;

  ///
  TDWorld? world = null;
  List<CubicBezier> cubicBeziers = [];
  Map<String, ui.Image> imageCache = {};

  ///

  setWorld(TDWorld value) {
    this.world = value;
  }

  TDWorld? getWorld() {
    return this.world;
  }

  void setCubicBeziers(List<CubicBezier> value) {
    this.cubicBeziers = value;
  }

  List<CubicBezier> getCubicBeziers() {
    return this.cubicBeziers;
  }

  setCacheValue(String key, ui.Image value) {
    imageCache[key] = value;
  }

  ui.Image? getCacheValue(String key) {
    return imageCache[key];
  }
}
