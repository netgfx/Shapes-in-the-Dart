import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart' as uiImage;

enum Easing {
  LINEAR,
  EASE_OUT_BACK,
  EASE_OUT_SINE,
  EASE_OUT_CIRC,
  EASE_OUT_QUART,
  EASE_OUT_QUAD,
  EASE_OUT_CUBIC,
  EASE_IN_OUT_BACK,
}

class Utils {
  static Utils shared = Utils._();
  final _random = new Random();
  Utils._();

  static Utils get instance => shared;

  double doubleInRange(
    double start,
    double end,
  ) {
    if (start == end) {
      return start;
    } else {
      return _random.nextDouble() * (end - start) + start;
    }
  }

  double randomDelay({
    double min = 0.005,
    double max = 0.05,
  }) {
    if (min == max) {
      return min;
    } else {
      return doubleInRange(min, max);
    }
  }

  double easeOutBack(
    double x,
  ) {
    const c1 = 1.70158;
    const c3 = c1 + 1;

    return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2);
  }

  double easeOutCirc(
    double x,
  ) {
    return sqrt(1 - pow(x - 1, 2));
  }

  double easeOutQuart(
    double x,
  ) {
    return 1 - pow(1 - x, 4).toDouble();
  }

  double easeOutQuad(
    double x,
  ) {
    return 1 - (1 - x) * (1 - x);
  }

  double easeOutCubic(
    double x,
  ) {
    return 1 - pow(1 - x, 3).toDouble();
  }

  double easeOutSine(
    double x,
  ) {
    return sin((x * pi) / 2);
  }

  double easeOutQuint(
    double x,
  ) {
    return 1 - pow(1 - x, 5).toDouble();
  }

  double easeInOutBack(
    double x,
  ) {
    const c1 = 1.70158;
    const c2 = c1 * 1.525;

    return x < 0.5 ? (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2 : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
  }

  bool chanceRoll(
    double? chance,
  ) {
    if (chance == null) {
      chance = 50;
    }
    return chance > 0 && (_random.nextDouble() * 100 <= chance);
  }

  Future<ui.Image> imageFromBytes(
    ByteData data,
  ) async {
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Future<Map<String, dynamic>?> loadSprite(
    String name,
    String jsonPath,
    String texturePath,
    List<String> delimiters,
    Function setTextureCache,
    Function setCache,
  ) async {
    final ByteData data = await rootBundle.load(texturePath);
    var textureImage = await Utils.shared.imageFromBytes(data);
    setTextureCache(name, textureImage);
    if (jsonPath != "") {
      var value = await loadJsonData(jsonPath);

      var spriteData = parseJSON(value, delimiters);

      setCache(name, spriteData);

      return {
        "data": spriteData,
        "texture": textureImage,
      };
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> loadJsonData(
    String path,
  ) async {
    var jsonText = await rootBundle.loadString(path);
    Map<String, dynamic> data = json.decode(jsonText);
    return data;
  }

  Map<String, List<Map<String, dynamic>>> parseJSON(
    Map<String, dynamic> data,
    List<String> delimiters,
  ) {
    Map<String, List<Map<String, dynamic>>> sprites = {};
    for (var key in delimiters) {
      sprites[key] = [];
      data["frames"].forEach((innerKey, value) {
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
}
