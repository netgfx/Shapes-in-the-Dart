import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/LetterParticle.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'dart:ui' as ui;
import 'alphabet_paths.dart';
import 'number_paths.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;

enum CharacterParticleEffect {
  NONE,
  JITTER,
  SPREAD,
  FADEIN,
  TREX,
}
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

class LetterParticles extends CustomPainter {
  List<Point<double>> points = [];
  String character;
  Color color = Colors.black;
  double radius = 20.0;
  AnimationController? controller;
  Canvas? canvas;
  double angle = 0;
  int delay = 500;
  int currentTime = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  ShapeType type = ShapeType.Circle;
  int timeDecay = 0;
  double? rate = 10;
  double endT = 0.0;
  final _random = new Random();
  int timeAlive = 0;
  int timeToLive = 24;
  CharacterParticleEffect effect = CharacterParticleEffect.NONE;
  bool? stagger = false;
  List<LetterParticle> particles = [];
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;
  Easing ease = Easing.LINEAR;

  /// Constructor
  LetterParticles({
    /// <-- The type character to display
    required this.character,

    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,

    /// <-- Color of the particles
    required this.color,

    /// <-- Radius of the particles (if circle)
    required this.radius,

    /// <-- Type of particle shape (circle, rectangle, etc...)
    required this.type,

    /// <-- The desired animation
    required this.effect,

    /// <-- The delay until the animation starts
    required this.delay,

    /// <-- The animation easing function
    required this.ease,

    /// <-- If the animation contains stagger
    this.stagger,

    /// <-- The rate at which the ticker runs
    this.rate,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,

    /// <-- Custom callback to call after Delay has passed
    this.animate,
  }) : super(repaint: controller) {
    /// safeguard as we only support capital letters for now
    this.character = this.character.toUpperCase();

    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();

    /// default painter
    Paint fill = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;

    /// a temp list of points
    List<double>? points = [];

    if (int.tryParse(this.character) == null) {
      points = alphabetPaths[this.character];
    } else {
      points = numberPaths[this.character];
    }

    /// here we need to calculate the diff of each letter based on its position
    /// versus the initial position
    double maxX = 0;
    double minX = 10000;
    double maxY = 0;
    double minY = 10000;
    for (var i = 0; i < points!.length; i += 2) {
      /// find the min

      if (points[i] < minX) {
        minX = points[i];
      }

      if (points[i + 1] < minY) {
        minY = points[i + 1];
      }
    }

    /// calculate the offset position and assign to `ParticleLetter`
    for (var i = 0; i < points.length; i += 2) {
      double offsetX = minX - 4;
      double offsetY = minY - 3;

      double finalX = points[i] - offsetX;
      double finalY = points[i + 1] - offsetY;
      if (finalX < 0) {
        finalX = 0;
      }
      if (finalY < 0) {
        finalY = 0;
      }
      double randX = 0;
      double randY = 0;
      if (this.effect == CharacterParticleEffect.SPREAD) {
        randX = doubleInRange(-200, 200);
        randY = doubleInRange(-200, 200);
      } else if (this.effect == CharacterParticleEffect.FADEIN) {
        fill = Paint()
          ..color = this.color.withAlpha(0)
          //..blendMode = this.blendMode ?? ui.BlendMode.src
          ..style = PaintingStyle.fill;
      }

      particles.add(
        LetterParticle(
            color: this.color,
            x: randX,
            y: randY,
            renderDelay: randomDelay(min: 500 + 50 * i.toDouble(), max: 1000 + 50 * i.toDouble()),
            opacity: 1.0,
            radius: this.radius,
            timeToLive: this.timeToLive.toDouble(),
            progress: 0.0,
            painter: fill,
            timeAlive: 0,
            currentTime: 0,
            endPath: Point(finalX, finalY)),
      );
    }

    /// fire the animate after a delay
    if (this.delay > 0 && this.animate != null) {
      Future.delayed(Duration(milliseconds: this.delay), () => {this.animate!()});
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    paintImage(canvas, size);
  }

  void paintImage(Canvas canvas, Size size) async {
    draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void draw(Canvas canvas, Size size) {
    /// check if the controller is running
    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        /// in order to run in our required frames per second
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay && this.timeAlive == 0) {
          /// reset the time
          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;

          /// only for stagger, we add a manual delay
          if (this.stagger == true) {
            for (var i = 0; i < particles.length; i++) {
              if (particles[i].renderDelay > 0) {
                if (this.controller!.lastElapsedDuration!.inMilliseconds > particles[i].renderDelay) {
                  /// particle individual time progress (0 - 1)
                  particles[i].progress += this.rate ?? 10 / 1000;

                  if (particles[i].progress >= 1.0) {
                    particles[i].progress = 1.0;
                  }
                }
              }
            }
          }

          /// manual ticker
          endT += this.rate ?? 0.009;
          if (endT >= 1.0) {
            endT = 1.0;
          }

          renderLetter(particles);
        } else if (this.timeAlive > 0) {
          this.currentTime = DateTime.now().millisecondsSinceEpoch;

          renderLetter(particles);
        } else {
          renderLetter(particles);
        }
      } else {
        print("re-rendering points with no changes");
        renderLetter(particles);
      }
    } else {
      print("no controller");
      renderLetter(particles);
    }
  }

  /// Render the letter particles
  void renderLetter(List<LetterParticle>? points) {
    if (points != null) {
      ///

      for (var i = 0; i < points.length; i++) {
        double finalX = points[i].getEndPath().x.toDouble();
        double finalY = points[i].getEndPath().y.toDouble();
        if (this.effect == CharacterParticleEffect.TREX) {
          double randX = doubleInRange(finalX - 1.5, finalX + 1.5);
          double randY = doubleInRange(finalY - 1.5, finalY + 1.5);
          finalX = ui.lerpDouble(randX, finalX, this.controller!.value)!;
          finalY = ui.lerpDouble(randY, finalY, this.controller!.value)!;
        } else if (this.effect == CharacterParticleEffect.JITTER) {
          double randX = doubleInRange(finalX - 1.5, finalX + 1.5);
          double randY = doubleInRange(finalY - 1.5, finalY + 1.5);

          finalX = doubleInRange(randX, finalX);
          finalY = doubleInRange(randY, finalY);
        } else if (this.effect == CharacterParticleEffect.SPREAD) {
          if (this.stagger == true) {
            double easeResult = getStagger(particles[i].progress);
            finalX = ui.lerpDouble(points[i].getX(), finalX, easeResult)!;
            finalY = ui.lerpDouble(points[i].getY(), finalY, easeResult)!;
          } else {
            finalX = ui.lerpDouble(points[i].getX(), finalX, this.controller!.value)!;
            finalY = ui.lerpDouble(points[i].getY(), finalY, this.controller!.value)!;
          }
        } else if (this.effect == CharacterParticleEffect.FADEIN) {
          int newAlpha = 255;
          if (this.stagger == true) {
            double easeResult = getStagger(particles[i].progress);
            newAlpha = ui.lerpDouble(0, 255, easeResult)!.round();
          } else {
            newAlpha = ui.lerpDouble(0, 255, this.controller!.value)!.round();
          }
          points[i].painter = Paint()
            ..color = this.color.withAlpha(newAlpha)
            //..blendMode = this.blendMode ?? ui.BlendMode.src
            ..style = PaintingStyle.fill;
        }

        drawType(finalX, finalY, this.type, points[i].painter!);
      }
    }
  }

  double getStagger(double progress) {
    /// linear
    double easeResult = progress;

    /// easings
    switch (this.ease) {
      case Easing.EASE_OUT_SINE:
        {
          easeResult = easeOutSine(progress);
        }
        break;

      case Easing.EASE_OUT_QUART:
        {
          easeResult = easeOutQuart(progress);
        }
        break;
      case Easing.EASE_OUT_QUAD:
        {
          easeResult = easeOutQuad(progress);
        }
        break;
      case Easing.EASE_OUT_CUBIC:
        {
          easeResult = easeOutCubic(progress);
        }
        break;
      case Easing.EASE_OUT_CIRC:
        {
          easeResult = easeOutCirc(progress);
        }
        break;
      case Easing.EASE_OUT_BACK:
        {
          easeResult = easeOutBack(progress);
        }
        break;
      case Easing.EASE_IN_OUT_BACK:
        {
          easeResult = easeInOutBack(progress);
        }
        break;
      default:
        {
          easeResult = progress;
        }
        break;
    }

    return easeResult;
  }

  int getSign() {
    return _random.nextBool() == false ? 1 : -1;
  }

  /// Draw the particle shape
  void drawType(double x, double y, ShapeType type, Paint painter) {
    switch (type) {
      case ShapeType.Circle:
        drawCircle(x, y, painter);
        break;
      case ShapeType.Rect:
        drawRect(x, y, painter);
        break;
      case ShapeType.RoundedRect:
        drawRRect(x, y, painter);
        break;
      case ShapeType.Triangle:
        drawPolygon(x, y, 3, painter, initialAngle: 30);
        break;
      case ShapeType.Diamond:
        drawPolygon(x, y, 4, painter, initialAngle: 0);
        break;
      case ShapeType.Pentagon:
        drawPolygon(x, y, 5, painter, initialAngle: -18);
        break;
      case ShapeType.Hexagon:
        drawPolygon(x, y, 6, painter, initialAngle: 0);
        break;
      case ShapeType.Octagon:
        drawPolygon(x, y, 8, painter, initialAngle: 0);
        break;
      case ShapeType.Decagon:
        drawPolygon(x, y, 10, painter, initialAngle: 0);
        break;
      case ShapeType.Dodecagon:
        drawPolygon(x, y, 12, painter, initialAngle: 0);
        break;
      case ShapeType.Heart:
        drawHeart(x, y, painter);
        break;
      case ShapeType.Star5:
        drawStar(x, y, 10, painter, initialAngle: 15);
        break;
      case ShapeType.Star6:
        drawStar(x, y, 12, painter, initialAngle: 0);
        break;
      case ShapeType.Star7:
        drawStar(x, y, 14, painter, initialAngle: 0);
        break;
      case ShapeType.Star8:
        drawStar(x, y, 16, painter, initialAngle: 0);
        break;
    }
  }

  void drawCircle(double x, double y, Paint paint) {
    rotate(0, 0, () {
      canvas!.drawCircle(Offset(x, y), this.radius, paint);
    });
  }

  void drawRect(double x, double y, Paint paint) {
    rotate(x, y, () {
      canvas!.drawRect(rect(), paint);
    });
  }

  void drawRRect(double x, double y, Paint paint, {double? cornerRadius}) {
    rotate(x, y, () {
      canvas!.drawRRect(RRect.fromRectAndRadius(rect(), Radius.circular(cornerRadius ?? radius * 0.2)), paint);
    });
  }

  void drawPolygon(double x, double y, int num, Paint paint, {double initialAngle = 0}) {
    rotate(x, y, () {
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

  void drawHeart(double x, double y, Paint paint) {
    rotate(x, y, () {
      final Path path = Path();

      path.moveTo(0, radius);

      path.cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0, -radius * 0.5);
      path.cubicTo(radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);

      canvas!.drawPath(path, paint);
    });
  }

  void drawStar(double x, double y, int num, Paint paint, {double initialAngle = 0}) {
    rotate(x, y, () {
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

  double doubleInRange(double start, double end) {
    if (start == end) {
      return start;
    } else {
      return _random.nextDouble() * (end - start) + start;
    }
  }

  double randomDelay({double min = 0.005, double max = 0.05}) {
    if (min == max) {
      return min;
    } else {
      return doubleInRange(min, max);
    }
  }

  double easeOutBack(double x) {
    const c1 = 1.70158;
    const c3 = c1 + 1;

    return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2);
  }

  double easeOutCirc(double x) {
    return sqrt(1 - pow(x - 1, 2));
  }

  double easeOutQuart(double x) {
    return 1 - pow(1 - x, 4).toDouble();
  }

  double easeOutQuad(double x) {
    return 1 - (1 - x) * (1 - x);
  }

  double easeOutCubic(double x) {
    return 1 - pow(1 - x, 3).toDouble();
  }

  double easeOutSine(double x) {
    return sin((x * pi) / 2);
  }

  double easeOutQuint(double x) {
    return 1 - pow(1 - x, 5).toDouble();
  }

  double easeInOutBack(double x) {
    const c1 = 1.70158;
    const c2 = c1 * 1.525;

    return x < 0.5 ? (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2 : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
  }

  void delayedPrint(String str) {
    if (DateTime.now().millisecondsSinceEpoch - this.printTime > 100) {
      this.printTime = DateTime.now().millisecondsSinceEpoch;
      print(str);
    }
  }

  void rotate(double? x, double? y, VoidCallback callback) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    var scale = 1.0;
    canvas!.save();
    canvas!.translate(_x, _y);

    if (scale != 1.0) {
      //canvas!.translate(this.p0.x + _x, this.p0.y + _y);
      var matrix = Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)..scale(scale);
      //..translate(this.p0.x - _x, this.p0.y - _y);
      canvas!.transform(matrix.storage);
      //canvas!.scale(scale);
    }

    //canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
