/**
 * @author       Richard Davey <rich@photonstorm.com>
 * @copyright    2016 Photon Storm Ltd.
 * @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
 */

import 'dart:math';

import 'package:flutter_shaders/game_classes/EntitySystem/LinePoint.dart';
import 'package:flutter_shaders/helpers/Rectangle.dart';
import 'package:flutter_shaders/helpers/utils.dart';

/**
 * Creates a new Line object with a start and an end point.
 *
 * @class Phaser.Line
 * @constructor
 * @param {number} [x1=0] - The x coordinate of the start of the line.
 * @param {number} [y1=0] - The y coordinate of the start of the line.
 * @param {number} [x2=0] - The x coordinate of the end of the line.
 * @param {number} [y2=0] - The y coordinate of the end of the line.
 */
class Line {
  double x1 = 0;
  double y1 = 0;
  double x2 = 0;
  double y2 = 0;
  /**
     * @property {Phaser.Point} start - The start point of the line.
     */
  LinePoint start = LinePoint(0, 0);

  /**
     * @property {Phaser.Point} end - The end point of the line.
     */
  LinePoint end = LinePoint(0, 0);

  /**
     * @property {number} type - The const type of this object.
     * @readonly
     */
  String type = "LINE";

  Line({x1, y1, x2, y2}) {
    this.x1 = x1 ?? 0;
    this.y1 = y1 ?? 0;
    this.x2 = x2 ?? 0;
    this.y2 = y2 ?? 0;
  }

  /**
     * Sets the components of the Line to the specified values.
     *
     * @method Phaser.Line#setTo
     * @param {number} [x1=0] - The x coordinate of the start of the line.
     * @param {number} [y1=0] - The y coordinate of the start of the line.
     * @param {number} [x2=0] - The x coordinate of the end of the line.
     * @param {number} [y2=0] - The y coordinate of the end of the line.
     * @return {Phaser.Line} This line object
     */
  void setTo(double x1, double y1, double x2, double y2) {
    this.start = LinePoint(x1, y1);
    this.end = LinePoint(x2, y2);
  }

  /**
     * Sets the line to match the x/y coordinates of the two given points.
     *
     * @param {any} start - A {@link Phaser.Point} or point-like object.
     * @param {any} end - A {@link Phaser.Point} or point-like object.
     * @return {Phaser.Line} - This line object.
     */
  fromPoints(LinePoint start, LinePoint end) {
    this.setTo(start.x, start.y, end.x, end.y);
  }

  /**
     * Sets the line to match the x/y coordinates of the two given sprites.
     * Can optionally be calculated from their center coordinates.
     *
     * @method Phaser.Line#fromSprite
     * @param {Phaser.Sprite} startSprite - The coordinates of this Sprite will be set to the Line.start point.
     * @param {Phaser.Sprite} endSprite - The coordinates of this Sprite will be set to the Line.start point.
     * @param {boolean} [useCenter=false] - If true it will use startSprite.centerX, if false startSprite.x.
     * @return {Phaser.Line} This line object
     */
  // fromSprite: function (startSprite, endSprite, useCenter)
  // {
  //     if (useCenter === undefined) { useCenter = false; }

  //     if (useCenter)
  //     {
  //         return this.setTo(startSprite.centerX, startSprite.centerY, endSprite.centerX, endSprite.centerY);
  //     }

  //     return this.fromPoints(startSprite, endSprite);
  // },

  /**
     * Sets this line to start at the given `x` and `y` coordinates and for the segment to extend at `angle` for the given `length`.
     *
     * @method Phaser.Line#fromAngle
     * @param {number} x - The x coordinate of the start of the line.
     * @param {number} y - The y coordinate of the start of the line.
     * @param {number} angle - The angle of the line in radians.
     * @param {number} length - The length of the line in pixels.
     * @return {Phaser.Line} This line object
     */
  fromAngle(double x, double y, int angle, int length) {
    this.start = LinePoint(x, y);
    this.end = LinePoint(x + (cos(angle) * length), y + (sin(angle) * length));
  }

