import 'dart:math';
import './utils.dart';

/**
 * @classdesc
 * A Circle object.
 *
 * This is a geometry object, containing numerical values and related methods to inspect and modify them.
 * It is not a Game Object, in that you cannot add it to the display list, and it has no texture.
 * To render a Circle you should look at the capabilities of the Graphics class.
 *
 * @class Circle
 * @memberof Phaser.Geom
 * @constructor
 * @since 3.0.0
 *
 * @param {number} [x=0] - The x position of the center of the circle.
 * @param {number} [y=0] - The y position of the center of the circle.
 * @param {number} [radius=0] - The radius of the circle.
 */
class Circle {
  double x = 0;
  double y = 0;
  double radius = 0;
  String type = "";
  double diameter = 0.0;
  Circle({
    required double x,
    required double y,
    required double radius,
  }) {
    /**
         * The geometry constant type of this object: `GEOM_CONST.CIRCLE`.
         * Used for fast type comparisons.
         *
         * @name Phaser.Geom.Circle#type
         * @type {number}
         * @readonly
         * @since 3.19.0
         */
    this.type = "CIRCLE";

    /**
         * The x position of the center of the circle.
         *
         * @name Phaser.Geom.Circle#x
         * @type {number}
         * @default 0
         * @since 3.0.0
         */
    this.x = x;

    /**
         * The y position of the center of the circle.
         *
         * @name Phaser.Geom.Circle#y
         * @type {number}
         * @default 0
         * @since 3.0.0
         */
    this.y = y;

    /**
         * The internal radius of the circle.
         *
         * @name Phaser.Geom.Circle#_radius
         * @type {number}
         * @private
         * @since 3.0.0
         */
    this.radius = radius;

    /**
         * The internal diameter of the circle.
         *
         * @name Phaser.Geom.Circle#_diameter
         * @type {number}
         * @private
         * @since 3.0.0
         */
    this.diameter = radius * 2;
  }

  /**
     * Check to see if the Circle contains the given x / y coordinates.
     *
     * @method Phaser.Geom.Circle#contains
     * @since 3.0.0
     *
     * @param {number} x - The x coordinate to check within the circle.
     * @param {number} y - The y coordinate to check within the circle.
     *
     * @return {boolean} True if the coordinates are within the circle, otherwise false.
     */
  bool contains(x, y) {
    return Utils.shared.contains(this, x, y);
  }

  /**
     * Returns a Point object containing the coordinates of a point on the circumference of the Circle
     * based on the given angle normalized to the range 0 to 1. I.e. a value of 0.5 will give the point
     * at 180 degrees around the circle.
     *
     * @method Phaser.Geom.Circle#getPoint
     * @since 3.0.0
     *
     * @generic {Phaser.Geom.Point} O - [out,$return]
     *
     * @param {number} position - A value between 0 and 1, where 0 equals 0 degrees, 0.5 equals 180 degrees and 1 equals 360 around the circle.
     * @param {(Phaser.Geom.Point|object)} [out] - An object to store the return values in. If not given a Point object will be created.
     *
     * @return {(Phaser.Geom.Point|object)} A Point, or point-like object, containing the coordinates of the point around the circle.
     */
  Point getPoint(position, point) {
    return Utils.shared.getPoint(this, position, point);
  }

  /**
     * Returns an array of Point objects containing the coordinates of the points around the circumference of the Circle,
     * based on the given quantity or stepRate values.
     *
     * @method Phaser.Geom.Circle#getPoints
     * @since 3.0.0
     *
     * @generic {Phaser.Geom.Point[]} O - [output,$return]
     *
     * @param {number} quantity - The amount of points to return. If a falsey value the quantity will be derived from the `stepRate` instead.
     * @param {number} [stepRate] - Sets the quantity by getting the circumference of the circle and dividing it by the stepRate.
     * @param {(array|Phaser.Geom.Point[])} [output] - An array to insert the points in to. If not provided a new array will be created.
     *
     * @return {(array|Phaser.Geom.Point[])} An array of Point objects pertaining to the points around the circumference of the circle.
     */
  List<Point> getPoints(quantity, stepRate, output) {
    return Utils.shared.getPoints(this, quantity, stepRate, output);
  }

