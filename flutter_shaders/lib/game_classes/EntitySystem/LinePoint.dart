/**
 * @author       Richard Davey <rich@photonstorm.com>
 * @copyright    2016 Photon Storm Ltd.
 * @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
 */
 //https://github.com/photonstorm/phaser-ce/blob/master/src/geom/Point.js

import 'dart:math';

import 'package:flutter_shaders/helpers/utils.dart';

/**
 * A Point object represents a location in a two-dimensional coordinate system, where x represents the horizontal axis and y represents the vertical axis.
 * The following code creates a point at (0,0):
 * `var myPoint = new Phaser.Point();`
 * You can also use them as 2D Vectors and you'll find different vector related methods in this class.
 *
 * @class Phaser.Point
 * @constructor
 * @param {number} [x=0] - The horizontal position of this Point.
 * @param {number} [y=0] - The vertical position of this Point.
 */
class LinePoint{

   

    /**
     * @property {number} x - The x value of the point.
     */
    double x = 0.0;

    /**
     * @property {number} y - The y value of the point.
     */
    double y = 0.0;

    /**
     * @property {number} type - The const type of this object.
     * @readonly
     */
    String type = "LINEPOINT";

  LinePoint(x, y){
    this.x = x ?? 0;
    this.y = y ?? 0;
  }

    /**
     * Copies the x and y properties from any given object to this Point.
     *
     * @method Phaser.Point#copyFrom
     * @param {any} source - The object to copy from.
     * @return {Phaser.Point} This Point object.
     */
    copyFrom(source){
        return this.setTo(source.x, source.y);
    }

    /**
     * Inverts the x and y values of this Point
     *
     * @method Phaser.Point#invert
     * @return {Phaser.Point} This Point object.
     */
    invert(){
        return this.setTo(this.y, this.x);
    }

    /**
     * Sets the `x` and `y` values of this Point object to the given values.
     * If you omit the `y` value then the `x` value will be applied to both, for example:
     * `Point.setTo(2)` is the same as `Point.setTo(2, 2)`
     *
     * Identical to {@link #set}.
     *
     * @method Phaser.Point#setTo
     * @param {number} x - The horizontal value of this point.
     * @param {number} [y] - The vertical value of this point. If not given the x value will be used in its place.
     * @return {Phaser.Point} This Point object. Useful for chaining method calls.
     */
    setTo(x, y){
        return this.set(x, y);
    }

    /**
     * Sets the `x` and `y` values of this Point object to the given values.
     * If you omit the `y` value then the `x` value will be applied to both, for example:
     * `Point.set(2)` is the same as `Point.set(2, 2)`
     *
     * Identical to {@link #setTo}.
     *
     * @method Phaser.Point#set
     * @param {number} x - The horizontal value of this point.
     * @param {number} [y] - The vertical value of this point. If not given the x value will be used in its place.
     * @return {Phaser.Point} This Point object. Useful for chaining method calls.
     */
    set(x, y){
        return LinePoint.set(this, x, y);
    }

    /**
     * Sets the `x` and `y` values of this Point object from a given polar coordinate.
     *
     * @method Phaser.Point#setToPolar
     * @param {number} azimuth - The angular coordinate, in radians (unless `asDegrees`).
     * @param {number} [radius=1] - The radial coordinate (length).
     * @param {boolean} [asDegrees=false] - True if `azimuth` is in degrees.
     * @return {Phaser.Point} This Point object. Useful for chaining method calls.
     */
    setToPolar(azimuth, radius, asDegrees){
        if (radius == null) { radius = 1; }
        if (asDegrees) { azimuth = Utils.shared.degreesToRadians(azimuth); }

        return this.setTo(cos(azimuth) * radius, sin(azimuth) * radius);
    }

    /**
     * Adds the given x and y values to this Point.
     *
     * @method Phaser.Point#add
     * @param {number} x - The value to add to Point.x.
     * @param {number} y - The value to add to Point.y.
     * @return {Phaser.Point} This Point object. Useful for chaining method calls.
     */
    add(x, y){
        this.x += x;
        this.y += y;
        return this;
    }

