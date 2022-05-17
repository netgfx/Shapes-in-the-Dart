import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
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
  static const degreeToRadiansFactor = pi / 180;
  static const radianToDegreesFactor = 180 / pi;
  int printTime = DateTime.now().millisecondsSinceEpoch;

  double radToDeg(radians) {
    return radians * radianToDegreesFactor;
  }

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

  Color randomColor(double alpha) {
    int r = (_random.nextDouble() * 255).floor();
    int g = (_random.nextDouble() * 255).floor();
    int b = (_random.nextDouble() * 255).floor();
    int a = (alpha * 255).floor();

    return Color.fromARGB(a, r, g, b);
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

  void delayedPrint(String str) {
    if (DateTime.now().millisecondsSinceEpoch - this.printTime > 10) {
      this.printTime = DateTime.now().millisecondsSinceEpoch;
      print(str);
    }
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

  /**
    * Find the angle of a segment from (x1, y1) -> (x2, y2).
    * 
    * @method Phaser.Math#angleBetween
    * @param {number} x1 - The x coordinate of the first value.
    * @param {number} y1 - The y coordinate of the first value.
    * @param {number} x2 - The x coordinate of the second value.
    * @param {number} y2 - The y coordinate of the second value.
    * @return {number} The angle, in radians.
    */
  double angleBetween(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }

  /**
    * Rotates currentAngle towards targetAngle, taking the shortest rotation distance.
    * The lerp argument is the amount to rotate by in this call.
    * 
    * @method Phaser.Math#rotateToAngle
    * @param {number} currentAngle - The current angle, in radians.
    * @param {number} targetAngle - The target angle to rotate to, in radians.
    * @param {number} [lerp=0.05] - The lerp value to add to the current angle.
    * @return {number} The adjusted angle.
    */
  double rotateToAngle(double currentAngle, double targetAngle, {double lerp = 0.05}) {
    const PI2 = pi * 2;

    if (currentAngle == targetAngle) {
      return currentAngle;
    }

    if ((targetAngle - currentAngle).abs() <= lerp || (targetAngle - currentAngle).abs() >= (PI2 - lerp)) {
      currentAngle = targetAngle;
    } else {
      if ((targetAngle - currentAngle).abs() > pi) {
        if (targetAngle < currentAngle) {
          targetAngle += PI2;
        } else {
          targetAngle -= PI2;
        }
      }

      if (targetAngle > currentAngle) {
        currentAngle += lerp;
      } else if (targetAngle < currentAngle) {
        currentAngle -= lerp;
      }
    }

    return currentAngle;
  }
}
