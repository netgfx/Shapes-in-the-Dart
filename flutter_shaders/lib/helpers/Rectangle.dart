/**
* @author       Richard Davey <rich@photonstorm.com>
* @copyright    2016 Photon Storm Ltd.
* @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
*/

import 'dart:math';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_shaders/helpers/utils.dart';

/**
* Creates a new Rectangle object with the top-left corner specified by the x and y parameters and with the specified width and height parameters.
* If you call this function without parameters, a Rectangle with x, y, width, and height properties set to 0 is created.
*
* @class Phaser.Rectangle
* @constructor
* @param {number} x - The x coordinate of the top-left corner of the Rectangle.
* @param {number} y - The y coordinate of the top-left corner of the Rectangle.
* @param {number} width - The width of the Rectangle. Should always be either zero or a positive value.
* @param {number} height - The height of the Rectangle. Should always be either zero or a positive value.
*/
class Rectangle {
  double x = 0;
  double y = 0;
  double width = 0;
  double height = 0;
  String type = "";

  Rectangle({
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    /**
    * @property {number} x - The x coordinate of the top-left corner of the Rectangle.
    */
    this.x = x;

    /**
    * @property {number} y - The y coordinate of the top-left corner of the Rectangle.
    */
    this.y = y;

    /**
    * @property {number} width - The width of the Rectangle. This value should never be set to a negative.
    */
    this.width = width;

    /**
    * @property {number} height - The height of the Rectangle. This value should never be set to a negative.
    */
    this.height = height;

    /**
    * @property {number} type - The const type of this object.
    * @readonly
    */
    this.type = "RECTANGLE";
  }

  /**
    * Adjusts the location of the Rectangle object, as determined by its top-left corner, by the specified amounts.
    * @method Phaser.Rectangle#offset
    * @param {number} dx - Moves the x value of the Rectangle object by this amount.
    * @param {number} dy - Moves the y value of the Rectangle object by this amount.
    * @return {Phaser.Rectangle} This Rectangle object.
    */
  offset(double dx, double dy) {
    this.x += dx;
    this.y += dy;

    return this;
  }

  /**
    * Adjusts the location of the Rectangle object using a Point object as a parameter. This method is similar to the Rectangle.offset() method, except that it takes a Point object as a parameter.
    * @method Phaser.Rectangle#offsetPoint
    * @param {Phaser.Point} point - A Point object to use to offset this Rectangle object.
    * @return {Phaser.Rectangle} This Rectangle object.
    */
  offsetPoint(Point<double> point) {
    return this.offset(point.x, point.y);
  }

  /**
    * Sets the members of Rectangle to the specified values.
    * @method Phaser.Rectangle#setTo
    * @param {number} x - The x coordinate of the top-left corner of the Rectangle.
    * @param {number} y - The y coordinate of the top-left corner of the Rectangle.
    * @param {number} width - The width of the Rectangle. Should always be either zero or a positive value.
    * @param {number} height - The height of the Rectangle. Should always be either zero or a positive value.
    * @return {Phaser.Rectangle} This Rectangle object
    */
  setTo(double x, double y, double width, double height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;

    return this;
  }

  /**
    * Scales the width and height of this Rectangle by the given amounts.
    * 
    * @method Phaser.Rectangle#scale
    * @param {number} x - The amount to scale the width of the Rectangle by. A value of 0.5 would reduce by half, a value of 2 would double the width, etc.
    * @param {number} [y] - The amount to scale the height of the Rectangle by. A value of 0.5 would reduce by half, a value of 2 would double the height, etc.
    * @return {Phaser.Rectangle} This Rectangle object
    */
  scale(double x, double y) {
    this.width *= x;
    this.height *= y;

    return this;
  }

  /**
    * Centers this Rectangle so that the center coordinates match the given x and y values.
    *
    * @method Phaser.Rectangle#centerOn
    * @param {number} x - The x coordinate to place the center of the Rectangle at.
    * @param {number} y - The y coordinate to place the center of the Rectangle at.
    * @return {Phaser.Rectangle} This Rectangle object
    */
  centerOn(double x, double y) {
    this.centerX = x;
    this.centerY = y;

    return this;
  }

  /**
    * Runs Math.floor() on both the x and y values of this Rectangle.
    * @method Phaser.Rectangle#floor
    */
  floor() {
    this.x = (this.x).floor() as double;
    this.y = (this.y).floor() as double;
  }

  /**
    * Runs Math.floor() on the x, y, width and height values of this Rectangle.
    * @method Phaser.Rectangle#floorAll
    */
  floorAll() {
    this.x = (this.x).floor() as double;
    this.y = (this.y).floor() as double;
    this.width = (this.width).floor() as double;
    this.height = (this.height).floor() as double;
  }

  /**
    * Runs Math.ceil() on both the x and y values of this Rectangle.
    * @method Phaser.Rectangle#ceil
    */
  ceil() {
    this.x = (this.x).ceil() as double;
    this.y = (this.y).ceil() as double;
  }

  /**
    * Runs Math.ceil() on the x, y, width and height values of this Rectangle.
    * @method Phaser.Rectangle#ceilAll
    */
  ceilAll() {
    this.x = (this.x).ceil() as double;
    this.y = (this.y).ceil() as double;
    this.width = (this.width).ceil() as double;
    this.height = (this.height).ceil() as double;
  }

  /**
    * Copies the x, y, width and height properties from any given object to this Rectangle.
    * @method Phaser.Rectangle#copyFrom
    * @param {any} source - The object to copy from.
    * @return {Phaser.Rectangle} This Rectangle object.
    */
  copyFrom(source) {
    return this.setTo(source.x, source.y, source.width, source.height);
  }

  /**
    * Copies the x, y, width and height properties from this Rectangle to any given object.
    * @method Phaser.Rectangle#copyTo
    * @param {any} source - The object to copy to.
    * @return {object} This object.
    */
  copyTo(Map<String, dynamic> dest) {
    dest["x"] = this.x;
    dest["y"] = this.y;
    dest["width"] = this.width;
    dest["height"] = this.height;

    return dest;
  }

  /**
    * Increases the size of the Rectangle object by the specified amounts. The center point of the Rectangle object stays the same, and its size increases to the left and right by the dx value, and to the top and the bottom by the dy value.
    * @method Phaser.Rectangle#inflate
    * @param {number} dx - The amount to be added to the left side of the Rectangle.
    * @param {number} dy - The amount to be added to the bottom side of the Rectangle.
    * @return {Phaser.Rectangle} This Rectangle object.
    */
  inflate(double dx, double dy) {
    return Utils.shared.inflate(this, dx, dy);
  }

  /**
    * The size of the Rectangle object, expressed as a Point object with the values of the width and height properties.
    * @method Phaser.Rectangle#size
    * @param {Phaser.Point} [output] - Optional Point object. If given the values will be set into the object, otherwise a brand new Point object will be created and returned.
    * @return {Phaser.Point} The size of the Rectangle object.
    */
  size(Point output) {
    return Utils.shared.size(this);
  }

  /**
    * Resize the Rectangle by providing a new width and height.
    * The x and y positions remain unchanged.
    * 
    * @method Phaser.Rectangle#resize
    * @param {number} width - The width of the Rectangle. Should always be either zero or a positive value.
    * @param {number} height - The height of the Rectangle. Should always be either zero or a positive value.
    * @return {Phaser.Rectangle} This Rectangle object
    */
  resize(width, height) {
    this.width = width;
    this.height = height;

    return this;
  }

  /**
    * Determines whether the specified coordinates are contained within the region defined by this Rectangle object.
    * @method Phaser.Rectangle#contains
    * @param {number} x - The x coordinate of the point to test.
    * @param {number} y - The y coordinate of the point to test.
    * @return {boolean} A value of true if the Rectangle object contains the specified point; otherwise false.
    */
  bool contains(x, y) {
    return Utils.shared.containsRect(this, x, y);
  }

  /**
    * Determines whether the first Rectangle object is fully contained within the second Rectangle object.
    * A Rectangle object is said to contain another if the second Rectangle object falls entirely within the boundaries of the first.
    * @method Phaser.Rectangle#containsRect
    * @param {Phaser.Rectangle} b - The second Rectangle object.
    * @return {boolean} A value of true if the Rectangle object contains the specified point; otherwise false.
    */
  containsRect(Rectangle b) {
    return Utils.shared.containsFullRect(b, this);
  }

  /**
    * Determines whether the two Rectangles are equal.
    * This method compares the x, y, width and height properties of each Rectangle.
    * @method Phaser.Rectangle#equals
    * @param {Phaser.Rectangle} b - The second Rectangle object.
    * @return {boolean} A value of true if the two Rectangles have exactly the same values for the x, y, width and height properties; otherwise false.
    */
  equals(b) {
    return Utils.shared.equals(this, b);
  }

  /**
    * If the Rectangle object specified in the toIntersect parameter intersects with this Rectangle object, returns the area of intersection as a Rectangle object. If the Rectangles do not intersect, this method returns an empty Rectangle object with its properties set to 0.
    * @method Phaser.Rectangle#intersection
    * @param {Phaser.Rectangle} b - The second Rectangle object.
    * @param {Phaser.Rectangle} out - Optional Rectangle object. If given the intersection values will be set into this object, otherwise a brand new Rectangle object will be created and returned.
    * @return {Phaser.Rectangle} A Rectangle object that equals the area of intersection. If the Rectangles do not intersect, this method returns an empty Rectangle object; that is, a Rectangle with its x, y, width, and height properties set to 0.
    */
  intersection(Rectangle b) {
    return Utils.shared.intersection(this, b);
  }

  /**
    * Determines whether this Rectangle and another given Rectangle intersect with each other.
    * This method checks the x, y, width, and height properties of the two Rectangles.
    * 
    * @method Phaser.Rectangle#intersects
    * @param {Phaser.Rectangle} b - The second Rectangle object.
    * @return {boolean} A value of true if the specified object intersects with this Rectangle object; otherwise false.
    */
  intersects(Rectangle b) {
    return Utils.shared.intersects(this, b);
  }

  /**
    * Determines whether the coordinates given intersects (overlaps) with this Rectangle.
    *
    * @method Phaser.Rectangle#intersectsRaw
    * @param {number} left - The x coordinate of the left of the area.
    * @param {number} right - The right coordinate of the area.
    * @param {number} top - The y coordinate of the area.
    * @param {number} bottom - The bottom coordinate of the area.
    * @param {number} tolerance - A tolerance value to allow for an intersection test with padding, default to 0
    * @return {boolean} A value of true if the specified object intersects with the Rectangle; otherwise false.
    */
  intersectsRaw(double left, double right, double top, double bottom, double tolerance) {
    return Utils.shared.intersectsRaw(this, left, right, top, bottom, tolerance);
  }

  /**
    * Adds two Rectangles together to create a new Rectangle object, by filling in the horizontal and vertical space between the two Rectangles.
    * @method Phaser.Rectangle#union
    * @param {Phaser.Rectangle} b - The second Rectangle object.
    * @param {Phaser.Rectangle} [out] - Optional Rectangle object. If given the new values will be set into this object, otherwise a brand new Rectangle object will be created and returned.
    * @return {Phaser.Rectangle} A Rectangle object that is the union of the two Rectangles.
    */
  union(Rectangle b) {
    return Utils.shared.union(this, b);
  }

  /**
    * Returns a point based on the given position constant, which can be one of:
    * 
    * `Phaser.TOP_LEFT`, `Phaser.TOP_CENTER`, `Phaser.TOP_RIGHT`, `Phaser.LEFT_CENTER`,
    * `Phaser.CENTER`, `Phaser.RIGHT_CENTER`, `Phaser.BOTTOM_LEFT`, `Phaser.BOTTOM_CENTER` 
    * and `Phaser.BOTTOM_RIGHT`.
    *
    * This method returns the same values as calling Rectangle.bottomLeft, etc, but those
    * calls always create a new Point object, where-as this one allows you to use your own.
    * 
    * @method Phaser.Rectangle#getPoint
    * @param {integer} [position] - One of the Phaser position constants, such as `Phaser.TOP_RIGHT`.
    * @param {Phaser.Point} [out] - A Phaser.Point that the values will be set in.
    *     If no object is provided a new Phaser.Point object will be created. In high performance areas avoid this by re-using an existing object.
    * @return {Phaser.Point} An object containing the point in its `x` and `y` properties.
    */
  getPoint(String position) {
    Point out = Point(0, 0);

    if (position == "TOP_LEFT") {
      return out = Point(this.x, this.y);
    } else if (position == "TOP_CENTER") {
      return out = Point(this.centerX, this.y);
    } else if (position == "TOP_RIGHT") {
      return out = Point(this.right, this.y);
    } else if (position == "LEFT_CENTER") {
      return out = Point(this.x, this.centerY);
    } else if (position == "CENTER") {
      return out = Point(this.centerX, this.centerY);
    } else if (position == "RIGHT_CENTER") {
      return out = Point(this.right, this.centerY);
    } else if (position == "BOTTOM_LEFT") {
      return out = Point(this.x, this.bottom);
    } else if (position == "BOTTOM_CENTER") {
      return out = Point(this.centerX, this.bottom);
    } else if (position == "BOTTOM_RIGHT") {
      return out = Point(this.right, this.bottom);
    }
  }

  /**
    * Returns a string representation of this object.
    * @method Phaser.Rectangle#toString
    * @return {string} A string representation of the instance.
    */
  toString() {
    return "[{Rectangle (x=" +
        this.x.toString() +
        " y=" +
        this.y.toString() +
        " width=" +
        this.width.toString() +
        " height=" +
        this.height.toString() +
        " empty=" +
        this.empty.toString() +
        ")}]";
  }

  /**
* The sum of the y and height properties. Changing the bottom property of a Rectangle object has no effect on the x, y and width properties, but does change the height property.
* @name Phaser.Rectangle#bottom
* @property {number} bottom - The sum of the y and height properties.
*/
  double get bottom {
    return this.y + this.height;
  }

  set bottom(value) {
    if (value <= this.y) {
      this.height = 0;
    } else {
      this.height = value - this.y;
    }
  }

/**
* The location of the Rectangles bottom left corner as a Point object.
* @name Phaser.Rectangle#bottomLeft
* @property {Phaser.Point} bottomLeft - Gets or sets the location of the Rectangles bottom left corner as a Point object.
*/

  get bottomLeft {
    return Point<double>(this.x, this.bottom);
  }

  set bottomLeft(value) {
    this.x = value.x;
    this.bottom = value.y;
  }

/**
* The location of the Rectangles bottom right corner as a Point object.
* @name Phaser.Rectangle#bottomRight
* @property {Phaser.Point} bottomRight - Gets or sets the location of the Rectangles bottom right corner as a Point object.
*/

  get bottomRight {
    return Point<double>(this.right, this.bottom);
  }

  set bottomRight(value) {
    this.right = value.x;
    this.bottom = value.y;
  }

/**
* The x coordinate of the left of the Rectangle. Changing the left property of a Rectangle object has no effect on the y and height properties. However it does affect the width property, whereas changing the x value does not affect the width property.
* @name Phaser.Rectangle#left
* @property {number} left - The x coordinate of the left of the Rectangle.
*/

  double get left {
    return this.x;
  }

  set left(value) {
    if (value >= this.right) {
      this.width = 0;
    } else {
      this.width = this.right - value;
    }
    this.x = value;
  }

/**
* The sum of the x and width properties. Changing the right property of a Rectangle object has no effect on the x, y and height properties, however it does affect the width property.
* @name Phaser.Rectangle#right
* @property {number} right - The sum of the x and width properties.
*/

  double get right {
    return this.x + this.width;
  }

  set right(value) {
    if (value <= this.x) {
      this.width = 0;
    } else {
      this.width = value - this.x;
    }
  }

/**
* The location of the Rectangles top left corner as a Point object.
* @name Phaser.Rectangle#topLeft
* @property {Phaser.Point} topLeft - The location of the Rectangles top left corner as a Point object.
*/

  Point get topLeft {
    return Point(this.x.toDouble(), this.y.toDouble());
  }

  set topLeft(value) {
    this.x = value.x;
    this.y = value.y;
  }

/**
* The location of the Rectangles top right corner as a Point object.
* @name Phaser.Rectangle#topRight
* @property {Phaser.Point} topRight - The location of the Rectangles top left corner as a Point object.
*/

  Point get topRight {
    return Point(this.x + this.width, this.y);
  }

  set topRight(value) {
    this.right = value.x;
    this.y = value.y;
  }

/**
* The y coordinate of the top of the Rectangle. Changing the top property of a Rectangle object has no effect on the x and width properties.
* However it does affect the height property, whereas changing the y value does not affect the height property.
* @name Phaser.Rectangle#top
* @property {number} top - The y coordinate of the top of the Rectangle.
*/

  double get top {
    return this.y;
  }

  set top(value) {
    if (value >= this.bottom) {
      this.height = 0;
      this.y = value;
    } else {
      this.height = (this.bottom - value);
    }
  }

/**
* Determines whether or not this Rectangle object is empty. A Rectangle object is empty if its width or height is less than or equal to 0.
* If set to true then all of the Rectangle properties are set to 0.
* @name Phaser.Rectangle#empty
* @property {boolean} empty - Gets or sets the Rectangles empty state.
*/

  get empty {
    return (this.width == 0 && this.height == 0);
  }

  set empty(value) {
    if (value == true) {
      this.setTo(0, 0, 0, 0);
    }
  }

  /**
* The x coordinate of the center of the Rectangle.
* @name Phaser.Rectangle#centerX
* @property {number} centerX - The x coordinate of the center of the Rectangle.
*/

  get centerX {
    return this.x + this.width / 2;
  }

  set centerX(value) {
    this.x = value - this.width / 2;
  }

/**
* The y coordinate of the center of the Rectangle.
* @name Phaser.Rectangle#centerY
* @property {number} centerY - The y coordinate of the center of the Rectangle.
*/

  get centerY {
    return this.y + this.width / 2;
  }

  set centerY(value) {
    this.y = value - this.width / 2;
  }

  /**
* The volume of the Rectangle derived from width * height.
* @name Phaser.Rectangle#volume
* @property {number} volume - The volume of the Rectangle derived from width * height.
* @readonly
*/

  get volume {
    return this.width * this.height;
  }

  /**
* The perimeter size of the Rectangle. This is the sum of all 4 sides.
* @name Phaser.Rectangle#perimeter
* @property {number} perimeter - The perimeter size of the Rectangle. This is the sum of all 4 sides.
* @readonly
*/

  get perimeter {
    return (this.width * 2) + (this.height * 2);
  }

/**
* A random value between the left and right values (inclusive) of the Rectangle.
*
* @name Phaser.Rectangle#randomX
* @property {number} randomX - A random value between the left and right values (inclusive) of the Rectangle.
*/

  get randomX {
    return this.x + (Utils.shared.doubleInRange(0, 1) * this.width);
  }

/**
* A random value between the top and bottom values (inclusive) of the Rectangle.
*
* @name Phaser.Rectangle#randomY
* @property {number} randomY - A random value between the top and bottom values (inclusive) of the Rectangle.
*/

  get randomY {
    return this.y + (Utils.shared.doubleInRange(0, 1) * this.height);
  }
}
