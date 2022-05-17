import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/LetterParticle.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/Star.dart';
import 'dart:ui' as ui;
import '../game_classes/alphabet_paths.dart';
import '../game_classes/number_paths.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;

class Line {
  Point start = Point(0, 0);
  Point end = Point(0, 0);
  Line(this.start, this.end) {}

  Point getStart() {
    return this.start;
  }

  Point getEnd() {
    return this.end;
  }
}

class Shadows extends CustomPainter {
  Color color = Colors.black;
  List<Star> stars = [];
  AnimationController? controller;
  Canvas? canvas;
  double radius = 100.0;
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
  int zDecay = 1000;
  List<Point> walls = [];
  BoxConstraints sceneSize = BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;
  Paint? painter;
  Paint? wallPaint;
  Paint? paintStroke;
  List<Point> stageCorners = [];
  Point light = Point(0, 0);

  /// Constructor
  Shadows({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,

    /// <-- Color of the particles
    required this.color,

    /// <-- Type of particle shape (circle, rectangle, etc...)
    required this.type,

    /// <-- The rate at which the ticker runs
    this.rate,
    required this.light,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,

    /// <-- Custom callback to call after Delay has passed
    this.animate,

    ///
    required this.sceneSize,
  }) : super(repaint: controller) {
    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();

    /// default painter

    painter = Paint()
      ..color = Colors.white
      ..blendMode = ui.BlendMode.overlay
      ..style = PaintingStyle.fill;

    paintStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    var NUMBER_OF_WALLS = 4;
    this.walls = [];
    var i, x, y;
    wallPaint = Paint()
      ..color = Colors.white
      //..blendMode = ui.BlendMode.multiply
      ..style = PaintingStyle.fill;
    for (i = 0; i < NUMBER_OF_WALLS; i++) {
      x = i * this.sceneSize.maxWidth / NUMBER_OF_WALLS + 40;
      y = 100 + i * 50;
      y = y < 40 ? 40 : y;

      this.walls.add(Point(x, y));
      //
    }

    stageCorners = [
      Point(0, 0),
      Point(this.sceneSize.maxWidth, 0),
      Point(this.sceneSize.maxWidth, this.sceneSize.maxHeight),
      Point(0, this.sceneSize.maxHeight)
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    var paint = Paint()
      ..color = Colors.black54
      ..blendMode = ui.BlendMode.multiply
      ..style = PaintingStyle.fill;
    drawRect(0, -50, null, null, paint);
    //canvas.drawColor(Colors.black54, BlendMode.multiply);
    paintImage(canvas, size);

    drawCircle(this.light.x.toDouble(), this.light.y.toDouble(), this.wallPaint!);

    /// walls
    this.drawWalls();
  }

  void paintImage(Canvas canvas, Size size) async {
    draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void draw(Canvas canvas, Size size) {
    double cx = this.sceneSize.maxWidth / 2;
    double cy = this.sceneSize.maxHeight / 2;

    /// check if the controller is running
    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        /// in order to run in our required frames per second
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay && this.timeAlive == 0) {
          /// reset the time

          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;

          this.performRayCasting();
        } else {
          this.performRayCasting();
        }
      }
    } else {
      print("re-rendering points with no changes");

      this.performRayCasting();
    }
  }

  int getSign() {
    return _random.nextBool() == false ? 1 : -1;
  }

  void performRayCasting() {
    List<Point<num>> points = [];

    Point wall;
    int wallWidth = 40;
    int wallHeight = 40;
    Line? ray = null;
    Point? intersect;
    List<Point> corners = [];
    for (var i = 0; i < this.walls.length; i++) {
      wall = this.walls[i];

      corners = [
        Point(wall.x + 0.1, wall.y + 0.1),
        Point(wall.x - 0.1, wall.y - 0.1),
        Point(wall.x - 0.1 + wallWidth, wall.y + 0.1),
        Point(wall.x + 0.1 + wallWidth, wall.y - 0.1),
        Point(wall.x - 0.1 + wallWidth, wall.y - 0.1 + wallHeight),
        Point(wall.x + 0.1 + wallWidth, wall.y + 0.1 + wallHeight),
        Point(wall.x + 0.1, wall.y - 0.1 + wallHeight),
        Point(wall.x - 0.1, wall.y + 0.1 + wallHeight)
      ];

      //delayedPrint(corners.toString());

      // Calculate rays through each point to the edge of the stage
      for (var i = 0; i < corners.length; i++) {
        var c = corners[i];

        // Here comes the linear algebra.
        // The equation for a line is y = slope * x + b
        // b is where the line crosses the left edge of the stage
        var slope = (c.y - this.light.y) / (c.x - this.light.x);
        var b = this.light.y - slope * this.light.x;

        Point? end = null;

        if (c.x == this.light.x) {
          // Vertical lines are a special case
          if (c.y <= this.light.y) {
            end = Point(this.light.x, 0);
          } else {
            end = Point(this.light.x, this.sceneSize.maxHeight);
          }
        } else if (c.y == this.light.y) {
          // Horizontal lines are a special case
          if (c.x <= this.light.x) {
            end = Point(0, this.light.y);
          } else {
            end = new Point(this.sceneSize.maxWidth, this.light.y);
          }
        } else {
          // Find the point where the line crosses the stage edge
          var left = Point(0, b);
          var right = Point(this.sceneSize.maxWidth, slope * this.sceneSize.maxWidth + b);
          var top = Point(-b / slope, 0);
          var bottom = Point((this.sceneSize.maxHeight - b) / slope, this.sceneSize.maxHeight);

          // Get the actual intersection point
          if (c.y <= this.light.y && c.x >= this.light.x) {
            if (top.x >= 0 && top.x <= this.sceneSize.maxWidth) {
              end = top;
            } else {
              end = right;
            }
          } else if (c.y <= this.light.y && c.x <= this.light.x) {
            if (top.x >= 0 && top.x <= this.sceneSize.maxWidth) {
              end = top;
            } else {
              end = left;
            }
          } else if (c.y >= this.light.y && c.x >= this.light.x) {
            if (bottom.x >= 0 && bottom.x <= this.sceneSize.maxWidth) {
              end = bottom;
            } else {
              end = right;
            }
          } else if (c.y >= this.light.y && c.x <= this.light.x) {
            if (bottom.x >= 0 && bottom.x <= this.sceneSize.maxWidth) {
              end = bottom;
            } else {
              end = left;
            }
          }
        }

        // Create a ray
        ray = Line(Point(this.light.x.toDouble(), this.light.y.toDouble()), Point(end!.x.toDouble(), end.y.toDouble()));
        //canvas!.drawLine(Offset(this.light.x.toDouble(), this.light.y.toDouble()), Offset(end.x.toDouble, end.y.toDouble()), this.wallPaint!);

        // Check if the ray intersected the wall
        intersect = this.getWallIntersection(ray);
        //delayedPrint(intersect.toString());
        if (intersect != null) {
          // This is the front edge of the light blocking object
          points.add(intersect);
        } else {
          // Nothing blocked the ray
          points.add(ray.getEnd());
        }
      }
    }

    // Shoot rays at each of the stage corners to see if the corner
    // of the stage is in shadow. This needs to be done so that
    // shadows don't cut the corner.
    ////////
    for (var i = 0; i < stageCorners.length; i++) {
      ray = Line(Point(this.light.x, this.light.y), Point(stageCorners[i].x, stageCorners[i].y));
      intersect = this.getWallIntersection(ray);
      //delayedPrint(intersect.toString());
      if (intersect == null) {
        // Corner is in light
        points.add(stageCorners[i]);
      }
    }

    // Now sort the points clockwise around the light
    // Sorting is required so that the points are connected in the right order.
    //
    // This sorting algorithm was copied from Stack Overflow:
    // http://stackoverflow.com/questions/6989100/sort-points-in-clockwise-order
    //
    // Here's a pseudo-code implementation if you want to code it yourself:
    // http://en.wikipedia.org/wiki/Graham_scan
    var center = Point(this.light.x, this.light.y);
    points.sort((a, b) {
      if (a.x - center.x >= 0 && b.x - center.x < 0) return 1;
      if (a.x - center.x < 0 && b.x - center.x >= 0) return -1;
      if (a.x - center.x == 0 && b.x - center.x == 0) {
        if (a.y - center.y >= 0 || b.y - center.y >= 0) return 1;
        return -1;
      }

      // Compute the cross product of vectors (center -> a) x (center -> b)
      var det = (a.x - center.x) * (b.y - center.y) - (b.x - center.x) * (a.y - center.y);
      if (det < 0) return 1;
      if (det > 0) return -1;

      // Points a and b are on the same line from the center
      // Check which point is closer to the center
      var d1 = (a.x - center.x) * (a.x - center.x) + (a.y - center.y) * (a.y - center.y);
      var d2 = (b.x - center.x) * (b.x - center.x) + (b.y - center.y) * (b.y - center.y);
      return 1;
    });

    /// #draw
    drawCones(points);
  }

  Point midPoint(Point start, Point end) {
    Point out = Point(0, 0);
    out = Point((start.x + end.x) / 2, (start.y + end.y) / 2);
    return out;
  }

  Point? getWallIntersection(Line ray) {
    double distanceToWall = double.infinity;
    Point? closestIntersection = null;
    int wallHeight = 40;
    int wallWidth = 40;
    // For each of the walls...

    this.walls.forEach((wall) {
      // Create an array of lines that represent the four edges of each wall
      List<Line> lines = [
        Line(Point(wall.x, wall.y), Point(wall.x + wallWidth, wall.y)),
        Line(Point(wall.x, wall.y), Point(wall.x, wall.y + wallHeight)),
        Line(Point(wall.x + wallWidth, wall.y), Point(wall.x + wallWidth, wall.y + wallHeight)),
        Line(Point(wall.x, wall.y + wallHeight), Point(wall.x + wallWidth, wall.y + wallHeight))
      ];

      // Test each of the edges in this wall against the ray.
      // If the ray intersects any of the edges then the wall must be in the way.
      for (var i = 0; i < lines.length; i++) {
        var intersect = intersectsPoints(ray.getStart(), ray.getEnd(), lines[i].getStart(), lines[i].getEnd());
        // delayedPrint(intersect.toString());
        if (intersect != null) {
          // Find the closest intersection
          var distance = this.distance(ray.start.x, ray.start.y, intersect.x, intersect.y);
          if (distance < distanceToWall) {
            distanceToWall = distance;
            closestIntersection = intersect;
          }
        }
      }
    });

    return closestIntersection;
  }

  double distance(x1, y1, x2, y2) {
    var dx = x1 - x2;
    var dy = y1 - y2;

    return sqrt(dx * dx + dy * dy);
  }

  Point? intersectsPoints(Point a, Point b, Point e, Point f) {
    Point result = new Point(0, 0);

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

    var uc = ((f.y - e.y) * (b.x - a.x) - (f.x - e.x) * (b.y - a.y));
    var ua = (((f.x - e.x) * (a.y - e.y)) - (f.y - e.y) * (a.x - e.x)) / uc;
    var ub = (((b.x - a.x) * (a.y - e.y)) - ((b.y - a.y) * (a.x - e.x))) / uc;

    if ((ua >= 0) && (ua <= 1) && (ub >= 0) && (ub <= 1)) {
      return result;
    } else {
      return null;
    }
  }

  void drawWalls() {
    for (var i = 0; i < this.walls.length; i++) {
      drawRect(this.walls[i].x.toDouble(), this.walls[i].y.toDouble(), 40, 40, this.wallPaint!);
    }
  }

  void drawCones(List<Point> points) {
    // Connect the dots and fill in the shape, which are cones of light,
    // with a bright white color. When multiplied with the background,
    // the white color will allow the full color of the background to
    // shine through.
    Path path = Path();

    path.moveTo(points[0].x.toDouble(), points[0].y.toDouble());
    for (var j = 0; j < points.length; j++) {
      path.lineTo(points[j].x.toDouble(), points[j].y.toDouble());
    }

    path.close();
    canvas!.drawPath(path, painter!);

    //
    for (var k = 0; k < points.length; k++) {
      canvas!.drawLine(Offset(this.light.x.toDouble(), this.light.y.toDouble()), Offset(points[k].x - 2, points[k].y - 2), this.paintStroke!);
    }
  }

  /// Draw the particle shape
  void drawType(double x, double y, ShapeType type, Paint painter) {
    switch (type) {
      case ShapeType.Circle:
        print("not supported");
        break;
      case ShapeType.Rect:
        drawRect(x, y, null, null, painter);
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
        print("not supported");
        break;
      case ShapeType.Star5:
        print("not supported");
        break;
      case ShapeType.Star6:
        print("not supported");
        break;
      case ShapeType.Star7:
        print("not supported");
        break;
      case ShapeType.Star8:
        print("not supported");
        break;
    }
  }

  void drawCircle(double x, double y, Paint paint) {
    rotate(0, 0, () {
      canvas!.drawCircle(Offset(x, y), 10, paint);
    });
  }

  void drawRect(double x, double y, double? width, double? height, Paint paint) {
    if (this.canvas != null) {
      rotate(x, y, () {
        double _w = width ?? this.sceneSize.maxWidth;
        double _h = height ?? this.sceneSize.maxHeight + 100;
        Rect rect = Rect.fromLTWH(0, 0, _w, _h);
        canvas!.drawRect(rect, paint);
      });
    }
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

  Rect rect() => Rect.fromCircle(center: Offset.zero, radius: radius);

  void delayedPrint(String str) {
    if (DateTime.now().millisecondsSinceEpoch - this.printTime > 100) {
      this.printTime = DateTime.now().millisecondsSinceEpoch;
      print(str);
    }
  }

  void rotate(double? x, double? y, VoidCallback callback) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas!.save();
    canvas!.translate(_x, _y);

    //canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
