import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/game_classes/TDBullet.dart';
import 'package:flutter_shaders/game_classes/TDEnemy.dart';
import 'package:flutter_shaders/game_classes/TDSpriteAnimator.dart';
import 'package:flutter_shaders/game_classes/TDWorld.dart';
import 'package:flutter_shaders/helpers/Circle.dart';
import 'package:flutter_shaders/helpers/GameObject.dart';
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
  double rof = 500.0;
  int lastShot = 0;
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
  List<TDBullet> bullets = [];
  Rectangle radar = Rectangle(x: 0, y: 0, width: 0, height: 0); //Circle(x: 0, y: 0, radius: 40);

  List<TDSpriteAnimator> collisionEffects = [];
  TDTower({
    required this.position,
    required this.baseType,
    required this.turretType,
    required this.rof,
    required this.scale,
  }) {
    this.position = position ?? Point(0, 0);
    loadBaseImage();
    loadTurretImage(makeBullets);
    collisionEffects.add(TDSpriteAnimator(
        position: Point(0, 0),
        texturePath: "assets/bug_explode.png",
        currentFrame: "Bat__Booger_FX",
        jsonPath: "assets/bug_explode.json",
        delimiters: [
          "Bat__Booger_FX",
        ],
        fps: 1,
        loop: LoopMode.Single,
        scale: 0.25));
  }

  void update(Canvas canvas, List<TDEnemy> enemies, Rectangle? worldBounds) {
    this.enemies = enemies;
    for (var i = 0; i < enemies.length; i++) {
      Size enemySize = enemies[i].getEnemySize();
      Size _size = getSize(turretImage);
      Point<double> enemyCenter = Point(enemies[i].getEnemyRect().left, enemies[i].getEnemyRect().top);

      if (radar.contains(enemies[i].position.x, enemies[i].position.y)) {
        //print("contains ${enemyCenter}");
        double _angle = Utils.shared.angleBetween(
          this.position.x + _size.width / 2,
          this.position.y + _size.height / 2,
          enemyCenter.x,
          enemyCenter.y,
        );
        double deg = Utils.shared.radToDeg(_angle);
        this.angle = _angle + pi / 2; //Utils.shared.rotateToAngle(this.angle, _angle + pi / 2, lerp: 0.1);
        var diff = DateTime.now().millisecondsSinceEpoch - this.lastShot >= this.rof;
        //print("diff: ${diff.toString()}");
        //print("rof: ${this.rof.toString()}");

        if (DateTime.now().millisecondsSinceEpoch - this.lastShot >= this.rof) {
          this.shootBullet(enemyCenter);
          this.lastShot = DateTime.now().millisecondsSinceEpoch;
        }
      }

      // draw world bounds
      if (worldBounds != null) {
        drawRectBorder(canvas, 0, 0, worldBounds.width, worldBounds.height);
      }
    }

    if (this.baseState == "done") {
      drawBase(canvas);
    }
    if (this.turretState == "done") {
      drawTurret(canvas);
      setTowerRadar(canvas);
    }

    drawBullets(canvas);

    // do collision check
    performCollisionChecks();

    drawCollisionEffects(canvas);
  }

  void performCollisionChecks() {
    TDWorld? _world = GameObject.shared.getWorld();
    int _enemiesLength = this.enemies.length;
    int _bulletsLength = this.bullets.length;
    for (var i = 0; i < _enemiesLength; i++) {
      Map<String, dynamic> objA = {"type": "solo", "object": this.enemies[i]};
      for (var j = 0; j < _bulletsLength; j++) {
        Map<String, dynamic> objB = {"type": "solo", "object": this.bullets[j]};
        if (_world != null) {
          bool result = _world.checkCollision({"a": objA, "b": objB});
          if (result == true) {
            this.bullets[j].alive = false;
            showCollisionEffect(this.enemies[i].enemyPosition);
          }
        }
      }
    }
  }

  void showCollisionEffect(Point<double> target) {
    var effect = this.collisionEffects.cast<TDSpriteAnimator?>().firstWhere((element) => element!.alive == false, orElse: () => null);
    if (effect != null) {
      effect.alive = true;
      effect.setPosition(target);
    } else {
      Size _size = getSize(turretImage!);

      TDSpriteAnimator _effect = TDSpriteAnimator(
          position: target,
          texturePath: "assets/bug_explode.png",
          currentFrame: "Bat__Booger_FX",
          jsonPath: "assets/bug_explode.json",
          delimiters: [
            "Bat__Booger_FX",
          ],
          fps: 1,
          loop: LoopMode.Single,
          scale: 0.25);
      _effect.alive = true;

      this.collisionEffects.add(_effect);
    }
  }

  void drawCollisionEffects(Canvas canvas) {
    if (this.collisionEffects.length > 0) {
      for (var i = 0; i < this.collisionEffects.length; i++) {
        if (this.collisionEffects[i].alive == true) {
          this.collisionEffects[i].update(canvas);
        }
      }
    }
  }

  void drawBullets(Canvas canvas) {
    if (this.bullets.length > 0) {
      for (var i = 0; i < this.bullets.length; i++) {
        if (this.bullets[i].alive == true) {
          this.bullets[i].update(canvas);
        }
      }
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

  Point originPosition() {
    if (turretState == "done") {
      Size _size = getSize(turretImage!);
      return Point(this.position.x + _size.width / 2, this.position.y + _size.height / 2);
    } else {
      return Point(0, 0);
    }
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

  /// Make the bullets
  void makeBullets() {
    Size _size = getSize(turretImage!);
    for (var i = 0; i < 1; i++) {
      this.bullets.add(new TDBullet(x: this.position.x + _size.width / 2, y: this.position.y + _size.height / 2, velocity: 0.1));
    }
  }

  void shootBullet(Point target) {
    if (this.bullets.length > 0) {
      Point origin = originPosition();
      Point _target = Utils.shared.extendLine(100, origin, target);

      /// take the first inactive bullet
      var bullet = this.bullets.cast<TDBullet?>().firstWhere((element) => element!.alive == false, orElse: () => null);
      if (bullet != null) {
        bullet.alive = true;
        bullet.target = _target;
      } else {
        Size _size = getSize(turretImage!);
        TDBullet _bullet = new TDBullet(x: this.position.x + _size.width / 2, y: this.position.y + _size.height / 2, velocity: 0.1);
        _bullet.alive = true;
        _bullet.target = _target;
        this.bullets.add(_bullet);
      }
    }
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

  void loadTurretImage(Function? onComplete) async {
    /// cache these externally
    turretState = "loading";
    final ByteData data = await rootBundle.load(baseURL + this.turretType + extensionStr);
    turretImage = await Utils.shared.imageFromBytes(data);
    turretTextureWidth = turretImage!.width;
    turretTextureHeight = turretImage!.height;
    turretState = "done";

    if (onComplete != null) {
      onComplete();
    }
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

  void drawRectBorder(Canvas canvas, double x, double y, double w, double h) {
    var _paint = Paint()
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = true
      ..color = Colors.red.withOpacity(1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    rotate(canvas, x, y, 0, () {
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _paint);
      //canvas.drawCircle(Offset(0, 0), radius, _paint);
    }, translate: true);
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