  /**
     * Rotates the line by the amount specified in `angle`.
     *
     * Rotation takes place from the center of the line.
     * If you wish to rotate around a different point see Line.rotateAround.
     *
     * If you wish to rotate the ends of the Line then see Line.start.rotate or Line.end.rotate.
     *
     * @method Phaser.Line#rotate
     * @param {number} angle - The angle in radians (unless asDegrees is true) to rotate the line by.
     * @param {boolean} [asDegrees=false] - Is the given angle in radians (false) or degrees (true)?
     * @return {Phaser.Line} This line object
     */
  rotate(double angle, bool asDegrees) {
    var cx = (this.start.x + this.end.x) / 2;
    var cy = (this.start.y + this.end.y) / 2;

    this.start.rotate(this.start, cx, cy, angle, asDegrees);
    this.end.rotate(this.end, cx, cy, angle, asDegrees);
  }

  /**
     * Rotates the line by the amount specified in `angle`.
     *
     * Rotation takes place around the coordinates given.
     *
     * @method Phaser.Line#rotateAround
     * @param {number} x - The x coordinate to offset the rotation from.
     * @param {number} y - The y coordinate to offset the rotation from.
     * @param {number} angle - The angle in radians (unless asDegrees is true) to rotate the line by.
     * @param {boolean} [asDegrees=false] - Is the given angle in radians (false) or degrees (true)?
     * @return {Phaser.Line} This line object
     */
  rotateAround(double x, double y, double angle, bool asDegrees) {
    this.start.rotate(this.start, x, y, angle, asDegrees);
    this.end.rotate(this.end, x, y, angle, asDegrees);
  }

  /**
     * Checks for intersection between this line and another Line.
     * If asSegment is true it will check for segment intersection. If asSegment is false it will check for line intersection.
     * Returns the intersection segment of AB and EF as a Point, or null if there is no intersection.
     *
     * @method Phaser.Line#intersects
     * @param {Phaser.Line} line - The line to check against this one.
     * @param {boolean} [asSegment=true] - If true it will check for segment intersection, otherwise full line intersection.
     * @param {Phaser.Point} [result] - A Point object to store the result in, if not given a new one will be created.
     * @return {Phaser.Point} The intersection segment of the two lines as a Point, or null if there is no intersection.
     */
  intersects(Line line, asSegment) {
    return intersectsPointsInner(this.start, this.end, line.start, line.end, asSegment);
  }

  /**
     * Returns the reflected angle between two lines.
     * This is the outgoing angle based on the angle of this line and the normalAngle of the given line.
     *
     * @method Phaser.Line#reflect
     * @param {Phaser.Line} line - The line to reflect off this line.
     * @return {number} The reflected angle in radians.
     */
  reflect(Line line) {
    return reflectAngle(this, line);
  }

  /**
     * Returns a Point object where the x and y values correspond to the center (or midpoint) of the Line segment.
     *
     * @method Phaser.Line#midPoint
     * @param {Phaser.Point} [out] - A Phaser.Point object into which the result will be populated. If not given a new Point object is created.
     * @return {Phaser.Point} A Phaser.Point object with the x and y values set to the center of the line segment.
     */
  midPoint() {
    LinePoint out = LinePoint(0, 0);

    out = LinePoint((this.start.x + this.end.x) / 2, (this.start.y + this.end.y) / 2);

    return out;
  }

  /**
     * Centers this Line on the given coordinates.
     *
     * The line is centered by positioning the start and end points so that the lines midpoint matches
     * the coordinates given.
     *
     * @method Phaser.Line#centerOn
     * @param {number} x - The x position to center the line on.
     * @param {number} y - The y position to center the line on.
     * @return {Phaser.Line} This line object
     */
  centerOn(double x, double y) {
    var cx = (this.start.x + this.end.x) / 2;
    var cy = (this.start.y + this.end.y) / 2;

    var tx = x - cx;
    var ty = y - cy;

    this.start = LinePoint(this.start.x + tx, this.start.y + ty);
    this.end = LinePoint(this.end.x + tx, this.end.y + ty);
  }

