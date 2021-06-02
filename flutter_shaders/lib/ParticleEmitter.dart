import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import 'Particle.dart';
import 'ShapeMaster.dart';

enum ParticleType { FIRE, EXPLODE, PATH, IMPLOSION, SNOW, FOUNTAIN }
enum EndAnimation { FADE_OUT, INSTANT, SCALE_DOWN }
enum SpreadBehaviour { CONTINUOUS, ONE_TIME }
enum BaseBehaviour { ALWAYS_ON, INITIALY_ON, ALWAYS_OFF, INITIALLY_OFF }

class ParticleEmitter extends CustomPainter {
  final Animation listenable;
  ShapeType type = ShapeType.Rect;
  Size particleSize = Size(20, 20);
  double radius = 0.0;
  Canvas? canvas;
  Offset center = Offset(0, 0);
  double? angle = 0;
  List<Particle> particles = [];
  Color color = Colors.orange;
  int minParticles = 2;
  final _random = new Random();
  bool running = true;
  int maxDistance = 200;
  late Paint painter;
  ParticleType particleType = ParticleType.EXPLODE;
  bool hasBase = true;
  EndAnimation endAnimation = EndAnimation.INSTANT;
  double minimumSpeed = 0.01;
  double maximumSpeed = 0.05;
  double gravity = 0.5;
  double delay = 0.5;
  BlendMode blendMode = BlendMode.src;
  AnimationController controller;

  /// in seconds
  static const initialTTL = {"max": 1000, "min": 500};
  Map<String, int> timeToLive = {"max": 1000, "min": 500};
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  SpreadBehaviour spreadBehaviour = SpreadBehaviour.ONE_TIME;

