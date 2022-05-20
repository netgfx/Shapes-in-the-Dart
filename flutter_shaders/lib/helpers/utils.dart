import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart' as uiImage;
import 'package:flutter_shaders/helpers/Circle.dart';

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

  /**
    * Returns the euclidian distance between the two given set of coordinates.
    *
    * @method Phaser.Math#distance
    * @param {number} x1
    * @param {number} y1
    * @param {number} x2
    * @param {number} y2
    * @return {number} The distance between the two sets of coordinates.
    */
  double distance(double x1, double y1, double x2, double y2) {
    var dx = x1 - x2;
    var dy = y1 - y2;

    return sqrt(dx * dx + dy * dy);
  }

  /**
 * Check to see if the Circle contains the given x / y coordinates.
 *
 * @function Phaser.Geom.Circle.Contains
 * @since 3.0.0
 *
 * @param {Phaser.Geom.Circle} circle - The Circle to check.
 * @param {number} x - The x coordinate to check within the circle.
 * @param {number} y - The y coordinate to check within the circle.
 *
 * @return {boolean} True if the coordinates are within the circle, otherwise false.
 */
  bool contains(Circle circle, double x, double y) {
    //  Check if x/y are within the bounds first
    if (circle.radius > 0 && x >= circle.left && x <= circle.right && y >= circle.top && y <= circle.bottom) {
      var dx = (circle.x - x) * (circle.x - x);
      var dy = (circle.y - y) * (circle.y - y);

      return (dx + dy) <= (circle.radius * circle.radius);
    } else {
      return false;
    }
  }

  /**
 * Returns a uniformly distributed random point from anywhere within the given Circle.
 *
 * @function Phaser.Geom.Circle.Random
 * @since 3.0.0
 *
 * @generic {Phaser.Geom.Point} O - [out,$return]
 *
 * @param {Phaser.Geom.Circle} circle - The Circle to get a random point from.
 * @param {(Phaser.Geom.Point|object)} [out] - A Point or point-like object to set the random `x` and `y` values in.
 *
 * @return {(Phaser.Geom.Point|object)} A Point object with the random values set in the `x` and `y` properties.
 */
  Point randomPoint(Circle circle, Point? out) {
    Point _out = out ?? Point(0, 0);

    var t = 2 * pi * _random.nextDouble();
    var u = _random.nextDouble() + _random.nextDouble();
    var r = (u > 1) ? 2 - u : u;
    var x = r * cos(t);
    var y = r * sin(t);

    _out = Point(circle.x + (x * circle.radius), circle.y + (y * circle.radius));

    return _out;
  }

  /**
 * Returns an array of Point objects containing the coordinates of the points around the circumference of the Circle,
 * based on the given quantity or stepRate values.
 *
 * @function Phaser.Geom.Circle.GetPoints
 * @since 3.0.0
 *
 * @param {Phaser.Geom.Circle} circle - The Circle to get the points from.
 * @param {number} quantity - The amount of points to return. If a falsey value the quantity will be derived from the `stepRate` instead.
 * @param {number} [stepRate] - Sets the quantity by getting the circumference of the circle and dividing it by the stepRate.
 * @param {array} [output] - An array to insert the points in to. If not provided a new array will be created.
 *
 * @return {Phaser.Geom.Point[]} An array of Point objects pertaining to the points around the circumference of the circle.
 */
  List<Point> getPoints(Circle circle, double quantity, double stepRate, List<Point> out) {
    List<Point> _out = [];

    //  If quantity is a falsey value (false, null, 0, undefined, etc) then we calculate it based on the stepRate instead.
    if (quantity == 0 && stepRate > 0) {
      quantity = circumference(circle) / stepRate;
    }

    for (var i = 0; i < quantity; i++) {
      var angle = fromPercent(i / quantity, 0, pi * 2);

      out.add(circumferencePoint(circle, angle, null));
    }

    return out;
  }

  double circumference(Circle circle) {
    return 2 * (pi * circle.radius);
  }

  /**
 * Returns a Point object containing the coordinates of a point on the circumference of the Circle
 * based on the given angle normalized to the range 0 to 1. I.e. a value of 0.5 will give the point
 * at 180 degrees around the circle.
 *
 * @function Phaser.Geom.Circle.GetPoint
 * @since 3.0.0
 *
 * @generic {Phaser.Geom.Point} O - [out,$return]
 *
 * @param {Phaser.Geom.Circle} circle - The Circle to get the circumference point on.
 * @param {number} position - A value between 0 and 1, where 0 equals 0 degrees, 0.5 equals 180 degrees and 1 equals 360 around the circle.
 * @param {(Phaser.Geom.Point|object)} [out] - An object to store the return values in. If not given a Point object will be created.
 *
 * @return {(Phaser.Geom.Point|object)} A Point, or point-like object, containing the coordinates of the point around the circle.
 */
  Point getPoint(Circle circle, double position, Point out) {
    var angle = fromPercent(position, 0, pi * 2);

    return circumferencePoint(circle, angle, out);
  }

/**
 * Returns a Point object containing the coordinates of a point on the circumference of the Circle based on the given angle.
 *
 * @function Phaser.Geom.Circle.CircumferencePoint
 * @since 3.0.0
 *
 * @generic {Phaser.Geom.Point} O - [out,$return]
 *
 * @param {Phaser.Geom.Circle} circle - The Circle to get the circumference point on.
 * @param {number} angle - The angle from the center of the Circle to the circumference to return the point from. Given in radians.
 * @param {(Phaser.Geom.Point|object)} [out] - A Point, or point-like object, to store the results in. If not given a Point will be created.
 *
 * @return {(Phaser.Geom.Point|object)} A Point object where the `x` and `y` properties are the point on the circumference.
 */
  Point circumferencePoint(Circle circle, double angle, Point? out) {
    Point _out = out ?? Point(0, 0);

    _out = Point(circle.x + (circle.radius * cos(angle)), circle.y + (circle.radius * sin(angle)));

    return _out;
  }

  /**
 * Return a value based on the range between `min` and `max` and the percentage given.
 *
 * @function Phaser.Math.FromPercent
 * @since 3.0.0
 *
 * @param {number} percent - A value between 0 and 1 representing the percentage.
 * @param {number} min - The minimum value.
 * @param {number} [max] - The maximum value.
 *
 * @return {number} The value that is `percent` percent between `min` and `max`.
 */
  double fromPercent(double percent, double min, double max) {
    percent = clamp(percent, 0, 1);

    return (max - min) * percent + min;
  }

  /**
 * Force a value within the boundaries by clamping it to the range `min`, `max`.
 *
 * @function Phaser.Math.Clamp
 * @since 3.0.0
 *
 * @param {number} value - The value to be clamped.
 * @param {number} min - The minimum bounds.
 * @param {number} max - The maximum bounds.
 *
 * @return {number} The clamped value.
 */
  double clamp(double value, double minValue, double maxValue) {
    return max(minValue, min(maxValue, value));
  }
}