  /**
     * Tests if the given coordinates fall on this line. See {@link #pointOnSegment} to test against just the line segment.
     *
     * @method Phaser.Line#pointOnLine
     * @param {number} x - The line to check against this one.
     * @param {number} y - The line to check against this one.
     * @param {number} [epsilon=0] - Range for a fuzzy comparison, e.g., 0.0001.
     * @return {boolean} True if the point is on the line, false if not.
     */
  pointOnLine(int x, int y, double? epsilon) {
    return Utils.shared.fuzzyEqual((x - this.start.x) * (this.end.y - this.start.y), (this.end.x - this.start.x) * (y - this.start.y), epsilon ?? 0);
  }

  /**
     * Tests if the given coordinates fall on this line and within the segment. See {@link #pointOnLine} to test against just the line.
     *
     * @method Phaser.Line#pointOnSegment
     * @param {number} x - The line to check against this one.
     * @param {number} y - The line to check against this one.
     * @param {number} [epsilon=0] - Range for a fuzzy comparison, e.g., 0.0001.
     * @return {boolean} True if the point is on the line and segment, false if not.
     */
  pointOnSegment(double x, double y, double epsilon) {
    var xMin = min(this.start.x, this.end.x);
    var xMax = max(this.start.x, this.end.x);
    var yMin = min(this.start.y, this.end.y);
    var yMax = max(this.start.y, this.end.y);

    return (this.pointOnLine(x.toInt(), y.toInt(), epsilon) && (x >= xMin && x <= xMax) && (y >= yMin && y <= yMax));
  }

  /**
     * Picks a random point from anywhere on the Line segment and returns it.
     *
     * @method Phaser.Line#random
     * @param {Phaser.Point|object} [out] - A Phaser.Point, or any object with public x/y properties, that the values will be set in.
     *     If no object is provided a new Phaser.Point object will be created. In high performance areas avoid this by re-using an object.
     * @return {Phaser.Point} An object containing the random point in its `x` and `y` properties.
     */
  random(out) {
    LinePoint out = LinePoint(0, 0);

    var _rand = new Random();
    var t = _rand.nextDouble();

    out = LinePoint(this.start.x + t * (this.end.x - this.start.x), this.start.y + t * (this.end.y - this.start.y));

    return out;
  }

  /**
     * Using Bresenham's line algorithm this will return an array of all coordinates on this line.
     * The start and end points are rounded before this runs as the algorithm works on integers.
     *
     * @method Phaser.Line#coordinatesOnLine
     * @param {number} [stepRate=1] - How many steps will we return? 1 = every coordinate on the line, 2 = every other coordinate, etc.
     * @param {array} [results] - The array to store the results in. If not provided a new one will be generated.
     * @return {array} An array of coordinates.
     */
  coordinatesOnLine(stepRate, results) {
    var _stepRate = stepRate ?? 1;
    var _results = results ?? [];

    var x1 = (this.start.x).round();
    var y1 = (this.start.y).round();
    var x2 = (this.end.x).round();
    var y2 = (this.end.y).round();

    var dx = (x2 - x1).abs();
    var dy = (y2 - y1).abs();
    var sx = (x1 < x2) ? 1 : -1;
    var sy = (y1 < y2) ? 1 : -1;
    var err = dx - dy;

    results.push([x1, y1]);

    var i = 1;

    while (!((x1 == x2) && (y1 == y2))) {
      var e2 = err << 1;

      if (e2 > -dy) {
        err -= dy;
        x1 += sx;
      }

      if (e2 < dx) {
        err += dx;
        y1 += sy;
      }

      if (i % stepRate == 0) {
        results.push([x1, y1]);
      }

      i++;
    }

    return results;
  }

