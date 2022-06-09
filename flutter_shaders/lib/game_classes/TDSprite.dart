import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/game_classes/TDWorld.dart';
import 'package:flutter_shaders/helpers/GameObject.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:bezier/bezier.dart";
import "../helpers//utils.dart";
import "../helpers/Rectangle.dart";
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

class TDSprite {
  double scale = 1.0;
  bool _alive = false;
  String _id = "";
  ui.Image? textureImage;
  Size size = Size(0, 0);
  int textureWidth = 0;
  int textureHeight = 0;
  String imageState = "none";
  TDWorld? world = GameObject.shared.getWorld();
  String textureURL = "";
  Point<double> position = Point(0, 0);
  double _angle = 0;
  Canvas canvas;

  ///
  TDSprite({required this.textureURL, required this.canvas}) {}

  ///
  bool get alive {
    return this._alive;
  }

  set alive(bool value) {
    this._alive = value;
  }

  Size getEnemySize() {
    return size;
  }

  String get id {
    return this._id;
  }

  set id(String value) {
    this._id = value;
  }

  Future<ui.Image?> loadImage() async {
    /// cache these externally
    imageState = "loading";
    final ByteData data = await rootBundle.load(textureURL);
    textureImage = await Utils.shared.imageFromBytes(data);
    this.textureWidth = textureImage!.width;
    this.textureHeight = textureImage!.height;
    setEnemySize(textureImage!);
    imageState = "done";
    alive = true;
  }

  void setEnemySize(ui.Image img) {
    double aspectRatio = img.width / img.height;
    int height = (img.height * this.scale).round();
    int width = (height * aspectRatio).round();
    this.size = Size(width.toDouble(), height.toDouble());
    //print("size: $size");
  }

  void update() {
    if (this.imageState == "done") {
      drawSprite(canvas);
    }
  }

  void drawSprite(Canvas canvas) {
    var paint = new Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = false;

    updateCanvas(canvas, position.x, position.y, angle, () {
      canvas.drawImageRect(
        this.textureImage!,
        Rect.fromLTWH(0, 0, textureWidth.toDouble(), textureHeight.toDouble()),
        Rect.fromLTWH(-size.width / 2, -size.height / 2, size.width, size.height),
        paint,
      );
    });

    Rectangle rect = getEnemyRect();
  }

  void updateCanvas(Canvas canvas, double? x, double? y, double? angle, VoidCallback callback, {bool translate = false}) {
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

  Rectangle getEnemyRect() {
    Size _size = getEnemySize();
    return Rectangle(x: this.position.x, y: this.position.y, width: _size.width, height: _size.height);
  }

  Rectangle getBounds() {
    Size _size = getEnemySize();
    return Rectangle(x: this.position.x, y: this.position.y, width: _size.width, height: _size.height);
  }

  Point<double> get enemyPosition {
    return this.position;
  }

  ui.Image? get texture {
    return this.textureImage;
  }

  double get angle {
    return this._angle;
  }

  set angle(double value) {
    this._angle = value;
  }

  Point<double> get enemyCenter {
    Size size = this.getEnemySize();

    return Point(this.position.x + size.width * 0.5, this.position.y + size.height * 0.5);
  }
}
