import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math.dart';

class PhysicsBodySimple {
  Point pos = Point(0, 0);
  Size _size = Size(0, 0);
  /** @property {Number} [mass=objectDefaultMass]                 - How heavy the object is, static if 0 */
  double mass = 1;
  /** @property {Number} [damping=objectDefaultDamping]           - How much to slow down velocity each frame (0-1) */
  double damping = 0.99;
  /** @property {Number} [angleDamping=objectDefaultAngleDamping] - How much to slow down rotation each frame (0-1) */
  double angleDamping = 0.99;
  /** @property {Number} [elasticity=objectDefaultElasticity]     - How bouncy the object is when colliding (0-1) */
  double elasticity = 0;
  /** @property {Number} [friction=objectDefaultFriction]         - How much friction to apply when sliding (0-1) */
  double friction = 0.8;
  /** @property {Number} [gravityScale=1]                         - How much to scale gravity by for this object */
  double gravityScale = 1;
  /** @property {Number} [renderOrder=0]                          - Objects are sorted by render order */
  int renderOrder = 0;
  /** @property {Vector2} [velocity=new Vector2()]                - Velocity of the object */
  Vector2 _velocity = Vector2(0, 0);
  /** @property {Number} [angleVelocity=0]                        - Angular velocity of the object */
  double _angleVelocity = 0;
  bool _immovable = false;
  bool collideSolidObjects = true;
  dynamic object;

  PhysicsBodySimple({
    required this.object,
    required this.pos,
    size,
    mass,
    damping,
    angleDamping,
    elasticity,
    friction,
    gravityScale,
    renderOrder,
    velocity,
    angleVelocity,
    collideSolidObjects,
  }) {
    this.mass = mass ?? 1;
    this.damping = damping ?? 0.99;
    this.angleDamping = angleDamping ?? 0.99;
    this.elasticity = elasticity ?? 0;
    this.friction = friction ?? 0.8;
    this.gravityScale = gravityScale ?? 1;
    this.renderOrder = renderOrder ?? 0;
    this.velocity = velocity ?? Vector2(0, 0);
    this.angleVelocity = angleVelocity ?? 0;
    this.collideSolidObjects = collideSolidObjects ?? true;
    this.pos = pos ?? Point(0, 0);
    this.size = size ?? Size(0, 0);
  }

  Vector2 get velocity {
    return this._velocity;
  }

  void set velocity(Vector2 value) {
    this._velocity = value;
  }

  double get angleVelocity {
    return this._angleVelocity;
  }

  void set angleVelocity(double value) {
    this._angleVelocity = value;
  }

  Size get size {
    return this._size;
  }

  void set size(Size value) {
    this._size = value;
  }

  bool get immovable {
    return this._immovable;
  }

  void set immovable(bool value) {
    this._immovable = value;
  }

  update(Canvas canvas, {double elapsedTime = 0.0, bool shouldUpdate = true}) {}
}