  /**
     * Returns a new Line object with the same values for the start and end properties as this Line object.
     * @method Phaser.Line#clone
     * @param {Phaser.Line} [output] - Optional Line object. If given the values will be set into the object, otherwise a brand new Line object will be created and returned.
     * @return {Phaser.Line} The cloned Line object.
     */
  clone() {
    Line output = Line(x1: this.start.x, y1: this.start.y, x2: this.end.x, y2: this.end.y);

    return output;
  }

/**
 * @name Phaser.Line#length
 * @property {number} length - Gets the length of the line segment.
 * @readonly
 */

  double get length {
    double result = sqrt((this.end.x - this.start.x) * (this.end.x - this.start.x) + (this.end.y - this.start.y) * (this.end.y - this.start.y));
    return result;
  }

/**
 * @name Phaser.Line#angle
 * @property {number} angle - Gets the angle of the line in radians.
 * @readonly
 */
  double get angle {
    return atan2(this.end.y - this.start.y, this.end.x - this.start.x);
  }

/**
 * @name Phaser.Line#slope
 * @property {number} slope - Gets the slope of the line (y/x).
 * @readonly
 */

  double get slope {
    return (this.end.y - this.start.y) / (this.end.x - this.start.x);
  }

  double get perpSlope {
    return -((this.end.x - this.start.x) / (this.end.y - this.start.y));
  }

/**
 * @name Phaser.Line#x
 * @property {number} x - Gets the x coordinate of the top left of the bounds around this line.
 * @readonly
 */

  double get x {
    return min(this.start.x, this.end.x);
  }

/**
 * @name Phaser.Line#y
 * @property {number} y - Gets the y coordinate of the top left of the bounds around this line.
 * @readonly
 */

  double get y {
    return min(this.start.y, this.end.y);
  }

/**
 * @name Phaser.Line#left
 * @property {number} left - Gets the left-most point of this line.
 * @readonly
 */

  double get left {
    return min(this.start.x, this.end.x);
  }

/**
 * @name Phaser.Line#right
 * @property {number} right - Gets the right-most point of this line.
 * @readonly
 */

  double get right {
    return max(this.start.x, this.end.x);
  }

/**
 * @name Phaser.Line#top
 * @property {number} top - Gets the top-most point of this line.
 * @readonly
 */

  double get top {
    return min(this.start.y, this.end.y);
  }

/**
 * @name Phaser.Line#bottom
 * @property {number} bottom - Gets the bottom-most point of this line.
 * @readonly
 */

  double get bottom {
    return max(this.start.y, this.end.y);
  }

/**
 * @name Phaser.Line#width
 * @property {number} width - Gets the width of this bounds of this line.
 * @readonly
 */
  double get width {
    return (this.start.x - this.end.x).abs().toDouble();
  }

/**
 * @name Phaser.Line#height
 * @property {number} height - Gets the height of this bounds of this line.
 * @readonly
 */
  double get height {
    return (this.start.y - this.end.y).abs().toDouble();
  }

/**
 * @name Phaser.Line#normalX
 * @property {number} normalX - Gets the x component of the left-hand normal of this line.
 * @readonly
 */

  double get normalX {
    return cos(this.angle - 1.5707963267948966);
  }

/**
 * @name Phaser.Line#normalY
 * @property {number} normalY - Gets the y component of the left-hand normal of this line.
 * @readonly
 */
  double get normalY {
    return sin(this.angle - 1.5707963267948966);
  }

/**
 * @name Phaser.Line#normalAngle
 * @property {number} normalAngle - Gets the angle in radians of the normal of this line (line.angle - 90 degrees.)
 * @readonly
 */