    /**
     * Subtracts the given x and y values from this Point.
     *
     * @method Phaser.Point#subtract
     * @param {number} x - The value to subtract from Point.x.
     * @param {number} y - The value to subtract from Point.y.
     * @return {Phaser.Point} This Point object. Useful for chaining method calls.
     */
    subtract(x, y){
        this.x -= x;
        this.y -= y;
        return this;
    }

    /**
     * Multiplies Point.x and Point.y by the given x and y values. Sometimes known as `Scale`.
     *
     * @method Phaser.Point#multiply
     * @param {number} x - The value to multiply Point.x by.
     * @param {number} y - The value to multiply Point.x by.
     * @return {Phaser.Point} This Point object. Useful for chaining method calls.
     */
    multiply(x, y){
        this.x *= x;
        this.y *= y;
        return this;
    }

    /**
     * Divides Point.x and Point.y by the given x and y values.
     *
     * @method Phaser.Point#divide
     * @param {number} x - The value to divide Point.x by.
     * @param {number} y - The value to divide Point.x by.
     * @return {Phaser.Point} This Point object. Useful for chaining method calls.
     */
    divide(x, y){
        this.x /= x;
        this.y /= y;
        return this;
    }

    /**
     * Clamps the x value of this Point to be between the given min and max.
     *
     * @method Phaser.Point#clampX
     * @param {number} min - The minimum value to clamp this Point to.
     * @param {number} max - The maximum value to clamp this Point to.
     * @return {Phaser.Point} This Point object.
     */
    clampX(min, max){
        this.x = Utils.shared.clamp(this.x, min, max);
        return this;
    }

    /**
     * Clamps the y value of this Point to be between the given min and max
     *
     * @method Phaser.Point#clampY
     * @param {number} min - The minimum value to clamp this Point to.
     * @param {number} max - The maximum value to clamp this Point to.
     * @return {Phaser.Point} This Point object.
     */
    clampY(min, max){
        this.y = Utils.shared.clamp(this.y, min, max);
        return this;
    }

    /**
     * Clamps this Point object values to be between the given min and max.
     *
     * @method Phaser.Point#clamp
     * @param {number} min - The minimum value to clamp this Point to.
     * @param {number} max - The maximum value to clamp this Point to.
     * @return {Phaser.Point} This Point object.
     */
    clamp(min, max){
        this.x = Utils.shared.clamp(this.x, min, max);
        this.y = Utils.shared.clamp(this.y, min, max);
        return this;
    }

    /**
     * If this Point is not within the given object, moves it inside (at the nearest edge).
     *
     * @method Phaser.Point#clip
     * @param {any} rect - A {@link Phaser.Rectangle} or any object with left, top, right, and bottom properties.
     * @return {Phaser.Point} This Point object.
     */
    clip(rect){
        var left = rect.left,
            top = rect.top,
            right = rect.right,
            bottom = rect.bottom;

        if (this.x < left) { this.x = left; }
        else if (this.x > right) { this.x = right; }
        if (this.y < top) { this.y = top; }
        else if (this.y > bottom) { this.y = bottom; }

        return this;
    }

    /**
     * Creates a copy of the given Point.
     *
     * @method Phaser.Point#clone
     * @param {Phaser.Point} [output] Optional Point object. If given the values will be set into this object, otherwise a brand new Point object will be created and returned.
     * @return {Phaser.Point} The new Point object.
     */
    clone(){
      
      LinePoint output = LinePoint(this.x, this.y);
        
      return output;
    }

    /**
     * Copies the x and y properties from this Point to any given object.
     *
     * @method Phaser.Point#copyTo
     * @param {any} dest - The object to copy to.
     * @return {object} The dest object.
     */
    copyTo(){
        LinePoint dest = LinePoint(this.x,this.y);

        return dest;
    }

    /**
     * Returns the distance of this Point object to the given object (can be a Circle, Point or anything with x/y properties)
     *
     * @method Phaser.Point#distance
     * @param {object} dest - The target object. Must have visible x and y properties that represent the center of the object.
     * @param {boolean} [round] - Round the distance to the nearest integer (default false).
     * @return {number} The distance between this Point object and the destination Point object.
     */
    distance(dest, round){
        return distancePoint(this,dest, round);
    }

