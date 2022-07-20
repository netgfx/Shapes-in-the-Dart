import 'dart:convert';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/sprite_archetype.dart';
import 'package:flutter_shaders/helpers/action_manager.dart';
import 'package:flutter_shaders/helpers/sprite_cache.dart';
import 'package:flutter_shaders/helpers/utils.dart';

enum LoopMode {
  Single,
  Repeat,
}

class TDSpriteAnimator with SpriteArchetype {
  Canvas? canvas;

  int currentTime = DateTime.now().millisecondsSinceEpoch;
  late ui.Image currentImage;
  String currentFrame = "";
  Map<String, List<Map<String, dynamic>>> spriteData = {};
  List<String> delimiters = [];
  double fps = 250;
  LoopMode loop;
  ui.Image? texture;
  int currentIndex = 0;
  String textureName = "";
  Size size = Size(0, 0);
  int textureWidth = 0;
  int textureHeight = 0;
  double scale = 1.0;
  Point<double> position = Point(0, 0);
  bool _alive = false;
  Paint _paint = new Paint();
  bool? startAlive = false;

  SpriteCache? cache;

  // constructor
  TDSpriteAnimator({
    required this.position,
    required this.textureName,
    required this.currentFrame,
    required this.cache,
    required this.loop,
    scale,
    this.startAlive,
  }) {
    this.scale = scale ?? 1.0;
    if (this.startAlive == true) {
      this.alive = true;
    }
    Map<String, dynamic>? cacheItem = cache!.getItem(textureName);
    if (cacheItem != null) {
      this.texture = cacheItem["texture"];
      this.spriteData = cacheItem["spriteData"];
    }
  }

  @override
  void update(Canvas canvas, {bool shouldUpdate = true}) {
    if (alive == true) {
      var img = spriteData[currentFrame]![currentIndex];
      Point<double> pos = Point(position.x - img["width"].toDouble() * scale / 2, position.y - img["height"].toDouble() * scale / 2);

      /// this component needs its own tick

      updateCanvas(canvas, pos.x, pos.y, scale, () {
        canvas.drawImageRect(
          this.texture!,
          Rect.fromLTWH(img["x"].toDouble(), img["y"].toDouble(), img["width"].toDouble(), img["height"].toDouble()),
          Rect.fromLTWH(
            0,
            0,
            img["width"].toDouble(),
            img["height"].toDouble(),
          ),
          _paint,
        );
      }, translate: false);

      if (shouldUpdate) {
        currentIndex++;
      }

      if (currentIndex >= spriteData[currentFrame]!.length) {
        if (this.loop == LoopMode.Single) {
          this.alive = false;
        }
        currentIndex = 0;
      }
    }
  }

  bool get alive {
    return _alive;
  }

  set alive(bool value) {
    _alive = value;
  }

  setPosition(Point<double> value) {
    this.position = value;
  }
}