  double get normalAngle {
    return Utils.shared.wrap(this.angle - 1.5707963267948966, -pi, pi);
  }

/**
 * Checks for intersection between two lines as defined by the given start and end points.
 * If asSegment is true it will check for line segment intersection. If asSegment is false it will check for line intersection.
 * Returns the intersection segment of AB and EF as a Point, or null if there is no intersection.
 * Adapted from code by Keith Hair
 *
 * @method Phaser.Line.intersectsPoints
 * @param {Phaser.Point} a - The start of the first Line to be checked.
 * @param {Phaser.Point} b - The end of the first line to be checked.
 * @param {Phaser.Point} e - The start of the second Line to be checked.
 * @param {Phaser.Point} f - The end of the second line to be checked.
 * @param {boolean} [asSegment=true] - If true it will check for segment intersection, otherwise full line intersection.
 * @param {Phaser.Point|object} [result] - A Point object to store the result in, if not given a new one will be created.
 * @return {Phaser.Point} The intersection segment of the two lines as a Point, or null if there is no intersection.
 */
  intersectsPointsInner(a, b, e, f, bool? asSegment) {
    if (asSegment == null) {
      asSegment = true;
    }
    var result = Point(0, 0);

    var a1 = b.y - a.y;
    var a2 = f.y - e.y;
    var b1 = a.x - b.x;
    var b2 = e.x - f.x;
    var c1 = (b.x * a.y) - (a.x * b.y);
    var c2 = (f.x * e.y) - (e.x * f.y);
    var denom = (a1 * b2) - (a2 * b1);

    if (denom == 0) {
      return null;
    }

    result = Point(((b1 * c2) - (b2 * c1)) / denom, ((a2 * c1) - (a1 * c2)) / denom);

    if (asSegment) {
      var uc = ((f.y - e.y) * (b.x - a.x) - (f.x - e.x) * (b.y - a.y));
      var ua = (((f.x - e.x) * (a.y - e.y)) - (f.y - e.y) * (a.x - e.x)) / uc;
      var ub = (((b.x - a.x) * (a.y - e.y)) - ((b.y - a.y) * (a.x - e.x))) / uc;

      if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) {
        return result;
      } else {
        return null;
      }
    }

    return result;
  }

/**
 * Checks for intersection between two lines.
 * If asSegment is true it will check for segment intersection.
 * If asSegment is false it will check for line intersection.
 * Returns the intersection segment of AB and EF as a Point, or null if there is no intersection.
 * Adapted from code by Keith Hair
 *
 * @method Phaser.Line.intersects
 * @param {Phaser.Line} a - The first Line to be checked.
 * @param {Phaser.Line} b - The second Line to be checked.
 * @param {boolean} [asSegment=true] - If true it will check for segment intersection, otherwise full line intersection.
 * @param {Phaser.Point} [result] - A Point object to store the result in, if not given a new one will be created.
 * @return {Phaser.Point} The intersection segment of the two lines as a Point, or null if there is no intersection.
 */
  intersectsPoint(a, b, asSegment) {
    return intersectsPointsInner(a.start, a.end, b.start, b.end, asSegment);
  }