    /**
     * Determines whether the given objects x/y values are equal to this Point object.
     *
     * @method Phaser.Point#equals
     * @param {Phaser.Point|any} a - The object to compare with this Point.
     * @return {boolean} A value of true if the x and y points are equal, otherwise false.
     */
    equals(a){
        return a.x == this.x && a.y == this.y;
    }

    /**
     * Determines whether a set of x-y coordinates are equal to this Point's.
     *
     * @method Phaser.Point#equalsXY
     * @param {number} x - The x-coordinate to compare with this Point.
     * @param {number} y - The y-coordinate to compare with this Point.
     * @return {boolean} A value of true if the Point's coordinates are identical to the arguments, otherwise false.
     */
    equalsXY(x, y){
        return this.x == x && this.y == y;
    }

    fuzzyEquals(a, epsilon){
        return fuzzyEquals(a, epsilon);
    }

    fuzzyEqualsXY(x, y, epsilon){
        return fuzzyEqualsXY(x, y, epsilon);
    }

    /**
     * Returns the angle between this Point object and another object with public x and y properties.
     *
     * @method Phaser.Point#angle
     * @param {Phaser.Point|any} a - The object to get the angle from this Point to.
     * @param {boolean} [asDegrees=false] - Return a value in radians (false) or degrees (true)?
     * @return {number} The angle, where this Point is the vertex. Within [-pi, pi] or [-180deg, 180deg].
     */
    angle(a, asDegrees){
        return this.angleXY(a.x, a.y, asDegrees);
    }

    /**
     * Returns the angle between this Point object and an x-y coordinate pair.
     *
     * @method Phaser.Point#angleXY
     * @param {number} x - The x-coordinate
     * @param {number} y - The y-coordinate
     * @param {boolean} [asDegrees=false] - Return a value in radians (false) or degrees (true)?
     * @return {number} The angle, where this Point is the vertex. Within [-pi, pi] or [-180deg, 180deg].
     */
    angleXY(x, y, asDegrees){
        var angle = atan2(y - this.y, x - this.x);

        if (asDegrees){
            return Utils.shared.radToDeg(angle);
        }
        else{
            return angle;
        }
    }

    /**
     * Returns the arctangent of this Point.
     *
     * @method Phaser.Point#atan
     * @param {boolean} [asDegrees=false] - Return a value in radians (false) or degrees (true)?
     * @return {number} The angle, where the vertex is (0, 0). Within [-pi, pi] or [-180deg, 180deg].
     */
    atan(asDegrees){
        var angle = atan2(this.y, this.x);

        if (asDegrees){
            return Utils.shared.radToDeg(angle);
        }
        else
        {
            return angle;
        }
    }

    /**
     * Rotates this Point around the x/y coordinates given to the desired angle.
     *
     * @method Phaser.Point#rotate
     * @param {number} x - The x coordinate of the anchor point.
     * @param {number} y - The y coordinate of the anchor point.
     * @param {number} angle - The angle in radians (unless asDegrees is true) to rotate the Point to.
     * @param {boolean} [asDegrees=false] - Is the given angle in radians (false) or degrees (true)?
     * @param {number} [distance] - An optional distance constraint between the Point and the anchor.
     * @return {Phaser.Point} The modified point object.
     */
    rotate(x, y, angle, asDegrees, distance){
        return rotatePoint(this, x, y, angle, asDegrees, distance);
    }

    /**
     * Calculates the length of the Point object.
     *
     * @method Phaser.Point#getMagnitude
     * @return {number} The length of the Point.
     */
    getMagnitude(){
        return sqrt((this.x * this.x) + (this.y * this.y));
    }

    /**
     * Calculates the length squared of the Point object.
     *
     * @method Phaser.Point#getMagnitudeSq
     * @return {number} The length ^ 2 of the Point.
     */
    getMagnitudeSq(){
        return (this.x * this.x) + (this.y * this.y);
    }

