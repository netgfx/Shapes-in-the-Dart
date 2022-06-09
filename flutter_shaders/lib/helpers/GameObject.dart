import 'package:flutter_shaders/game_classes/TDWorld.dart';
import 'dart:ui' as ui;

class GameObject {
  static GameObject shared = GameObject._();
  GameObject._();

  static GameObject get instance => shared;

  ///
  TDWorld? world = null;
  Map<String, ui.Image> imageCache = {};

  ///

  setWorld(TDWorld value) {
    this.world = value;
  }

  TDWorld? getWorld() {
    return this.world;
  }

  setCacheValue(String key, ui.Image value) {
    imageCache[key] = value;
  }

  ui.Image? getCacheValue(String key) {
    return imageCache[key];
  }
}
