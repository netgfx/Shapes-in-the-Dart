import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:bezier/bezier.dart";
import "../helpers//utils.dart";
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
  double speed = 0.1;
  String imageState = "none";
  Size size = Size(0, 0);
  double scale = 1.0;

  /// pixels per tick
  double ticker = 0;
  int maxCurves = 0;
  int curveIndex = 0;
  double angle = 0;
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
    this.position = position ?? Point(0, 0);
    loadImage();
  }

  void update() {
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

    this.angle = Utils.shared.radToDeg(Utils.shared.angleBetween(oldValues.x, oldValues.y, position.x, position.y));
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
    setEnemySize(textureImage!);
    imageState = "done";
  }

  Size getEnemySize() {
    return size;
  }

  void setEnemySize(ui.Image img) {
    double aspectRatio = img.width / img.height;
    int height = (img.height * this.scale).round();
    int width = (height * aspectRatio).round();
    this.size = Size(width.toDouble(), height.toDouble());
    //print("size: $size");
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
}