    /**
     * Alters the length of the Point without changing the direction.
     *
     * @method Phaser.Point#setMagnitude
     * @param {number} magnitude - The desired magnitude of the resulting Point.
     * @return {Phaser.Point} This Point object.
     */
    setMagnitude(magnitude){
        return this.normalize().multiply(magnitude, magnitude);
    }

    /**
     * Alters the Point object so that its length is 1, but it retains the same direction.
     *
     * @method Phaser.Point#normalize
     * @return {Phaser.Point} This Point object.
     */
    normalize(){
        if (!this.isZero())
        {
            var m = this.getMagnitude();
            this.x /= m;
            this.y /= m;
        }

        return this;
    }

    /**
     * Alters the Point object so its magnitude is at most the max value.
     *
     * @method Phaser.Point#limit
     * @param {number} max - The maximum magnitude for the Point.
     * @return {Phaser.Point} This Point object.
     * @see Phaser.Point#expand
     */
    limit(max){
        if (this.getMagnitudeSq() > max * max)
        {
            this.setMagnitude(max);
        }

        return this;
    }

    /**
     * Alters the Point object so its magnitude is at least the min value.
     *
     * @method Phaser.Point#expand
     * @param {number} min - The minimum magnitude for the Point.
     * @return {Phaser.Point} This Point object.
     * @see Phaser.Point#limit
     */
    expand(min){
        if (this.getMagnitudeSq() < min * min)
        {
            this.setMagnitude(min);
        }

        return this;
    }

    /**
     * Determine if this point is at 0,0.
     *
     * @method Phaser.Point#isZero
     * @return {boolean} True if this Point is 0,0, otherwise false.
     */
    isZero(){
        return (this.x == 0 && this.y == 0);
    }

    /**
     * The dot product of this and another Point object.
     *
     * @method Phaser.Point#dot
     * @param {Phaser.Point} a - The Point object to get the dot product combined with this Point.
     * @return {number} The result.
     */
    dot(a){
        return ((this.x * a.x) + (this.y * a.y));
    }

    /**
     * The cross product of this and another Point object.
     *
     * @method Phaser.Point#cross
     * @param {Phaser.Point} a - The Point object to get the cross product combined with this Point.
     * @return {number} The result.
     */
    cross(a){
        return ((this.x * a.y) - (this.y * a.x));
    }

    /**
     * Make this Point perpendicular (90 degrees rotation)
     *
     * @method Phaser.Point#perp
     * @return {Phaser.Point} This Point object.
     */
    perp(){
        return this.setTo(-this.y, this.x);
    }

    /**
     * Make this Point perpendicular (-90 degrees rotation)
     *
     * @method Phaser.Point#rperp
     * @return {Phaser.Point} This Point object.
     */
    rperp(){
        return this.setTo(this.y, -this.x);
    }

    /**
     * Right-hand normalize (make unit length) this Point.
     *
     * @method Phaser.Point#normalRightHand
     * @return {Phaser.Point} This Point object.
     */
    normalRightHand(){
        return this.setTo(this.y * -1, this.x);
    }

    /**
     * Math.floor() both the x and y properties of this Point.
     *
     * @method Phaser.Point#floor
     * @return {Phaser.Point} This Point object.
     */
    floor(){
        return this.setTo((this.x).floor(), (this.y).floor());
    }

    /**
     * Math.ceil() both the x and y properties of this Point.
     *
     * @method Phaser.Point#ceil
     * @return {Phaser.Point} This Point object.
     */
    ceil(){
        return this.setTo(ceil(this.x).ceil(),(this.y).ceil());
    }

    /**
     * Math.round() both the x and y properties of this Point.
     *
     * @method Phaser.Point#round
     * @return {Phaser.Point} This Point object.
     */
    round(){
        return this.setTo((this.x).round(), (this.y).round());
    }

    /**
     * Returns a string representation of this object.
     *
     * @method Phaser.Point#toString
     * @return {string} A string representation of the instance.
     */
    toString(){
        return '[{Point (x=' + this.x + ' y=' + this.y + ')}]';
    }

