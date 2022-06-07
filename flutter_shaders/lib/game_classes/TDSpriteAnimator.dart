import 'dart:convert';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_shaders/helpers/utils.dart';

enum LoopMode {
  Single,
  Repeat,
}

class TDSpriteAnimator {
  Canvas? canvas;
  double timeDecay = 250;
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  late ui.Image currentImage;
  String currentFrame = "";
  Map<String, List<Map<String, dynamic>>> spriteData = {};
  List<String> delimiters = [];
  double fps = 250;
  LoopMode loop;
  ui.Image? texture;
  int currentIndex = 0;
  String texturePath = "";
  String jsonPath = "";
  String textureLoadState = "none";
  double scale = 1.0;
  Point<double> position = Point(0, 0);
  bool _alive = false;
  Paint _paint = new Paint();
  TDSpriteAnimator({
    required this.position,
    required this.texturePath,
    required this.currentFrame,
    required this.jsonPath,
    required this.delimiters,
    required this.fps,
    required this.loop,
    scale,
  }) {
    print("draw animation sprite ${this.fps}");
    this.fps = (1 / this.fps) * 1000;
    this.timeDecay = 48; //this.fps;
    print("fps ${this.fps} decay: ${this.timeDecay}");

    this.scale = scale ?? 1.0;
    loadSprite();
  }

  void update(Canvas canvas) {
    if (textureLoadState == "done" && alive == true) {
      var img = spriteData[currentFrame]![currentIndex];
      Point<double> pos = Point(position.x - 133.0 / 2, position.y - 133.0 / 2);

      /// this component needs its own tick
      if (DateTime.now().millisecondsSinceEpoch - this.currentTime >= this.timeDecay) {
        this.currentTime = DateTime.now().millisecondsSinceEpoch;
        updateCanvas(canvas, pos.x, pos.y, scale, () {
          canvas.drawImageRect(
            this.texture!,
            Rect.fromLTWH(img["x"].toDouble(), img["y"].toDouble(), img["width"].toDouble(), img["height"].toDouble()),
            Rect.fromLTWH(0, 0, img["width"].toDouble(), img["height"].toDouble()),
            _paint,
          );
        }, translate: false);

        currentIndex++;

        if (currentIndex >= spriteData[currentFrame]!.length) {
          this.alive = false;
          currentIndex = 0;
        }
      } else {
        // do nothing?
        updateCanvas(canvas, pos.x, pos.y, scale, () {
          canvas.drawImageRect(
            this.texture!,
            Rect.fromLTWH(img["x"].toDouble(), img["y"].toDouble(), img["width"].toDouble(), img["height"].toDouble()),
            Rect.fromLTWH(0, 0, img["width"].toDouble(), img["height"].toDouble()),
            _paint,
          );
        }, translate: false);
      }
    }
  }

  void loadSprite() async {
    textureLoadState = "loading";
    final ByteData data = await rootBundle.load(texturePath);
    this.texture = await Utils.shared.imageFromBytes(data);

    if (jsonPath != "") {
      var data = loadJsonData(jsonPath);
      data.then((value) => {spriteData = parseJSON(value), print("${spriteData}, ${spriteData[currentFrame]!.length}")});

      textureLoadState = "done";
    } else {
      textureLoadState = "none";
    }
  }

  Future<Map<String, dynamic>> loadJsonData(String path) async {
    var jsonText = await rootBundle.loadString(path);
    Map<String, dynamic> data = json.decode(jsonText);
    return data;
  }

  Map<String, List<Map<String, dynamic>>> parseJSON(Map<String, dynamic> data) {
    Map<String, List<Map<String, dynamic>>> sprites = {};
    for (var key in delimiters) {
      sprites[key] = [];
      data["frames"].forEach((innerKey, value) {
        print(innerKey);
        final frameData = value['frame'];
        final int x = frameData['x'];
        final int y = frameData['y'];
        final int width = frameData['w'];
        final int height = frameData['h'];
        if ((innerKey as String).contains(key) == true) {
          sprites[key]!.add({"x": x, "y": y, "width": width, "height": height});
        }
      });
    }

    return sprites;
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

  void updateCanvas(Canvas canvas, double? x, double? y, double? scale, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas.save();

    if (translate) {
      canvas.translate(_x, _y);
    }

    if (scale != null) {
      canvas.translate(_x, _y);
      canvas.scale(scale);
    }
    callback();
    canvas.restore();
  }
}
