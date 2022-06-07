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

class TDEnemy {
  /// TODO: Define types in ENUM
  String type = "larva";
  String baseURL = "assets/";
  String extensionStr = ".png";
  ui.Image? textureImage;
  Point<double> position = Point(0, 0);
  double life = 100;
  double speed = 0.0001;
  String imageState = "none";
  Size size = Size(0, 0);
  double scale = 1.0;
  bool _alive = false;
  String _id = "";

  /// pixels per tick
  double ticker = 0;
  int maxCurves = 0;
  int curveIndex = 0;
  double angle = 0;
  int textureWidth = 0;
  int textureHeight = 0;
  List<CubicBezier> quadBeziers = [];

  TDEnemy({
    required this.type,
    required this.maxCurves,
    required this.life,
    required this.speed,
    required this.quadBeziers,
    required this.scale,
    position,
  }) {
    TDWorld? world = GameObject.shared.getWorld();
    if (world != null) {
      this.id = world.add(this, null);
    }
    this.position = position ?? Point(0, 0);
    loadImage();
  }

  void update(Canvas canvas) {
    if (this.imageState == "done") {
      ticker += this.speed;
      vectorMath.Vector2 point = vectorMath.Vector2(0, 0);
      if (ticker >= 1.0 && this.curveIndex < this.maxCurves) {
        ticker = 0.0;
        this.curveIndex += 1;
        //offset = offset == 0 ? 1 : 0;
      }
      if (this.curveIndex >= this.maxCurves) {
        ticker = 1.0;
        this.curveIndex = this.maxCurves;
      }

      vectorMath.Vector2 oldValues = vectorMath.Vector2(this.position.x, this.position.y);
      if (this.curveIndex == this.maxCurves) {
        point = getCurvePoint(0.99);
        this.position = Point(point.x, point.y);
      } else {
        point = getCurvePoint(this.ticker);
        this.position = Point(point.x, point.y);
      }

      double _angle = Utils.shared.angleBetween(oldValues.x, oldValues.y, position.x, position.y);
      this.angle = _angle + pi / 2; //vectorMath.radians(_angle + (360 / 3) * 1);

      if (this.imageState == "done") {
        drawEnemy(canvas);
      }
    }
  }

  vectorMath.Vector2 getNextPoint(double perc) {
    vectorMath.Vector2 nextPoint = vectorMath.Vector2(0, 0);
    if (perc + 0.05 > 1) {
      nextPoint = this.quadBeziers[(this.curveIndex + 1).clamp(0, this.maxCurves - 1)].pointAt(0);
    } else {
      nextPoint = this.quadBeziers[(this.curveIndex + 1).clamp(0, this.maxCurves - 1)].pointAt(perc + 0.1);
    }

    return nextPoint;
  }

  vectorMath.Vector2 getCurvePoint(double perc, {int? index: null}) {
    int _index = index ?? this.curveIndex.clamp(0, this.maxCurves - 1);
    //delayedPrint('>>> ${(perc.clamp(0, 1)).toString()} ${curveIndex}');
    var _perc = perc;
    if (perc < 0) {
      _perc = 0;
    } else if (perc > 1) {
      _perc = 1;
    } else {
      _perc = perc.clamp(0, 1);
    }
    return quadBeziers[_index].pointAt(_perc);
  }

  Future<ui.Image?> loadImage() async {
    /// cache these externally
    imageState = "loading";
    final ByteData data = await rootBundle.load(baseURL + this.type + extensionStr);
    textureImage = await Utils.shared.imageFromBytes(data);
    this.textureWidth = textureImage!.width;
    this.textureHeight = textureImage!.height;
    setEnemySize(textureImage!);
    imageState = "done";
    alive = true;
  }

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

  void setEnemySize(ui.Image img) {
    double aspectRatio = img.width / img.height;
    int height = (img.height * this.scale).round();
    int width = (height * aspectRatio).round();
    this.size = Size(width.toDouble(), height.toDouble());
    //print("size: $size");
  }

  void drawEnemy(Canvas canvas) {
    var paint = new Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = false;

    rotate(canvas, position.x, position.y, angle, () {
      canvas.drawImageRect(
        this.enemyTexture!,
        Rect.fromLTWH(0, 0, textureWidth.toDouble(), textureHeight.toDouble()),
        Rect.fromLTWH(-size.width / 2, -size.height / 2, size.width, size.height),
        paint,
      );
    });

    Rectangle rect = getEnemyRect();
    drawRect(canvas, rect.x, rect.y, rect.width, rect.height);
  }

  void drawRect(Canvas canvas, double x, double y, double w, double h) {
    var _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    rotate(canvas, x, y, null, () {
      canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2, w, h), _paint);
      //canvas.drawCircle(Offset(0, 0), radius, _paint);
    }, translate: true);
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

  ui.Image? get enemyTexture {
    return this.textureImage;
  }

  double get enemyAngle {
    return this.angle;
  }

  Point<double> get enemyCenter {
    Size size = this.getEnemySize();

    return Point(this.position.x + size.width * 0.5, this.position.y + size.height * 0.5);
  }
}