    /**
 * Adds the coordinates of two points together to create a new point.
 *
 * @method Phaser.Point.add
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
addPoints(a, b){
   LinePoint out = LinePoint(a.x + b.x, a.y + b.y);
    return out;
}

/**
 * Subtracts the coordinates of two points to create a new point.
 *
 * @method Phaser.Point.subtract
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
subtractPoints(a, b){
    LinePoint out = LinePoint(a.x - b.x, a.y - b.y);

    return out;
}

/**
 * Subtracts the coordinates of two points to create a new point.
 *
 * @method Phaser.Point.subtract
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
multiplyPoints(a, b){
    LinePoint out = LinePoint(a.x * b.x, a.y * b.y);
    return out;
}

/**
 * Divides the coordinates of two points to create a new point.
 *
 * @method Phaser.Point.divide
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
dividePoints(a, b){
    LinePoint out = LinePoint(a.x / b.x, a.y / b.y);
    return out;
}

/**
 * Determines whether the two given Point objects are equal. They are considered equal if they have the same x and y values.
 *
 * @method Phaser.Point.equals
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @return {boolean} A value of true if the Points are equal, otherwise false.
 */
equalsPoints(a, b){
    return a.x == b.x && a.y == b.y;
}

equalsXYPoints(a, x, y){
    return a.x == x && a.y == y;
}

fuzzyEqualsPoints(a, b, epsilon){
    return Utils.shared.fuzzyEqual(a.x, b.x, epsilon) &&
           Utils.shared.fuzzyEqual(a.y, b.y, epsilon);
}

fuzzyEqualsXYPoints(a, x, y, epsilon){
    return Utils.shared.fuzzyEqual(a.x, x, epsilon) &&
           Utils.shared.fuzzyEqual(a.y, y, epsilon);
}

/**
 * Returns the angle between two Point objects.
 *
 * @method Phaser.Point.angle
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @return {number} The angle, where b is the vertex. Within [-pi, pi].
 */
anglePoints(a, b){
    return atan2(a.y - b.y, a.x - b.x);
}


/**
 * Creates a negative Point.
 *
 * @method Phaser.Point.negative
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
negative(a){
   LinePoint out = Point();

    return out.setTo(-a.x, -a.y);
}

/**
 * Adds two 2D Points together and multiplies the result by the given scalar.
 *
 * @method Phaser.Point.multiplyAdd
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @param {number} s - The scaling value.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
multiplyAdd(a, b, s){
    LinePoint out = LinePoint((a.x + b.x) * s, (a.y + b.y) * s);

    return out;
}

/**
 * Interpolates the two given Points, based on the `f` value (between 0 and 1) and returns a new Point.
 *
 * @method Phaser.Point.interpolate
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @param {number} f - The level of interpolation between the two points. Indicates where the new point will be, along the line between pt1 and pt2. If f=1, pt1 is returned; if f=0, pt2 is returned.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
interpolate(a, b, f){
    LinePoint out = LinePoint(a.x + (b.x - a.x) * f, a.y + (b.y - a.y) * f);

    return out;
}

/**
 * Return a perpendicular vector (90 degrees rotation)
 *
 * @method Phaser.Point.perp
 * @param {Phaser.Point} a - The Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
perpPoint(a){
    LinePoint out = LinePoint(-a.y, a.x);

    return out;
}

rperpPoint(a){
    LinePoint out = LinePoint(a.y, -a.x);

    return out;
}


/**
 * Returns the euclidian distance of this Point object to the given object (can be a Circle, Point or anything with x/y properties).
 *
 * @method Phaser.Point.distance
 * @param {object} a - The target object. Must have visible x and y properties that represent the center of the object.
 * @param {object} b - The target object. Must have visible x and y properties that represent the center of the object.
 * @param {boolean} [round=false] - Round the distance to the nearest integer.
 * @return {number} The distance between this Point object and the destination Point object.
 */
distancePoint(a, b, round){
    var distance = Utils.shared.distance(a.x, a.y, b.x, b.y);
    return round ? (distance).round() : distance;
}


/**
 * Project two Points onto another Point.
 *
 * @method Phaser.Point.project
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
project(a, b){
  var amt = a.dot(b) / b.getMagnitudeSq();

     LinePoint out = LinePoint(0, 0);

    // =!
    if (amt != 0){
        out = LinePoint(amt * b.x, amt * b.y);
    }

    return out;
}

/**
 * Project two Points onto a Point of unit length.
 *
 * @method Phaser.Point.projectUnit
 * @param {Phaser.Point} a - The first Point object.
 * @param {Phaser.Point} b - The second Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
projectUnit(a, b){
    LinePoint out = LinePoint(0,0);

    var amt = a.dot(b);

    if (amt != 0){
        //out = LinePoint(amt * b.x, amt * b.y);
        out.setTo(amt * b.x, amt * b.y);
    }

    return out;
}

/**
 * Rotates a Point object, or any object with exposed x/y properties, around the given coordinates by
 * the angle specified. If the angle between the point and coordinates was 45 deg and the angle argument
 * is 45 deg then the resulting angle will be 90 deg, as the angle argument is added to the current angle.
 *
 * The distance allows you to specify a distance constraint for the rotation between the point and the
 * coordinates. If none is given the distance between the two is calculated and used.
 *
 * @method Phaser.Point.rotate
 * @param {Phaser.Point} a - The Point object to rotate.
 * @param {number} x - The x coordinate of the anchor point
 * @param {number} y - The y coordinate of the anchor point
 * @param {number} angle - The angle in radians (unless asDegrees is true) to rotate the Point by.
 * @param {boolean} [asDegrees=false] - Is the given angle in radians (false) or degrees (true)?
 * @param {number} [distance] - An optional distance constraint between the Point and the anchor.
 * @return {Phaser.Point} The modified point object.
 */
rotatePoint(a, x, y, angle, asDegrees, distance){
    if (asDegrees) { angle = Utils.shared.degreesToRadians(angle); }

    if (distance == null){
        a.subtract(x, y);

        var s = sin(angle);
        var c = cos(angle);

        var tx = c * a.x - s * a.y;
        var ty = s * a.x + c * a.y;

        a.x = tx + x;
        a.y = ty + y;
    }
    else{
        var t = angle + atan2(a.y - y, a.x - x);
        a.x = x + distance * cos(t);
        a.y = y + distance * sin(t);
    }

    return a;
}

// end of class
}







