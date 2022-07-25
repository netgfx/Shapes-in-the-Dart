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
  int currentTime = 0;
  late ui.Image currentImage;
  String currentFrame = "";
  Map<String, List<Map<String, dynamic>>> spriteData = {};
  List<String> delimiters = [];
  double? fps = 250;
  LoopMode loop;
  int currentIndex = 0;
  int textureWidth = 0;
  int textureHeight = 0;
  Paint _paint = new Paint();
  bool? startAlive = false;
  int timeDecay = 0;
  SpriteCache? cache;

  // constructor
  TDSpriteAnimator({
    required position,
    required textureName,
    required this.currentFrame,
    required this.cache,
    required this.loop,
    scale,
    interactive,
    onEvent,
    this.fps,
    this.startAlive,
  }) {
    this.position = position;
    this.textureName = textureName;
    this.interactive = interactive;
    this.onEvent = onEvent;
    this.timeDecay = (1 / (this.fps ?? 60) * 1000).round();
    this.scale = scale ?? 1.0;
    if (this.startAlive == true) {
      this.alive = true;
    }
    Map<String, dynamic>? cacheItem = cache!.getItem(textureName);
    if (cacheItem != null) {
      this.texture = cacheItem["texture"];
      this.spriteData = cacheItem["spriteData"];
      var img = spriteData[currentFrame]![currentIndex];
      this.size = Size(img["width"].toDouble() * this.scale, img["height"].toDouble() * this.scale);
    }
  }

  @override
  void update(Canvas canvas, {double elapsedTime = 0.0, bool shouldUpdate = true}) {
    if (alive == true) {
      var img = spriteData[currentFrame]![currentIndex];
      Point<double> pos = Point(position.x - img["width"].toDouble() * scale / 2, position.y - img["height"].toDouble() * scale / 2);

      /// this component needs its own tick
      if (elapsedTime - this.currentTime >= timeDecay) {
        /// reset the time
        this.currentTime = elapsedTime.round();

        renderSprite(canvas, pos, img);

        if (shouldUpdate) {
          currentIndex++;
        }

        if (currentIndex >= spriteData[currentFrame]!.length) {
          if (this.loop == LoopMode.Single) {
            this.alive = false;
          }
          currentIndex = 0;
        }
      } else {
        renderSprite(canvas, pos, img);
      }
    }
  }

  void renderSprite(Canvas canvas, Point<double> pos, Map<String, dynamic> img) {
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
  }

  setPosition(Point<double> value) {
    this.position = value;
  }
}