  ////////////////////////////////////////////////////////////////////////
  /// Constructor
  ParticleEmitter(
      {required this.type,
      required this.particleSize,
      required this.minParticles,
      required this.radius,
      required this.center,
      required this.color,
      required this.listenable,
      required this.controller,
      required this.particleType,
      required this.endAnimation,
      required this.spreadBehaviour,
      this.minimumSpeed = 0.01,
      this.maximumSpeed = 0.05,
      this.timeToLive = initialTTL,
      this.gravity = 0.1,
      this.hasBase = true,
      this.blendMode = BlendMode.src,
      this.delay = 0.5})
      : super(repaint: listenable) {
    /// initializer
    this.painter = Paint()
      ..color = this.color
      ..blendMode = this.blendMode
      ..style = PaintingStyle.fill;

    // time
    this.currentTime = DateTime.now().millisecondsSinceEpoch;

    if (this.particleType == ParticleType.EXPLODE && (this.spreadBehaviour == SpreadBehaviour.ONE_TIME || this.spreadBehaviour == SpreadBehaviour.CONTINUOUS)) {
      // then create some particles
      if (particles.length == 0) {
        for (var i = 0; i < minParticles; i++) {
          double speed = randomDelay(min: this.minimumSpeed, max: this.maximumSpeed);
          double rand = 0;
          double randX = this.particleType == ParticleType.EXPLODE ? 0 : randomX();
          double _radius = randomizeRadius();
          Map<String, double> endPath = randomPointOnRadius();
          Paint _painter = this.painter;
          if (this.endAnimation == EndAnimation.FADE_OUT) {
            _painter = Paint()
              ..color = this.color
              ..blendMode = this.blendMode
              ..style = PaintingStyle.fill;
          }
          particles.add(new Particle(
              x: randX,
              y: -rand,
              radius: _radius,
              speed: speed,
              endPath: endPath,
              timeAlive: DateTime.now().millisecondsSinceEpoch,
              currentTime: this.currentTime,
              renderDelay: doubleInRange(0.01, this.delay),
              opacity: 1.0,
              painter: _painter));

          // {"x": randX, "y": -rand, "radius": _radius, "speed": speed, "endPath": endPath, "timeAlive": DateTime.now().millisecondsSinceEpoch, "current": this.currentTime, "renderDelay": doubleInRange(0.01, this.delay), "opacity": 1.0});
        }
        //print(particles);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;

    draw();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  // MARK: Drawing
  void draw() {
    //print("making a $type");
    drawType(type);
  }

  void drawType(ShapeType type) {
    if (this.running == false) {
      print("stopping...");
      return;
    }

    // DEBUG ONLY
    // this.painter = Paint()
    //   ..color = randomColor(1)
    //   ..style = PaintingStyle.fill;

    if (this.hasBase == true) {
      switch (type) {
        case ShapeType.Circle:
          drawCircle(null, this.radius, painter);
          break;
        case ShapeType.Rect:
          drawRect(center, painter);
          break;
        case ShapeType.RoundedRect:
          drawRRect(center, painter);
          break;
        case ShapeType.Triangle:
          drawPolygon(center, 3, painter, initialAngle: 30);
          break;
        case ShapeType.Diamond:
          drawPolygon(center, 4, painter, initialAngle: 0);
          break;
        case ShapeType.Pentagon:
          drawPolygon(center, 5, painter, initialAngle: -18);
          break;
        case ShapeType.Hexagon:
          drawPolygon(center, 6, painter, initialAngle: 0);
          break;
        case ShapeType.Octagon:
          drawPolygon(center, 8, painter, initialAngle: 0);
          break;
        case ShapeType.Decagon:
          drawPolygon(center, 10, painter, initialAngle: 0);
          break;
        case ShapeType.Dodecagon:
          drawPolygon(center, 12, painter, initialAngle: 0);
          break;
        case ShapeType.Heart:
          drawHeart(center, painter);
          break;
        case ShapeType.Star5:
          drawStar(center, 10, painter, initialAngle: 15);
          break;
        case ShapeType.Star6:
          drawStar(center, 12, painter, initialAngle: 0);
          break;
        case ShapeType.Star7:
          drawStar(center, 14, painter, initialAngle: 0);
          break;
        case ShapeType.Star8:
          drawStar(center, 16, painter, initialAngle: 0);
          break;
      }
    }

    /// MAKING FIRE PARTICLES
    if (this.particleType == ParticleType.FIRE) {
      // initialize particles if needed
      if (particles.length == 0) {
        for (var i = 0; i < (minParticles / 2).floor(); i++) {
          double speed = this.spreadBehaviour == SpreadBehaviour.ONE_TIME ? 0.1 : randomDelay(min: 0.01, max: 0.09);
          double rand = this.radius * 0.1;
          double randX = this.particleType == ParticleType.EXPLODE ? 0 : randomX();
          double _radius = randomizeRadius();
          Map<String, double> endPath = randomPointOnRadius();
          Paint _painter = this.painter;
          if (this.endAnimation == EndAnimation.FADE_OUT) {
            _painter = Paint()
              ..color = this.color
              ..blendMode = this.blendMode
              ..style = PaintingStyle.fill;
          }
          particles.add(new Particle(x: randX, y: -rand, radius: _radius, speed: speed, endPath: endPath, timeAlive: DateTime.now().millisecondsSinceEpoch, currentTime: this.currentTime, renderDelay: 0, opacity: 1.0, painter: _painter));

          //{"x": randX, "y": -rand, "radius": _radius, "speed": speed, "endPath": endPath, "timeAlive": DateTime.now().millisecondsSinceEpoch});
        }
        //print(particles);
      }

      if (particles.length > 0 && particles.length < minParticles) {
        // add more
        for (var i = 0; i < (minParticles - particles.length); i++) {
          double speed = this.spreadBehaviour == SpreadBehaviour.ONE_TIME ? randomDelay(min: this.minimumSpeed, max: this.maximumSpeed) : randomDelay();
          double rand = 0;
          double randX = randomX();
          double _radius = randomizeRadius();
          Map<String, double> endPath = randomPointOnRadius();
          Paint _painter = this.painter;
          if (this.endAnimation == EndAnimation.FADE_OUT) {
            _painter = Paint()
              ..color = this.color
              ..blendMode = this.blendMode
              ..style = PaintingStyle.fill;
          }
          particles.add(Particle(x: randX, y: -rand, radius: _radius, speed: speed, endPath: endPath, timeAlive: DateTime.now().millisecondsSinceEpoch, currentTime: this.currentTime, renderDelay: 0, opacity: 1.0, painter: _painter));

          //{"x": randX, "y": -rand, "radius": _radius, "speed": speed, "timeAlive": DateTime.now().millisecondsSinceEpoch});
        }
      }

      List<Particle> tempArr = [];
      for (var i = 0; i < particles.length; i++) {
        if ((particles[i].getY()) < (maxDistance * -1)) {
          //print("removing $i");
          particles.removeAt(i);
        } else if ((this.currentTime - particles[i].getTimeAlive().toInt()).abs() > doubleInRange(this.timeToLive["min"]!.toDouble(), this.timeToLive["max"]!.toDouble())) {
          //print("REMOVING $i");
          if (this.endAnimation == EndAnimation.INSTANT) {
            //print("instant remove of $i");
            particles.removeAt(i);
          } else if (this.endAnimation == EndAnimation.SCALE_DOWN) {
            if (particles[i].getRadius() < 0.01) {
              //print("PARTICLE RADIUS ${particles[i]["radius"]}");
              particles.removeAt(i);
            } else {
              particles[i].radius -= 0.25;
              tempArr.add(particles[i]);
            }
          }
        } else {
          tempArr.add(particles[i]);
        }
      }

      particles.clear();
      particles = tempArr;

      for (var j = 0; j < particles.length; j++) {
        double rand = particles[j].getY() - (maxDistance * particles[j].getSpeed()).toDouble();

        particles[j].x = particles[j].getX();
        particles[j].y = rand.abs() * -1;
        drawCircle(Offset(particles[j].getX().toDouble(), rand), particles[j].getRadius(), painter);
      }
    }

    /// Explode particles
    else if (this.particleType == ParticleType.EXPLODE && this.spreadBehaviour == SpreadBehaviour.ONE_TIME) {
      if (particles.length == 0) {
        stop();
      }

      List<Particle> tempArr = [];
      for (var i = 0; i < particles.length; i++) {
        if ((particles[i].getY()) < (maxDistance * -1)) {
          particles.removeAt(i);
        } else if ((this.currentTime - particles[i].getTimeAlive().toInt()).abs() > doubleInRange(this.timeToLive["min"]!.toDouble(), this.timeToLive["max"]!.toDouble())) {
          //print("REMOVING $i");
          if (this.endAnimation == EndAnimation.INSTANT) {
            print("instant remove of $i");
            particles.removeAt(i);
          } else if (this.endAnimation == EndAnimation.SCALE_DOWN) {
            if (particles[i].getRadius() < 0.01) {
              print("PARTICLE RADIUS ${particles[i].getRadius()}");
              particles.removeAt(i);
            } else {
              particles[i].radius -= 0.25;
              tempArr.add(particles[i]);
            }
          }
        } else {
          tempArr.add(particles[i]);
        }
      }

      particles.clear();
      particles = tempArr;

      for (var j = 0; j < particles.length; j++) {
        double randX = particles[j].getX().abs() + (particles[j].getEndPath()!["x"]!.abs() * particles[j].getSpeed()).toDouble();
        double randY = particles[j].getY().abs() + (particles[j].getEndPath()!["y"]!.abs() * particles[j].getSpeed()).toDouble();
        int signX = particles[j].getEndPath()!["x"]! < 0 ? -1 : 1;
        int signY = particles[j].getEndPath()!["y"]! < 0 ? -1 : 1;
        //print("$signX, $signY");
        particles[j].x = randX * signX;
        particles[j].y = (randY * signY);
        particles[j].timeAlive = DateTime.now().millisecondsSinceEpoch;

        drawShape(this.type, particles[j].getRadius(), Offset(particles[j].getX().toDouble(), particles[j].getY().toDouble()));
      }
    } else if (this.particleType == ParticleType.EXPLODE && this.spreadBehaviour == SpreadBehaviour.CONTINUOUS) {
      drawContinuousExplode();
    } else if (this.particleType == ParticleType.FOUNTAIN && this.spreadBehaviour == SpreadBehaviour.CONTINUOUS) {
      drawFountainMode();
    }
  }

  /// Continuous explode
  void drawContinuousExplode() {
    //print("continuous explode ${particles.length} $minParticles");

    if (particles.length < minParticles) {
      // add more
      for (var i = 0; i < (minParticles - particles.length); i++) {
        double speed = randomDelay(min: this.minimumSpeed, max: this.maximumSpeed);
        double rand = 0;
        double randX = this.particleType == ParticleType.EXPLODE ? 0 : randomX();
        double _radius = randomizeRadius();
        Map<String, double> endPath = randomPointOnRadius();
        Paint _painter = this.painter;
        if (this.endAnimation == EndAnimation.FADE_OUT) {
          _painter = Paint()
            ..color = this.color
            ..blendMode = this.blendMode
            ..style = PaintingStyle.fill;
        }

        particles
            .add(new Particle(x: randX, y: -rand, radius: _radius, speed: speed, endPath: endPath, timeAlive: DateTime.now().millisecondsSinceEpoch, currentTime: this.currentTime + 100 * i, renderDelay: 0, opacity: 1.0, painter: _painter));
        //{"x": randX, "y": -rand, "radius": _radius, "speed": speed, "endPath": endPath, "timeAlive": DateTime.now().millisecondsSinceEpoch, "current": DateTime.now().millisecondsSinceEpoch + 100 * i, "renderDelay": 0, "opacity": 1.0});
      }
    }

    List<Particle> tempArr = [];
    for (var i = 0; i < particles.length; i++) {
      //print("Time alive: ${(this.currentTime - particles[i]['timeAlive'].toInt()).abs()} - ${this.timeToLive}");
      if ((particles[i].getCurrentTime() - particles[i].getTimeAlive().toInt()).abs() > doubleInRange(this.timeToLive["min"]!.toDouble(), this.timeToLive["max"]!.toDouble())) {
        //print("REMOVING $i");
        if (this.endAnimation == EndAnimation.INSTANT) {
          print("remove $i ${particles.length}");
          particles.removeAt(i);
        } else if (this.endAnimation == EndAnimation.SCALE_DOWN) {
          if (particles[i].getRadius() < 0.01) {
            // print("PARTICLE RADIUS ${particles[i]["radius"]}");
            particles.removeAt(i);
          } else {
            particles[i].radius -= 0.25;
            tempArr.add(particles[i]);
          }
        } else if (this.endAnimation == EndAnimation.FADE_OUT) {
          particles[i].opacity -= 0.05;
          if (particles[i].opacity < 0) {
            particles.removeAt(i);
          } else {
            tempArr.add(particles[i]);
          }
        }
      } else {
        tempArr.add(particles[i]);
      }
    }

    //particles.clear();
    particles = tempArr;

    for (var j = 0; j < particles.length; j++) {
      if (particles[j].getRenderDelay() <= 0) {
        double randX = particles[j].getX().abs() + (particles[j].getEndPath()!["x"]!.abs() * particles[j].getSpeed()).toDouble();
        double randY = particles[j].getY().abs() + (particles[j].getEndPath()!["y"]!.abs() * particles[j].getSpeed()).toDouble();
        int signX = particles[j].getEndPath()!["x"]! < 0 ? -1 : 1;
        int signY = particles[j].getEndPath()!["y"]! < 0 ? -1 : 1;

        particles[j].x = randX * signX;
        particles[j].y = (randY * signY);
        particles[j].timeAlive = DateTime.now().millisecondsSinceEpoch;
        if (this.endAnimation == EndAnimation.FADE_OUT) {
          int opacity = (particles[j].getOpacity() * 255).floor();

          this.painter = Paint()
            ..color = this.color.withAlpha(opacity)
            ..blendMode = this.blendMode
            ..style = PaintingStyle.fill;
        }
        drawShape(this.type, particles[j].getRadius(), Offset(particles[j].getX().toDouble(), particles[j].getY().toDouble()));
      } else {
        particles[j].renderDelay -= doubleInRange(0.01, 0.1);
      }
    }
  }

  /// fountain mode
  void drawFountainMode() {
    // this.vx = Math.random() * 20 - 10;
    // this.vy = Math.random() * 20 - 20;
    // add more
    for (var i = 0; i < (minParticles - particles.length); i++) {
      double speed = randomDelay(min: this.minimumSpeed, max: this.maximumSpeed);
      double rand = 0;
      double randX = this.particleType == ParticleType.EXPLODE ? 0 : randomX();
      double _radius = randomizeRadius();
      Map<String, double> endPath = {"x": _random.nextDouble() * 20 - 10, "y": _random.nextDouble() * 20 - 20};
      Paint _painter = this.painter;
      if (this.endAnimation == EndAnimation.FADE_OUT) {
        _painter = Paint()
          ..color = this.color
          ..blendMode = this.blendMode
          ..style = PaintingStyle.fill;
      }

      particles.add(new Particle(
          x: randX,
          y: -rand,
          radius: _radius,
          speed: speed,
          endPath: endPath,
          timeAlive: DateTime.now().millisecondsSinceEpoch,
          currentTime: DateTime.now().millisecondsSinceEpoch + 100 * i,
          renderDelay: 0,
          opacity: 1.0,
          painter: _painter));
    }

    List<Particle> tempArr = [];
    for (var i = 0; i < particles.length; i++) {
      if ((particles[i].getCurrentTime() - particles[i].getTimeAlive().toInt()).abs() > doubleInRange(this.timeToLive["min"]!.toDouble(), this.timeToLive["max"]!.toDouble())) {
        //print("REMOVING $i");
        if (this.endAnimation == EndAnimation.INSTANT) {
          print("remove $i ${particles.length}");
          particles.removeAt(i);
        } else if (this.endAnimation == EndAnimation.SCALE_DOWN) {
          if (particles[i].getRadius() < 0.01) {
            // print("PARTICLE RADIUS ${particles[i]["radius"]}");
            particles.removeAt(i);
          } else {
            particles[i].radius -= 0.25;
            tempArr.add(particles[i]);
          }
        } else if (this.endAnimation == EndAnimation.FADE_OUT) {
          particles[i].opacity -= 0.05;
          if (particles[i].opacity < 0) {
            particles.removeAt(i);
          } else {
            tempArr.add(particles[i]);
          }
        }
      } else {
        tempArr.add(particles[i]);
      }
    }

    //particles.clear();
    particles = tempArr;

    for (var j = 0; j < particles.length; j++) {
      if (particles[j].getRenderDelay() <= 0) {
        double randX = particles[j].getX().abs() + (particles[j].getEndPath()!["x"]!.abs() * particles[j].getSpeed()).toDouble();
        double randY = particles[j].getY().abs() + (particles[j].getEndPath()!["y"]!.abs() * particles[j].getSpeed()).toDouble();
        // add gravity
        particles[j].getEndPath()!["y"] = particles[j].getEndPath()!["y"]!.abs() + this.gravity;
        int signX = particles[j].getEndPath()!["x"]! < 0 ? -1 : 1;
        int signY = particles[j].getEndPath()!["y"]! < 0 ? -1 : 1;

        particles[j].x = (randX * signX);
        particles[j].y = (randY * signY);
        particles[j].timeAlive = DateTime.now().millisecondsSinceEpoch;
        if (this.endAnimation == EndAnimation.FADE_OUT) {
          int opacity = (particles[j].getOpacity() * 255).floor();

          this.painter = Paint()
            ..color = this.color.withAlpha(opacity)
            ..blendMode = this.blendMode
            ..style = PaintingStyle.fill;
        }
        drawShape(this.type, particles[j].getRadius(), Offset(particles[j].getX().toDouble(), particles[j].getY().toDouble()));
      } else {
        particles[j].renderDelay -= doubleInRange(0.01, 0.1);
      }
    }
  }

  void drawShape(ShapeType type, double radius, Offset offset) {
    switch (type) {
      case ShapeType.Circle:
        drawCircle(offset, radius, painter);
        break;
      case ShapeType.Rect:
        drawRect(offset, painter);
        break;
      case ShapeType.RoundedRect:
        drawRRect(offset, painter);
        break;
      case ShapeType.Triangle:
        drawPolygon(offset, 3, painter, initialAngle: 30);
        break;
      case ShapeType.Diamond:
        drawPolygon(offset, 4, painter, initialAngle: 0);
        break;
      case ShapeType.Pentagon:
        drawPolygon(offset, 5, painter, initialAngle: -18);
        break;
      case ShapeType.Hexagon:
        drawPolygon(offset, 6, painter, initialAngle: 0);
        break;
      case ShapeType.Octagon:
        drawPolygon(offset, 8, painter, initialAngle: 0);
        break;
      case ShapeType.Decagon:
        drawPolygon(offset, 10, painter, initialAngle: 0);
        break;
      case ShapeType.Dodecagon:
        drawPolygon(offset, 12, painter, initialAngle: 0);
        break;
      case ShapeType.Heart:
        drawHeart(offset, painter);
        break;
      case ShapeType.Star5:
        drawStar(offset, 10, painter, initialAngle: 15);
        break;
      case ShapeType.Star6:
        drawStar(offset, 12, painter, initialAngle: 0);
        break;
      case ShapeType.Star7:
        drawStar(offset, 14, painter, initialAngle: 0);
        break;
      case ShapeType.Star8:
        drawStar(offset, 16, painter, initialAngle: 0);
        break;
    }
  }

  /// HELPER FUNCTIONS ///
  void stop() {
    //stopping particles
    this.running = false;
    this.controller.stop(canceled: true);
  }

  double randomDelay({double min = 0.005, double max = 0.05}) {
    if (min == max) {
      return min;
    } else {
      return doubleInRange(min, max);
    }
  }

  Map<String, double> randomPointOnRadius() {
    double angle = _random.nextDouble() * pi * 2;
    double x = cos(angle) * radius;
    double y = sin(angle) * radius;

    return {"x": x, "y": y};
  }

  double doubleInRange(double start, double end) {
    if (start == end) {
      return start;
    } else {
      return _random.nextDouble() * (end - start) + start;
    }
  }

  double randomX() {
    double _rnd = _random.nextDouble();
    bool sign = _random.nextBool();
    return sign == true ? (_rnd * this.radius) * -1 : (_rnd * this.radius);
  }

  double randomY() {
    double _rnd = _random.nextDouble();
    bool sign = _random.nextBool();
    return sign == true ? (_rnd * this.radius) * -1 : (_rnd * this.radius);
  }

  Color randomColor(double alpha) {
    int r = (_random.nextDouble() * 255).floor();
    int g = (_random.nextDouble() * 255).floor();
    int b = (_random.nextDouble() * 255).floor();
    int a = (alpha * 255).floor();

    return Color.fromARGB(a, r, g, b);
  }

  double randomizeRadius() {
    double rnd = doubleInRange(0.1, 0.25);

    return rnd * particleSize.width;
  }

  void changeColor(Color color) {}

  void drawCircle(Offset? offset, double r, Paint paint) {
    Offset _offset = offset ?? Offset.zero;
    //rotate(() {
    canvas!.drawCircle(_offset, r, paint);
    //});
  }

  void drawRect(Offset offset, Paint paint) {
    rotate(offset.dx, offset.dy, () {
      canvas!.drawRect(rect(), paint);
    });
  }

  void drawRRect(Offset offset, Paint paint, {double? cornerRadius}) {
    rotate(offset.dx, offset.dy, () {
      canvas!.drawRRect(RRect.fromRectAndRadius(rect(), Radius.circular(cornerRadius ?? radius * 0.2)), paint);
    });
  }

  void drawPolygon(Offset offset, int num, Paint paint, {double initialAngle = 0}) {
    rotate(offset.dx, offset.dy, () {
      final Path path = Path();
      for (int i = 0; i < num; i++) {
        final double radian = vectorMath.radians(initialAngle + 360 / num * i.toDouble());
        final double x = radius * cos(radian);
        final double y = radius * sin(radian);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas!.drawPath(path, paint);
    });
  }

  void drawHeart(Offset offset, Paint paint) {
    rotate(offset.dx, offset.dy, () {
      final Path path = Path();

      path.moveTo(0, radius);

      path.cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0, -radius * 0.5);
      path.cubicTo(radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);

      canvas!.drawPath(path, paint);
    });
  }

  void drawStar(Offset offset, int num, Paint paint, {double initialAngle = 0}) {
    rotate(offset.dx, offset.dy, () {
      final Path path = Path();
      for (int i = 0; i < num; i++) {
        final double radian = vectorMath.radians(initialAngle + 360 / num * i.toDouble());
        final double x = radius * (i.isEven ? 0.5 : 1) * cos(radian);
        final double y = radius * (i.isEven ? 0.5 : 1) * sin(radian);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas!.drawPath(path, paint);
    });
  }

  Rect rect() => Rect.fromCircle(center: Offset.zero, radius: radius);

  void rotate(double? x, double? y, VoidCallback callback) {
    double _x = x ?? center.dx;
    double _y = y ?? center.dy;
    canvas!.save();
    canvas!.translate(_x, _y);

    if (angle! > 0) {
      canvas!.rotate(angle!);
    }
    callback();
    canvas!.restore();
  }
}