/**
 * Right-hand normalize (make unit length) a Point.
 *
 * @method Phaser.Point.normalRightHand
 * @param {Phaser.Point} a - The Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
Phaser.Point.normalRightHand = function (a, out)
{
    if (out === undefined) { out = new Phaser.Point(); }

    return out.setTo(a.y * -1, a.x);
};

/**
 * Normalize (make unit length) a Point.
 *
 * @method Phaser.Point.normalize
 * @param {Phaser.Point} a - The Point object.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
Phaser.Point.normalize = function (a, out)
{
    if (out === undefined) { out = new Phaser.Point(); }

    var m = a.getMagnitude();

    if (m !== 0)
    {
        out.setTo(a.x / m, a.y / m);
    }

    return out;
};



/**
 * Calculates centroid (or midpoint) from an array of points. If only one point is provided, that point is returned.
 *
 * @method Phaser.Point.centroid
 * @param {Phaser.Point[]} points - The array of one or more points.
 * @param {Phaser.Point} [out] - Optional Point to store the value in, if not supplied a new Point object will be created.
 * @return {Phaser.Point} The new Point object.
 */
Phaser.Point.centroid = function (points, out)
{
    if (out === undefined) { out = new Phaser.Point(); }

    if (Object.prototype.toString.call(points) !== '[object Array]')
    {
        throw new Error('Phaser.Point. Parameter \'points\' must be an array');
    }

    var pointslength = points.length;

    if (pointslength < 1)
    {
        throw new Error('Phaser.Point. Parameter \'points\' array must not be empty');
    }

    if (pointslength === 1)
    {
        out.copyFrom(points[0]);
        return out;
    }

    for (var i = 0; i < pointslength; i++)
    {
        Phaser.Point.add(out, points[i], out);
    }

    out.divide(pointslength, pointslength);

    return out;
};

