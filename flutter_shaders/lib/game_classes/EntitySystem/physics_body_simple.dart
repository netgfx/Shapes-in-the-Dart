import 'dart:math';
import 'dart:ui';

import 'package:flutter_shaders/game_classes/EntitySystem/TDWorld.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/vector_little.dart';
import 'package:flutter_shaders/helpers/utils.dart';

class PhysicsBodySimple {
  Vector2 pos = Vector2(x: 0, y: 0);
  Vector2 _size = Vector2(x: 0, y: 0);
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
  Vector2 _velocity = Vector2(x: 0, y: 0);
  /** @property {Number} [angleVelocity=0]                        - Angular velocity of the object */
  double _angleVelocity = 0;
  bool _immovable = false;
  bool collideSolidObjects = true;
  dynamic object;
  bool collideTiles = true;
  double _angle = 0.0;
  /** Clamp max speed to avoid fast objects missing collisions
 *  @default
 *  @memberof Settings */
  double objectMaxSpeed = 1.0;
  double gravity = 0;
  dynamic groundObject;
  /** Enable physics solver for collisions between objects
 *  @default
 *  @memberof Settings */
  bool enablePhysicsSolver = true;
  TDWorld world;

  PhysicsBodySimple({
    required this.object,
    required this.pos,
    required this.world,
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
    this.velocity = velocity ?? Vector2(x: 0, y: 0);
    this.angleVelocity = angleVelocity ?? 0;
    this.collideSolidObjects = collideSolidObjects ?? true;
    this.size = size ?? Vector2(x: 0, y: 0);
  }

  double get angle {
    return this._angle;
  }

  void set angle(double value) {
    this._angle = value;
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

  Vector2 get size {
    return this._size;
  }

  void set size(Vector2 value) {
    this._size = value;
  }

  bool get immovable {
    return this._immovable;
  }

  void set immovable(bool value) {
    this._immovable = value;
  }

  dynamic getObject() {
    return this.object;
  }

  setCollision(
      {collideSolidObjects = false, isSolid = false, collideTiles = true}) {
    //ASSERT(collideSolidObjects || !isSolid); // solid objects must be set to collide

    this.collideSolidObjects = collideSolidObjects;
    this.immovable = isSolid;
    this.collideTiles = collideTiles;
  }

  /** Returns a copy of this vector times the vector passed in
     *  @param {Vector2} vector
     *  @return {Vector2} */
  multiply(Vector2 v) {
    return Vector2(x: this.pos.x * v.x, y: this.pos.y * v.y);
  }

  collideWithObject(o) {
    return 1;
  }

  update(Canvas canvas, {double elapsedTime = 0.0, bool shouldUpdate = true}) {
    // var parent = this.object;
    // if (parent) {
    //   // copy parent pos/angle
    //   this.pos = multiply(Vector2(x: parent.getMirrorSign(), y: 1))
    //       .rotate(-parent.angle)
    //       .add(parent.pos);
    //   //this.angle = parent.getMirrorSign()*this.localAngle + parent.angle;
    //   return;
    // }

    // limit max speed to prevent missing collisions
    this.velocity.x =
        Utils.shared.clamp(this.velocity.x, -objectMaxSpeed, objectMaxSpeed);
    this.velocity.y =
        Utils.shared.clamp(this.velocity.y, -objectMaxSpeed, objectMaxSpeed);

    // apply physics
    var oldPos = Point<double>(this.pos.x.toDouble(), this.pos.y.toDouble());
    this.velocity.x = this.damping * this.velocity.x;
    this.velocity.y =
        this.damping * this.velocity.y + gravity * this.gravityScale;
    this.pos = Vector2(
        x: this.pos.x + this.damping * this.velocity.x,
        y: this.pos.y +
            this.damping * this.velocity.y +
            gravity * this.gravityScale);

    this.angle += this.angleVelocity *= this.angleDamping;

    // physics sanity checks
    //ASSERT(this.angleDamping >= 0 && this.angleDamping <= 1);
    //ASSERT(this.damping >= 0 && this.damping <= 1);

    if (!this.enablePhysicsSolver ||
        this.mass == 0) // do not update collision for fixed objects
      return;

    var wasMovingDown = this.velocity.y < 0;
    if (this.groundObject != null) {
      // apply friction in local space of ground object
      var groundSpeed =
          this.groundObject!.velocity ? this.groundObject!.velocity.x : 0;
      this.velocity.x =
          groundSpeed + (this.velocity.x - groundSpeed) * this.friction;
      this.groundObject = 0;
      //debugOverlay && debugPhysics && debugPoint(this.pos.subtract(vec2(0,this.size.y/2)), '#0f0');
    }

    if (this.collideSolidObjects) {
      // check collisions against solid objects
      const epsilon =
          1e-3; // necessary to push slightly outside of the collision
      for (var o in this.world.getEngineObjectsCollide()) {
        // non solid objects don't collide with eachother
        if (!this.immovable & !o.immovable ||
            o.destroyed ||
            o.parent ||
            o == this) continue;

        // check collision
        if (!Utils.shared.isOverlapping(this.pos, this.size, o.pos, o.size))
          continue;

        // pass collision to objects
        if (!this.collideWithObject(o) | !o.collideWithObject(this)) continue;

        if (Utils.shared.isOverlapping(oldPos, this.size, o.pos, o.size)) {
          // if already was touching, try to push away
          var deltaPos = Utils.shared.subtract(oldPos, o.pos);
          var length = deltaPos.length();
          const pushAwayAccel = .001; // push away if already overlapping
          var velocity = length < .01
              ? Utils.shared.randVector(length: pushAwayAccel)
              : deltaPos.scale(pushAwayAccel / length);
          this.velocity = this.velocity.add(velocity);
          if (o.mass) // push away if not fixed
            o.velocity = o.velocity.subtract(velocity);

          //debugOverlay && debugPhysics && debugAABB(this.pos, this.size, o.pos, o.size, '#f00');
          continue;
        }

        // check for collision
        var sizeBoth = this.size.add(o.size);
        var smallStepUp = (oldPos.y - o.pos.y) * 2 >
            sizeBoth.y + gravity; // prefer to push up if small delta
        var isBlockedX = (oldPos.y - o.pos.y).abs() * 2 < sizeBoth.y;
        var isBlockedY = (oldPos.x - o.pos.x).abs() * 2 < sizeBoth.x;

        if (smallStepUp || isBlockedY || !isBlockedX) // resolve y collision
        {
          // push outside object collision
          this.pos.y = o.pos.y +
              (sizeBoth.y / 2 + epsilon) *
                  Utils.shared.sign(oldPos.y - o.pos.y);
          if (o.groundObject && wasMovingDown || !o.mass) {
            // set ground object if landed on something
            if (wasMovingDown) this.groundObject = o;

            // bounce if other object is fixed or grounded
            this.velocity.y *= -this.elasticity;
          } else if (o.mass) {
            // inelastic collision
            var inelastic =
                (this.mass * this.velocity.y + o.mass * o.velocity.y) /
                    (this.mass + o.mass);

            // elastic collision
            var elastic0 =
                this.velocity.y * (this.mass - o.mass) / (this.mass + o.mass) +
                    o.velocity.y * 2 * o.mass / (this.mass + o.mass);
            var elastic1 =
                o.velocity.y * (o.mass - this.mass) / (this.mass + o.mass) +
                    this.velocity.y * 2 * this.mass / (this.mass + o.mass);

            // lerp betwen elastic or inelastic based on elasticity
            var elasticity = max(this.elasticity, o.elasticity as double);
            this.velocity.y =
                Utils.shared.lerp(elasticity, min: inelastic, max: elastic0);
            o.velocity.y =
                Utils.shared.lerp(elasticity, min: inelastic, max: elastic1);
          }
        }
        if (!smallStepUp && (isBlockedX || !isBlockedY)) // resolve x collision
        {
          // push outside collision
          this.pos.x = o.pos.x +
              (sizeBoth.x / 2 + epsilon) *
                  Utils.shared.sign(oldPos.x - o.pos.x);
          if (o.mass) {
            // inelastic collision
            var inelastic =
                (this.mass * this.velocity.x + o.mass * o.velocity.x) /
                    (this.mass + o.mass);

            // elastic collision
            var elastic0 =
                this.velocity.x * (this.mass - o.mass) / (this.mass + o.mass) +
                    o.velocity.x * 2 * o.mass / (this.mass + o.mass);
            var elastic1 =
                o.velocity.x * (o.mass - this.mass) / (this.mass + o.mass) +
                    this.velocity.x * 2 * this.mass / (this.mass + o.mass);

            // lerp betwen elastic or inelastic based on elasticity
            var elasticity = max(this.elasticity, o.elasticity as double);
            this.velocity.x =
                Utils.shared.lerp(elasticity, min: inelastic, max: elastic0);
            o.velocity.x =
                Utils.shared.lerp(elasticity, min: inelastic, max: elastic1);
          } else // bounce if other object is fixed
            this.velocity.x *= -this.elasticity;
        }
        //debugOverlay && debugPhysics && debugAABB(this.pos, this.size, o.pos, o.size, '#f0f');
      }
    }
  }
}