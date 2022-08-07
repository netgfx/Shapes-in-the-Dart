import 'package:flutter_shaders/game_classes/EntitySystem/TDWorld.dart';
import 'dart:ui' as ui;

import 'package:flutter_shaders/helpers/math/CubicBezier.dart';
import 'package:flutter_shaders/helpers/sprite_cache.dart';

class GameObject {
  static GameObject shared = GameObject._();
  GameObject._();

  static GameObject get instance => shared;

  ///
  TDWorld? world = null;
  List<CubicBezier> cubicBeziers = [];
  Map<String, ui.Image> imageCache = {};
  SpriteCache spriteCache = SpriteCache();

  ///

  setWorld(TDWorld value) {
    this.world = value;
  }

  TDWorld? getWorld() {
    return this.world;
  }

  setSpriteCache(SpriteCache value) {
    this.spriteCache = value;
  }

  SpriteCache getSpriteCache() {
    return this.spriteCache;
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
