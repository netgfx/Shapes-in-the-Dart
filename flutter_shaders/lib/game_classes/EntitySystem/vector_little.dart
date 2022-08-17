///////////////////////////////////////////////////////////////////////////////

import 'dart:math';

import 'package:flutter_shaders/helpers/utils.dart';

/** 
 * Create a 2d vector, can take another Vector2 to copy, 2 scalars, or 1 scalar
 * @param {Number} [x=0]
 * @param {Number} [y=0]
 * @return {Vector2}
 * @example
 * let a = vec2(0, 1); // vector with coordinates (0, 1)
 * let b = vec2(a);    // copy a into b
 * a = vec2(5);        // set a to (5, 5)
 * b = vec2();         // set b to (0, 0)
 * @memberof Utilities
 */
vec2({x = 0, y}) {
  x.x == null
      ? new Vector2(x: x, y: y == null ? x : y)
      : new Vector2(x: x.x, y: x.y);
}

/** 
 * 2D Vector object with vector math library
 * <br> - Functions do not change this so they can be chained together
 * @example
 * let a = new Vector2(2, 3); // vector with coordinates (2, 3)
 * let b = new Vector2;       // vector with coordinates (0, 0)
 * let c = vec2(4, 2);        // use the vec2 function to make a Vector2
 * let d = a.add(b).scale(5); // operators can be chained
 */
class Vector2 {
  double x = 0;
  double y = 0;
  /** Create a 2D vector with the x and y passed in, can also be created with vec2()
     *  @param {Number} [x=0] - X axis location
     *  @param {Number} [y=0] - Y axis location */
  Vector2({x = 0, y = 0}) {
    /** @property {Number} - X axis location */
    this.x = x ?? 0;
    /** @property {Number} - Y axis location */
    this.y = y ?? 0;
  }

  /** Returns a new vector that is a copy of this
     *  @return {Vector2} */
  copy() {
    return new Vector2(x: this.x, y: this.y);
  }

  /** Returns a copy of this vector plus the vector passed in
     *  @param {Vector2} vector
     *  @return {Vector2} */
  add(v) {
    return new Vector2(x: this.x + v.x, y: this.y + v.y);
  }

  /** Returns a copy of this vector minus the vector passed in
     *  @param {Vector2} vector
     *  @return {Vector2} */
  subtract(v) {
    return new Vector2(x: this.x - v.x, y: this.y - v.y);
  }

  /** Returns a copy of this vector times the vector passed in
     *  @param {Vector2} vector
     *  @return {Vector2} */
  multiply(v) {
    return new Vector2(x: this.x * v.x, y: this.y * v.y);
  }

  /** Returns a copy of this vector divided by the vector passed in
     *  @param {Vector2} vector
     *  @return {Vector2} */
  divide(v) {
    return new Vector2(x: this.x / v.x, y: this.y / v.y);
  }

  /** Returns a copy of this vector scaled by the vector passed in
     *  @param {Number} scale
     *  @return {Vector2} */
  scale(s) {
    return new Vector2(x: this.x * s, y: this.y * s);
  }

  /** Returns the length of this vector
     * @return {Number} */
  length() {
    return pow(this.lengthSquared(), .5);
  }

  /** Returns the length of this vector squared
     * @return {Number} */
  lengthSquared() {
    return pow(this.x, 2) + pow(this.y, 2);
  }

  /** Returns the distance from this vector to vector passed in
     * @param {Vector2} vector
     * @return {Number} */
  distance(v) {
    return pow(this.distanceSquared(v), .5);
  }

  /** Returns the distance squared from this vector to vector passed in
     * @param {Vector2} vector
     * @return {Number} */
  distanceSquared(v) {
    return pow((this.x - v.x), 2) + pow((this.y - v.y), 2);
  }

  /** Returns a new vector in same direction as this one with the length passed in
     * @param {Number} [length=1]
     * @return {Vector2} */
  normalize({length = 1}) {
    var l = this.length();
    return l ? this.scale(length / l) : new Vector2(x: 0, y: length);
  }

  /** Returns a new vector clamped to length passed in
     * @param {Number} [length=1]
     * @return {Vector2} */
  clampLength({length = 1}) {
    var l = this.length();
    return l > length ? this.scale(length / l) : this;
  }

  /** Returns the dot product of this and the vector passed in
     * @param {Vector2} vector
     * @return {Number} */
  dot(v) {
    return this.x * v.x + this.y * v.y;
  }

  /** Returns the cross product of this and the vector passed in
     * @param {Vector2} vector
     * @return {Number} */
  cross(v) {
    return this.x * v.y - this.y * v.x;
  }

  /** Returns the angle of this vector, up is angle 0
     * @return {Number} */
  angle() {
    return atan2(this.x, this.y);
  }

  /** Sets this vector with angle and length passed in
     * @param {Number} [angle=0]
     * @param {Number} [length=1] */
  setAngle(rand, {a = 0, length = 1}) {
    this.x = length * sin(a);
    this.y = length * cos(a);
    return this;
  }

  /** Returns copy of this vector rotated by the angle passed in
     * @param {Number} angle
     * @return {Vector2} */
  rotate(a) {
    var c = cos(a), s = sin(a);
    return new Vector2(x: this.x * c - this.y * s, y: this.x * s + this.y * c);
  }

  /** Returns the integer direction of this vector, corrosponding to multiples of 90 degree rotation (0-3)
     * @return {Number} */
  direction() {
    return (this.x).abs() > (this.y).abs()
        ? this.x < 0
            ? 3
            : 1
        : this.y < 0
            ? 2
            : 0;
  }

  /** Returns a copy of this vector that has been inverted
     * @return {Vector2} */
  invert() {
    return new Vector2(x: this.y, y: -this.x);
  }

  /** Returns a copy of this vector with each axis floored
     * @return {Vector2} */
  floor() {
    return new Vector2(x: (this.x).floor(), y: (this.y).floor());
  }

  /** Returns the area this vector covers as a rectangle
     * @return {Number} */
  area() {
    return (this.x * this.y).abs();
  }

  /** Returns a new vector that is p percent between this and the vector passed in
     * @param {Vector2} vector
     * @param {Number}  percent
     * @return {Vector2} */
  lerp(v, p) {
    return this.add(v.subtract(this).scale(Utils.shared.simpleClamp(p)));
  }

  /** Returns true if this vector is within the bounds of an array size passed in
     * @param {Vector2} arraySize
     * @return {Boolean} */
  arrayCheck(arraySize) {
    return this.x >= 0 &&
        this.y >= 0 &&
        this.x < arraySize.x &&
        this.y < arraySize.y;
  }

  /** Returns this vector expressed as a string
     * @param {float} digits - precision to display
     * @return {String} */
  toString({digits = 3}) {
    return "(${(this.x < 0 ? '' : ' ')} ${this.x}, ${(this.y < 0 ? '' : ' ')} ${this.y}} )";
  }
}
