/**
 * @author       Richard Davey <rich@photonstorm.com>
 * @copyright    2022 Photon Storm Ltd.
 * @license      {@link https://opensource.org/licenses/MIT|MIT License}
 */

import 'package:vector_math/vector_math.dart' as vectorMath;
import './CubicBezierInterpolation.dart' as CubicBezierCurve;

/**
 * @classdesc
 * A higher-order Bézier curve constructed of four points.
 *
 * @class CubicBezier
 * @extends Phaser.Curves.Curve
 * @memberof Phaser.Curves
 * @constructor
 * @since 3.0.0
 *
 * @param {(Phaser.Math.Vector2|Phaser.Math.Vector2[])} p0 - Start point, or an array of point pairs.
 * @param {Phaser.Math.Vector2} p1 - Control Point 1.
 * @param {Phaser.Math.Vector2} p2 - Control Point 2.
 * @param {Phaser.Math.Vector2} p3 - End Point.
 */
class CubicBezier {
  late vectorMath.Vector2 p0;
  late vectorMath.Vector2 p1;
  late vectorMath.Vector2 p2;
  late vectorMath.Vector2 p3;

  CubicBezier({
    /**
         * The start point of this curve.
         *
         * @name Phaser.Curves.CubicBezier#p0
         * @type {Phaser.Math.Vector2}
         * @since 3.0.0
         */
    required this.p0,

    /**
         * The first control point of this curve.
         *
         * @name Phaser.Curves.CubicBezier#p1
         * @type {Phaser.Math.Vector2}
         * @since 3.0.0
         */
    required this.p1,

    /**
         * The second control point of this curve.
         *
         * @name Phaser.Curves.CubicBezier#p2
         * @type {Phaser.Math.Vector2}
         * @since 3.0.0
         */
    required this.p2,

    /**
         * The end point of this curve.
         *
         * @name Phaser.Curves.CubicBezier#p3
         * @type {Phaser.Math.Vector2}
         * @since 3.0.0
         */
    required this.p3,
  }) {}

  /**
     * Gets the starting point on the curve.
     *
     * @method Phaser.Curves.CubicBezier#getStartPoint
     * @since 3.0.0
     *
     * @generic {Phaser.Math.Vector2} O - [out,$return]
     *
     * @param {Phaser.Math.Vector2} [out] - A Vector2 object to store the result in. If not given will be created.
     *
     * @return {Phaser.Math.Vector2} The coordinates of the point on the curve. If an `out` object was given this will be returned.
     */
  vectorMath.Vector2 getStartPoint() {
    return this.p0;
  }

  /**
     * Get point at relative position in curve according to length.
     *
     * @method Phaser.Curves.CubicBezier#getPoint
     * @since 3.0.0
     *
     * @generic {Phaser.Math.Vector2} O - [out,$return]
     *
     * @param {number} t - The position along the curve to return. Where 0 is the start and 1 is the end.
     * @param {Phaser.Math.Vector2} [out] - A Vector2 object to store the result in. If not given will be created.
     *
     * @return {Phaser.Math.Vector2} The coordinates of the point on the curve. If an `out` object was given this will be returned.
     */
  vectorMath.Vector2 getPoint(double t) {
    var p0 = this.p0;
    var p1 = this.p1;
    var p2 = this.p2;
    var p3 = this.p3;

    return vectorMath.Vector2(
        CubicBezierCurve.CubicBezierInterpolation(t, p0.x, p1.x, p2.x, p3.x), CubicBezierCurve.CubicBezierInterpolation(t, p0.y, p1.y, p2.y, p3.y));
  }

  List<vectorMath.Vector2> points() {
    return [p0, p1, p2, p3];
  }
}