  /**
     * Returns a uniformly distributed random point from anywhere within the Circle.
     *
     * @method Phaser.Geom.Circle#getRandomPoint
     * @since 3.0.0
     *
     * @generic {Phaser.Geom.Point} O - [point,$return]
     *
     * @param {(Phaser.Geom.Point|object)} [point] - A Point or point-like object to set the random `x` and `y` values in.
     *
     * @return {(Phaser.Geom.Point|object)} A Point object with the random values set in the `x` and `y` properties.
     */
  Point getRandomPoint(point) {
    return Utils.shared.randomPoint(this, point);
  }

  /**
     * Sets the x, y and radius of this circle.
     *
     * @method Phaser.Geom.Circle#setTo
     * @since 3.0.0
     *
     * @param {number} [x=0] - The x position of the center of the circle.
     * @param {number} [y=0] - The y position of the center of the circle.
     * @param {number} [radius=0] - The radius of the circle.
     *
     * @return {this} This Circle object.
     */
  Circle setTo(x, y, radius) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.diameter = radius * 2;

    return this;
  }

  /**
     * Sets this Circle to be empty with a radius of zero.
     * Does not change its position.
     *
     * @method Phaser.Geom.Circle#setEmpty
     * @since 3.0.0
     *
     * @return {this} This Circle object.
     */
  Circle setEmpty() {
    this.radius = 0;
    this.diameter = 0;

    return this;
  }

  /**
     * Sets the position of this Circle.
     *
     * @method Phaser.Geom.Circle#setPosition
     * @since 3.0.0
     *
     * @param {number} [x=0] - The x position of the center of the circle.
     * @param {number} [y=0] - The y position of the center of the circle.
     *
     * @return {this} This Circle object.
     */
  Circle setPosition(double x, double? y) {
    if (y == null) {
      y = x;
    }

    this.x = x;
    this.y = y;

    return this;
  }

  /**
     * Checks to see if the Circle is empty: has a radius of zero.
     *
     * @method Phaser.Geom.Circle#isEmpty
     * @since 3.0.0
     *
     * @return {boolean} True if the Circle is empty, otherwise false.
     */
  bool isEmpty() {
    return (this.radius <= 0);
  }

  /**
     * The radius of the Circle.
     *
     * @name Phaser.Geom.Circle#radius
     * @type {number}
     * @since 3.0.0
     */
  double get circleRadius {
    return this.radius;
  }

  set circleRadius(double radius) {
    this.radius = radius;
    this.diameter = radius * 2;
  }

  /**
     * The diameter of the Circle.
     *
     * @name Phaser.Geom.Circle#diameter
     * @type {number}
     * @since 3.0.0
     */
  double get circleDiameter {
    return this.diameter;
  }

  set circleDiameter(double value) {
    this.diameter = value;
    this.radius = value * 0.5;
  }

  /**
     * The left position of the Circle.
     *
     * @name Phaser.Geom.Circle#left
     * @type {number}
     * @since 3.0.0
     */
  double get left {
    return this.x - this.radius;
  }

  set left(double value) {
    this.x = value + this.radius;
  }

  /**
     * The right position of the Circle.
     *
     * @name Phaser.Geom.Circle#right
     * @type {number}
     * @since 3.0.0
     */
  double get right {
    return this.x + this.radius;
  }

  set right(double value) {
    this.x = value - this.radius;
  }

  /**
     * The top position of the Circle.
     *
     * @name Phaser.Geom.Circle#top
     * @type {number}
     * @since 3.0.0
     */
  double get top {
    return this.y - this.radius;
  }

  set top(double value) {
    this.y = value + this.radius;
  }

  /**
     * The bottom position of the Circle.
     *
     * @name Phaser.Geom.Circle#bottom
     * @type {number}
     * @since 3.0.0
     */

  double get bottom {
    return this.y + this.radius;
  }

  set bottom(double value) {
    this.y = value - this.radius;
  }
}
