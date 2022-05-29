import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/game_classes/TDEnemy.dart';
import 'package:flutter_shaders/helpers/Circle.dart';
import 'package:flutter_shaders/helpers/Rectangle.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:bezier/bezier.dart";
import "../helpers//utils.dart";
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

class TDTower {
  /// TODO: Define types in ENUM
  String baseType = "base1";
  String turretType = "cannon1";
  String baseURL = "assets/td/";
  String extensionStr = ".png";
  ui.Image? baseImage;
  ui.Image? turretImage;
  Point<double> position = Point(0, 0);

  /// rate of fire
  double rof = 1.0;
  double damage = 1.0;

  ///
  String turretState = "none";
  String baseState = "none";
  Size size = Size(0, 0);
  double scale = 1.0;

  int curveIndex = 0;
  double angle = 0;
  int baseTextureWidth = 0;
  int baseTextureHeight = 0;
  int turretTextureWidth = 0;
  int turretTextureHeight = 0;
  List<TDEnemy> enemies = [];
  Rectangle radar = Rectangle(x: 0, y: 0, width: 0, height: 0); //Circle(x: 0, y: 0, radius: 40);

  TDTower({
    required this.position,
    required this.baseType,
    required this.turretType,
    required this.rof,
    required this.scale,
  }) {
    this.position = position ?? Point(0, 0);
    loadBaseImage();
    loadTurretImage();
  }

  void update(Canvas canvas, List<TDEnemy> enemies) {
    this.enemies = enemies;
    for (var i = 0; i < enemies.length; i++) {
      Size enemySize = enemies[i].getEnemySize();
      Size _size = getSize(turretImage);
      Point<double> enemyCenter = Point(enemies[i].getEnemyRect().left, enemies[i].getEnemyRect().top);

      // if (radar.contains(enemies[i].position.x, enemies[i].position.y)) {
      //print("contains ${enemyCenter}");
      double _angle = Utils.shared.angleBetween(
        this.position.x + _size.width / 2,
        this.position.y + _size.height / 2,
        enemyCenter.x,
        enemyCenter.y,
      );
      double deg = Utils.shared.radToDeg(_angle);
      this.angle = Utils.shared.rotateToAngle(this.angle, _angle + pi / 2, lerp: 0.1);
    }
    if (this.baseState == "done") {
      drawBase(canvas);
    }
    if (this.turretState == "done") {
      drawTurret(canvas);
      setTowerRadar(canvas);
    }
  }

  void drawBase(Canvas canvas) {
    var paint = new Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = false;

    Size baseSize = getSize(baseImage!);
    rotate(canvas, 0, 0, 0, () {
      canvas.drawImageRect(
        baseImage!,
        Rect.fromLTWH(0, 0, baseTextureWidth.toDouble(), baseTextureHeight.toDouble()),
        Rect.fromLTWH(this.position.x, this.position.y, baseSize.width, baseSize.height),
        paint,
      );
    });
  }

  void drawTurret(Canvas canvas) {
    var paint = new Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = false;

    Size _size = getSize(turretImage!);
    rotate(canvas, this.position.x + _size.width / 2, this.position.y + _size.height / 2, this.angle, () {
      canvas.drawImageRect(
        turretImage!,
        Rect.fromLTWH(0, 0, turretTextureWidth.toDouble(), turretTextureHeight.toDouble()),
        Rect.fromLTWH(-_size.width / 2, -_size.height / 2 - 10, _size.width, _size.height),
        paint,
      );
    });

    Point<double> enemyCenter = Point(enemies[0].getEnemyRect().left, enemies[0].getEnemyRect().centerY);
    double dist = Utils.shared.distance(enemyCenter.x, enemyCenter.y, position.x + _size.width / 2, position.y + _size.height / 2);
    drawRect(canvas, this.position.x + _size.width / 2, this.position.y + _size.height / 2, dist, 5);
    // drawLine(
    //   canvas,
    //   Point(this.position.x + _size.width / 2, this.position.y + _size.height / 2),
    //   Point(enemyCenter.x, enemyCenter.y),
    // );
  }

  Size getSize(ui.Image? img) {
    if (img == null) {
      return Size(0, 0);
    }
    double aspectRatio = img.width / img.height;
    int height = (img.height * this.scale).round();
    int width = (height * aspectRatio).round();
    return Size(width.toDouble(), height.toDouble());
    //print("size: $size");
  }

  void loadBaseImage() async {
    /// cache these externally
    baseState = "loading";
    final ByteData data = await rootBundle.load(baseURL + this.baseType + extensionStr);
    baseImage = await Utils.shared.imageFromBytes(data);
    baseTextureWidth = baseImage!.width;
    baseTextureHeight = baseImage!.height;
    baseState = "done";
  }

  void loadTurretImage() async {
    /// cache these externally
    turretState = "loading";
    final ByteData data = await rootBundle.load(baseURL + this.turretType + extensionStr);
    turretImage = await Utils.shared.imageFromBytes(data);
    turretTextureWidth = turretImage!.width;
    turretTextureHeight = turretImage!.height;
    turretState = "done";
  }

  void setTowerRadar(Canvas canvas) {
    //print("making radar ${this.position}");
    Size _size = this.getSize(baseImage!);
    double radius = 350;
    radar = Rectangle(
      x: this.position.x,
      y: this.position.y - 150,
      width: radius,
      height: radius,
    );
    // Circle(
    //   x: this.position.x + radius + _size.width * 0.5,
    //   y: this.position.y + radius + _size.height * 0.5,
    //   radius: radius,
    // );

    drawRadar(canvas, radar.left, radar.top, radius);
  }

  void drawRadar(Canvas canvas, double x, double y, double radius) {
    var _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.red.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    rotate(canvas, x, y, null, () {
      canvas.drawRect(Rect.fromLTWH(0, 0, radius, radius), _paint);
      //canvas.drawCircle(Offset(0, 0), radius, _paint);
    }, translate: true);
  }

  void drawRect(Canvas canvas, double x, double y, double w, double h) {
    var _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.purple.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    rotate(canvas, x, y, this.angle - pi / 2, () {
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _paint);
      //canvas.drawCircle(Offset(0, 0), radius, _paint);
    }, translate: false);
  }

  void drawLine(Canvas canvas, Point a, Point b) {
    var _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    rotate(canvas, 0, 0, null, () {
      canvas.drawLine(Offset(a.x.toDouble(), a.y.toDouble()), Offset(b.x.toDouble(), b.y.toDouble()), _paint);
      //canvas.drawCircle(Offset(0, 0), radius, _paint);
    }, translate: false);
  }

  void rotate(Canvas canvas, double? x, double? y, double? angle, VoidCallback callback, {bool translate = false}) {
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

  double get towerAngle {
    return this.angle;
  }
}