/**
 * Parses an object for x and/or y properties and returns a new Phaser.Point with matching values.
 * If the object doesn't contain those properties a Point with x/y of zero will be returned.
 *
 * @method Phaser.Point.parse
 * @static
 * @param {object} obj - The object to parse.
 * @param {string} [xProp='x'] - The property used to set the Point.x value.
 * @param {string} [yProp='y'] - The property used to set the Point.y value.
 * @return {Phaser.Point} The new Point object.
 */
Phaser.Point.parse = function (obj, xProp, yProp)
{
    xProp = xProp || 'x';
    yProp = yProp || 'y';

    var point = new Phaser.Point();

    if (obj[xProp])
    {
        point.x = parseFloat(obj[xProp]);
    }

    if (obj[yProp])
    {
        point.y = parseFloat(obj[yProp]);
    }

    return point;
};

/**
 * Truncates the x and y values, removing any fractional parts.
 *
 * @method Phaser.Point.trunc
 * @static
 * @param {object} obj - The Point.
 * @return {object} The modified Point.
 */
Phaser.Point.trunc = function (obj)
{
    obj.x = Phaser.Math.trunc(obj.x);
    obj.y = Phaser.Math.trunc(obj.y);

    return obj;
};

/**
 * Tests a Point or Point-like object.
 *
 * @method Phaser.Point.isPoint
 * @static
 * @param {object} obj - The object to test.
 * @return {boolean} - True if the object has numeric x and y properties.
 */
Phaser.Point.isPoint = function (obj)
{
    return (obj != null) && (typeof obj.x === 'number') && (typeof obj.y === 'number');
};

/**
 * Sets the `x` and `y` values of an object and returns the object.
 *
 * @method Phaser.Point#set
 * @static
 * @param {object} obj - An object with numeric x and y properties.
 * @param {number} x - The x value.
 * @param {number} [y] - The y value. If not given the x value will be used in its place.
 * @return {object} The object. Useful for chaining method calls.
 */
Phaser.Point.set = function (obj, x, y)
{
    obj.x = x || 0;
    obj.y = y || ((y !== 0) ? obj.x : 0);

    return obj;
};

/**
 * Sorts an array of points in a clockwise direction, relative to a reference point.
 *
 * The sort is clockwise relative to the display, starting from a 12 o'clock position.
 * (In the Cartesian plane, it is anticlockwise, starting from the -y direction.)
 *
 * Example sequence: (0, -1), (1, 0), (0, 1), (-1, 0)
 *
 * @method Phaser.Point#sortClockwise
 * @static
 * @param {array} points - An array of Points or point-like objects (e.g., sprites).
 * @param {object|Phaser.Point} [center] - The reference point. If omitted, the {@link #centroid} (midpoint) of the points is used.
 * @return {array} The sorted array.
 */
Phaser.Point.sortClockwise = function (points, center)
{
    // Adapted from <https://stackoverflow.com/a/6989383/822138> (ciamej)

    if (!center)
    {
        center = this.centroid(points);
    }

    var cx = center.x;
    var cy = center.y;

    var sort = function (a, b)
    {
        if (a.x - cx >= 0 && b.x - cx < 0)
        {
            return -1;
        }

        if (a.x - cx < 0 && b.x - cx >= 0)
        {
            return 1;
        }

        if (a.x - cx === 0 && b.x - cx === 0)
        {
            if (a.y - cy >= 0 || b.y - cy >= 0)
            {
                return (a.y > b.y) ? 1 : -1;
            }

            return (b.y > a.y) ? 1 : -1;
        }

        // Compute the cross product of vectors (center -> a) * (center -> b)
        var det = (a.x - cx) * -(b.y - cy) - (b.x - cx) * -(a.y - cy);

        if (det < 0)
        {
            return -1;
        }

        if (det > 0)
        {
            return 1;
        }

        /*
         * Points a and b are on the same line from the center
         * Check which point is closer to the center
         */
        var d1 = (a.x - cx) * (a.x - cx) + (a.y - cy) * (a.y - cy);
        var d2 = (b.x - cx) * (b.x - cx) + (b.y - cy) * (b.y - cy);

        return (d1 > d2) ? -1 : 1;
    };

    return points.sort(sort);

}