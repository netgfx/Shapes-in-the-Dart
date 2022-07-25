import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart' as uiImage;
import 'package:flutter_shaders/game_classes/EntitySystem/sprite_archetype.dart';
import 'package:flutter_shaders/helpers/Circle.dart';
import 'package:flutter_shaders/helpers/Rectangle.dart';

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

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
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

  Future<ui.Image?> imageFromBytes(
    ByteData data,
  ) async {
    try {
      ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (error) {
      print(error);
    }
    return null;
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

  Point<double> calculateXY(int canvasWidth, int canvasHeight, int width, int height, double angle) {
    //calculate where the top left corner of the object would be relative to center of the canvas
    //if the object had no rotation and was centered
    double x = -width / 2;
    double y = -height / 2;

    //rotate relative x and y coordinates by angle degrees
    double sinA = sin(angle * pi / 180);
    double cosA = cos(angle * pi / 180);
    double xRotated = x * cosA - y * sinA;
    double yRotated = x * sinA + y * cosA;

    //translate relative coordinates back to absolute
    double canvasCenterX = canvasWidth / 2;
    double canvasCenterY = canvasHeight / 2;
    double finalX = xRotated + canvasCenterX;
    double finalY = yRotated + canvasCenterY;

    return Point(finalX, finalY);
  }

  /**
    * Gets the shortest angle between `angle1` and `angle2`.
    * Both angles must be in the range -180 to 180, which is the same clamped
    * range that `sprite.angle` uses, so you can pass in two sprite angles to
    * this method, and get the shortest angle back between the two of them.
    *
    * The angle returned will be in the same range. If the returned angle is
    * greater than 0 then it's a counter-clockwise rotation, if < 0 then it's
    * a clockwise rotation.
    * 
    * @method Phaser.Math#getShortestAngle
    * @param {number} angle1 - The first angle. In the range -180 to 180.
    * @param {number} angle2 - The second angle. In the range -180 to 180.
    * @return {number} The shortest angle, in degrees. If greater than zero it's a counter-clockwise rotation.
    */
  double getShortestAngle(angle1, angle2) {
    var difference = angle2 - angle1;

    if (difference == 0) {
      return 0;
    }

    var times = ((difference - (-180)) / 360).floor();

    return difference - (times * 360);
  }

  /**
* Increases the size of the Rectangle object by the specified amounts. The center point of the Rectangle object stays the same, and its size increases to the left and right by the dx value, and to the top and the bottom by the dy value.
* @method Phaser.Rectangle.inflate
* @param {Phaser.Rectangle} a - The Rectangle object.
* @param {number} dx - The amount to be added to the left side of the Rectangle.
* @param {number} dy - The amount to be added to the bottom side of the Rectangle.
* @return {Phaser.Rectangle} This Rectangle object.
*/
  inflate(Rectangle a, double dx, double dy) {
    a.x -= dx;
    a.width += 2 * dx;
    a.y -= dy;
    a.height += 2 * dy;

    return a;
  }

/**
* Increases the size of the Rectangle object. This method is similar to the Rectangle.inflate() method except it takes a Point object as a parameter.
* @method Phaser.Rectangle.inflatePoint
* @param {Phaser.Rectangle} a - The Rectangle object.
* @param {Phaser.Point} point - The x property of this Point object is used to increase the horizontal dimension of the Rectangle object. The y property is used to increase the vertical dimension of the Rectangle object.
* @return {Phaser.Rectangle} The Rectangle object.
*/
  inflatePoint(Rectangle a, Point<double> point) {
    return inflate(a, point.x, point.y);
  }

  /**
* Adds two Rectangles together to create a new Rectangle object, by filling in the horizontal and vertical space between the two Rectangles.
* @method Phaser.Rectangle.union
* @param {Phaser.Rectangle} a - The first Rectangle object.
* @param {Phaser.Rectangle} b - The second Rectangle object.
* @param {Phaser.Rectangle} [output] - Optional Rectangle object. If given the new values will be set into this object, otherwise a brand new Rectangle object will be created and returned.
* @return {Phaser.Rectangle} A Rectangle object that is the union of the two Rectangles.
*/
  union(Rectangle a, Rectangle b) {
    return Rectangle(
        x: min(a.x, b.x), y: min(a.y, b.y), width: max(a.right, b.right) - min(a.left, b.left), height: max(a.bottom, b.bottom) - min(a.top, b.top));
  }

  /**
* Determines whether the two Rectangles are equal.
* This method compares the x, y, width and height properties of each Rectangle.
* @method Phaser.Rectangle.equals
* @param {Phaser.Rectangle} a - The first Rectangle object.
* @param {Phaser.Rectangle} b - The second Rectangle object.
* @return {boolean} A value of true if the two Rectangles have exactly the same values for the x, y, width and height properties; otherwise false.
*/
  equals(Rectangle a, Rectangle b) {
    return (a.x == b.x && a.y == b.y && a.width == b.width && a.height == b.height);
  }

  /**
* Determines whether the specified point is contained within the rectangular region defined by this Rectangle object. This method is similar to the Rectangle.contains() method, except that it takes a Point object as a parameter.
* @method Phaser.Rectangle.containsPoint
* @param {Phaser.Rectangle} a - The Rectangle object.
* @param {Phaser.Point} point - The point object being checked. Can be Point or any object with .x and .y values.
* @return {boolean} A value of true if the Rectangle object contains the specified point; otherwise false.
*/
  containsPoint(a, point) {
    return contains(a, point.x, point.y);
  }

/**
* Determines if the two objects (either Rectangles or Rectangle-like) have the same width and height values under strict equality.
* @method Phaser.Rectangle.sameDimensions
* @param {Rectangle-like} a - The first Rectangle object.
* @param {Rectangle-like} b - The second Rectangle object.
* @return {boolean} True if the object have equivalent values for the width and height properties.
*/
  sameDimensions(Rectangle a, Rectangle b) {
    return (a.width == b.width && a.height == b.height);
  }

  /**
* If the Rectangle object specified in the toIntersect parameter intersects with this Rectangle object, returns the area of intersection as a Rectangle object. If the Rectangles do not intersect, this method returns an empty Rectangle object with its properties set to 0.
* @method Phaser.Rectangle.intersection
* @param {Phaser.Rectangle} a - The first Rectangle object.
* @param {Phaser.Rectangle} b - The second Rectangle object.
* @param {Phaser.Rectangle} [output] - Optional Rectangle object. If given the intersection values will be set into this object, otherwise a brand new Rectangle object will be created and returned.
* @return {Phaser.Rectangle} A Rectangle object that equals the area of intersection. If the Rectangles do not intersect, this method returns an empty Rectangle object; that is, a Rectangle with its x, y, width, and height properties set to 0.
*/
  intersection(Rectangle a, Rectangle b) {
    if (intersects(a, b)) {
      double x = max(a.x, b.x);
      double y = max(a.y, b.y);
      double width = min(a.right, b.right) - x;
      double height = min(a.bottom, b.bottom) - y;

      return Rectangle(x: x, y: y, width: width, height: height);
    }

    return null;
  }

/**
* Calculates the Axis Aligned Bounding Box (or aabb) from an array of points.
*
* @method Phaser.Rectangle#aabb
* @param {Phaser.Point[]} points - The array of one or more points.
* @param {Phaser.Rectangle} [out] - Optional Rectangle to store the value in, if not supplied a new Rectangle object will be created.
* @return {Phaser.Rectangle} The new Rectangle object.
* @static
*/
  aabb(points) {
    double xMax = double.negativeInfinity;
    double xMin = double.infinity;
    double yMax = double.negativeInfinity;
    double yMin = double.infinity;

    points.forEach((point) {
      if (point.x > xMax) {
        xMax = point.x;
      }
      if (point.x < xMin) {
        xMin = point.x;
      }

      if (point.y > yMax) {
        yMax = point.y;
      }
      if (point.y < yMin) {
        yMin = point.y;
      }
    });

    Rectangle out = Rectangle(x: xMin, y: yMin, width: xMax - xMin, height: yMax - yMin);

    return out;
  }

/**
* Determines whether the object specified intersects (overlaps) with the given values.
* @method Phaser.Rectangle.intersectsRaw
* @param {number} left - The x coordinate of the left of the area.
* @param {number} right - The right coordinate of the area.
* @param {number} top - The y coordinate of the area.
* @param {number} bottom - The bottom coordinate of the area.
* @param {number} tolerance - A tolerance value to allow for an intersection test with padding, default to 0
* @return {boolean} A value of true if the specified object intersects with the Rectangle; otherwise false.
*/
  intersectsRaw(Rectangle a, double left, double right, double top, double bottom, double tolerance) {
    return !(left > a.right + tolerance || right < a.left - tolerance || top > a.bottom + tolerance || bottom < a.top - tolerance);
  }

/**
* Determines whether the two Rectangles intersect with each other.
* This method checks the x, y, width, and height properties of the Rectangles.
* @method Phaser.Rectangle.intersects
* @param {Phaser.Rectangle} a - The first Rectangle object.
* @param {Phaser.Rectangle} b - The second Rectangle object.
* @return {boolean} A value of true if the specified object intersects with this Rectangle object; otherwise false.
*/
  bool intersects(Rectangle a, Rectangle b) {
    if (a.width <= 0 || a.height <= 0 || b.width <= 0 || b.height <= 0) {
      return false;
    }

    return !(a.right < b.x || a.bottom < b.y || a.x > b.right || a.y > b.bottom);
  }

/**
* Determines whether the specified coordinates are contained within the region defined by the given raw values.
* @method Phaser.Rectangle.containsRaw
* @param {number} rx - The x coordinate of the top left of the area.
* @param {number} ry - The y coordinate of the top left of the area.
* @param {number} rw - The width of the area.
* @param {number} rh - The height of the area.
* @param {number} x - The x coordinate of the point to test.
* @param {number} y - The y coordinate of the point to test.
* @return {boolean} A value of true if the Rectangle object contains the specified point; otherwise false.
*/
  bool containsRaw(double rx, double ry, double rw, double rh, double x, double y) {
    return (x >= rx && x < (rx + rw) && y >= ry && y < (ry + rh));
  }

/**
* Determines whether the specified coordinates are contained within the region defined by this Rectangle object.
* @method Phaser.Rectangle.contains
* @param {Phaser.Rectangle} a - The Rectangle object.
* @param {number} x - The x coordinate of the point to test.
* @param {number} y - The y coordinate of the point to test.
* @return {boolean} A value of true if the Rectangle object contains the specified point; otherwise false.
*/
  containsRect(Rectangle a, double x, double y) {
    if (a.width <= 0 || a.height <= 0) {
      return false;
    }

    return (x >= a.x && x < a.right && y >= a.y && y < a.bottom);
  }

  containsFullRect(Rectangle a, Rectangle b) {
    //  If the given rect has a larger volume than this one then it can never contain it
    if (a.volume > b.volume) {
      return false;
    }

    return (a.x >= b.x && a.y >= b.y && a.right < b.right && a.bottom < b.bottom);
  }

/**
* The size of the Rectangle object, expressed as a Point object with the values of the width and height properties.
* @method Phaser.Rectangle.size
* @param {Phaser.Rectangle} a - The Rectangle object.
* @param {Phaser.Point} [output] - Optional Point object. If given the values will be set into the object, otherwise a brand new Point object will be created and returned.
* @return {Phaser.Point} The size of the Rectangle object
*/
  size(Rectangle a) {
    Point output = Point(a.width, a.height);

    return output;
  }

  extendLine(double distance, Point a, Point b) {
    // Find Slope of the line
    double lenAB = sqrt(pow(a.x - b.x, 2.0) + pow(a.y - b.y, 2.0));
    Point<double> result = Point(b.x + (b.x - a.x) / lenAB * distance, b.y + (b.y - a.y) / lenAB * distance);

    return result;
  }

  /**
   * Sort sprites by zIndex
   */
  int sortByDepth(dynamic childA, dynamic childB) {
    return childA.zIndex - childB.zIndex;
  }
}