/**
 * Checks for intersection between the Line and a Rectangle shape, or a rectangle-like
 * object, with public `x`, `y`, `right` and `bottom` properties, such as a Sprite or Body.
 *
 * An intersection is considered valid if:
 *
 * The line starts within or ends within the rectangle; or
 * The line segment intersects one of the 4 rectangle edges; and
 * The line has a non-zero length; and
 * The rectangle is not empty.
 *
 * For the purposes of this function rectangles are considered 'solid'.
 *
 * @method Phaser.Line.intersectsRectangle
 * @param {Phaser.Line} line - The line to check for intersection with.
 * @param {Phaser.Rectangle|object} rect - The rectangle, or rectangle-like object, to check for intersection with.
 * @return {boolean} True if the line intersects with the rectangle edges, or starts or ends within the rectangle.
 */
  bool intersectsRectangle(Line line, Rectangle rect) {
    //  Quick bail out
    if (line.length == 0 || rect.empty) {
      return false;
    }

    var x1 = line.start.x;
    var y1 = line.start.y;

    var x2 = line.end.x;
    var y2 = line.end.y;

    var bx1 = rect.x;
    var by1 = rect.y;
    var bx2 = rect.right;
    var by2 = rect.bottom;

    double t = 0;

    /*
     *  If the start or end of the line is inside the rect then we assume
     *  collision, as rects are solid for our use-case.
     */

    if ((x1 >= bx1 && x1 <= bx2 && y1 >= by1 && y1 <= by2) || (x2 >= bx1 && x2 <= bx2 && y2 >= by1 && y2 <= by2)) {
      return true;
    }

    if (x1 < bx1 && x2 >= bx1) {
      //  Left edge
      t = y1 + (y2 - y1) * (bx1 - x1) / (x2 - x1);

      if (t > by1 && t <= by2) {
        return true;
      }
    } else if (x1 > bx2 && x2 <= bx2) {
      //  Right edge
      t = y1 + (y2 - y1) * (bx2 - x1) / (x2 - x1);

      if (t >= by1 && t <= by2) {
        return true;
      }
    }

    if (y1 < by1 && y2 >= by1) {
      //  Top edge
      t = x1 + (x2 - x1) * (by1 - y1) / (y2 - y1);

      if (t >= bx1 && t <= bx2) {
        return true;
      }
    } else if (y1 > by2 && y2 <= by2) {
      //  Bottom edge
      t = x1 + (x2 - x1) * (by2 - y1) / (y2 - y1);

      if (t >= bx1 && t <= bx2) {
        return true;
      }
    }

    return false;
  }

/**
 * Finds the closest intersection between the Line and a Rectangle shape, or a rectangle-like
 * object, such as a Sprite or Body.
 *
 * @method Phaser.Line.intersectionWithRectangle
 * @param {Phaser.Line} line - The line to check for intersection with.
 * @param {Phaser.Rectangle} rect - The rectangle, or rectangle-like object, to check for intersection with.
 * @param {Phaser.Point} [result] - A Point object to store the result in.
 * @return {?Phaser.Point} - The intersection closest to the Line's start, or null if there is no intersection.
 */
// intersectionWithRectangle(line, rect){
//     var self = intersectionWithRectangle;

//     Point result = Point(0,0);

//     if (!self.edges){
//         self.edges = [ new Phaser.Line(), new Phaser.Line(), new Phaser.Line(), new Phaser.Line() ];
//     }

//     if (!self.edgeIntersection)
//     {
//         self.edgeIntersection = new Phaser.Point();
//     }

//     var edges = self.edges;
//     var edgeIntersection = self.edgeIntersection.set(0);

//     var bx1 = rect.x;
//     var by1 = rect.y;
//     var bx2 = rect.right;
//     var by2 = rect.bottom;
//     var closestDistance = Infinity;

//     edges[0].setTo(bx1, by1, bx2, by1);
//     edges[1].setTo(bx1, by2, bx2, by2);
//     edges[2].setTo(bx1, by1, bx1, by2);
//     edges[3].setTo(bx2, by1, bx2, by2);

//     for (var edge, i = 0; (edge = edges[i]); i++)
//     {
//         if (line.intersects(edge, true, edgeIntersection))
//         {
//             var distance = line.start.distance(edgeIntersection);

//             if (distance < closestDistance)
//             {
//                 closestDistance = distance;
//                 result.copyFrom(edgeIntersection);
//             }
//         }
//     }

//     if (distance != null)
//     {
//         return result;
//     }

//     return null;
// }

/**
 * Returns the reflected angle between two lines.
 * This is the outgoing angle based on the angle of Line 1 and the normalAngle of Line 2.
 *
 * @method Phaser.Line.reflect
 * @param {Phaser.Line} a - The base line.
 * @param {Phaser.Line} b - The line to be reflected from the base line.
 * @return {number} The reflected angle in radians.
 */
  reflectAngle(a, b) {
    return 2 * b.normalAngle - 3.141592653589793 - a.angle;
  }
}
