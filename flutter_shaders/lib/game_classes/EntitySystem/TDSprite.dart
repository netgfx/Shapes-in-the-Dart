import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/TDWorld.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/sprite_archetype.dart';
import 'package:flutter_shaders/helpers/GameObject.dart';
import 'package:flutter_shaders/helpers/sprite_cache.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:bezier/bezier.dart";
import "../../helpers/utils.dart";
import "../../helpers/Rectangle.dart";
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

class TDSprite with SpriteArchetype {
  double scale = 1.0;
  String _id = "";
  ui.Image? texture;
  Size size = Size(0, 0);
  int textureWidth = 0;
  int textureHeight = 0;
  TDWorld? world = GameObject.shared.getWorld();
  String textureName = "";
  Point<double> position = Point(0, 0);
  double _angle = 0;
  Canvas? canvas;
  bool _alive = false;
  bool? startAlive = false;
  //
  SpriteCache? cache;

  ///
  TDSprite({
    required this.position,
    required this.textureName,
    required this.cache,
    interactive,
    onEvent,
    scale,
    this.startAlive,
  }) {
    this.interactive = interactive ?? false;
    this.onEvent = onEvent ?? null;
    this.scale = scale ?? 1.0;
    if (this.startAlive == true) {
      this.alive = true;
    }
    Map<String, dynamic>? cacheItem = cache!.getItem(textureName);
    if (cacheItem != null) {
      this.texture = cacheItem["texture"];
      this.textureWidth = cacheItem["textureWidth"];
      this.textureHeight = cacheItem["textureHeight"];
      if (this.texture != null) {
        setSize();
      }
    }
  }

  ///

  Size getSize() {
    return size;
  }

  String get id {
    return this._id;
  }

  set id(String value) {
    this._id = value;
  }

  void setSize() {
    ui.Image img = this.texture!;
    double aspectRatio = img.width / img.height;
    int height = (img.height * this.scale).round();
    int width = (height * aspectRatio).round();
    this.size = Size(width.toDouble(), height.toDouble());
  }

  @override
  void update(Canvas canvas, {double elapsedTime = 0, bool shouldUpdate = true}) {
    if (this.texture != null) {
      drawSprite(canvas);
    }
  }

  void drawSprite(Canvas canvas) {
    var paint = new Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = false;

    Size fitSize = Size(size.width, size.height);

    updateCanvas(canvas, position.x, position.y, scale, () {
      if (GameObject.shared.world != null) {
        Size bounds = GameObject.shared.getWorld()!.worldBounds;
        final FittedSizes sizes = applyBoxFit(BoxFit.cover, this.size, bounds);
        final Rect inputSubrect = Alignment.center.inscribe(sizes.source, Offset.zero & this.size);
        final Rect outputSubrect = Alignment.center.inscribe(sizes.destination, Offset.zero & bounds);
        canvas.drawImageRect(this.texture!, inputSubrect, outputSubrect, paint);
      }
      // canvas.drawImageRect(
      //   this.texture!,
      //   Rect.fromLTWH(0, 0, textureWidth.toDouble(), textureHeight.toDouble()),
      //   Rect.fromLTWH(0, 0, size.width, size.height),
      //   paint,
      // );
    });
  }

  Rectangle getRect() {
    Size _size = getSize();
    return Rectangle(x: this.position.x, y: this.position.y, width: _size.width, height: _size.height);
  }

  Rectangle getBounds() {
    Size _size = getSize();
    return Rectangle(x: this.position.x, y: this.position.y, width: _size.width, height: _size.height);
  }

  ui.Image? get textureImage {
    return this.texture;
  }

  double get angle {
    return this._angle;
  }

  set angle(double value) {
    this._angle = value;
  }

  bool get alive {
    return _alive;
  }

  set alive(bool value) {
    _alive = value;
  }

  Point<double> get center {
    Size size = this.getSize();

    return Point(this.position.x + size.width * 0.5, this.position.y + size.height * 0.5);
  }

  Point<double> getPosition() {
    return this.position;
  }
}
