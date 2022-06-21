import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/Star.dart';
import 'package:flutter_shaders/game_classes/pathfinding/BFS.dart';
import 'package:flutter_shaders/game_classes/pathfinding/BFSSimple.dart';
import 'package:flutter_shaders/game_classes/pathfinding/Grid.dart';
import 'package:flutter_shaders/game_classes/pathfinding/MazeLocation.dart';
import 'package:flutter_shaders/helpers/GameObject.dart';
import 'package:flutter_shaders/helpers/math/CubicBezier.dart';
import 'package:flutter_shaders/helpers/utils.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;
import '../helpers/tiles.dart';

class TileMapPainter extends CustomPainter {
  Color color = Colors.black;
  List<Star> stars = [];
  AnimationController? controller;
  Canvas? canvas;
  double radius = 100.0;
  int delay = 500;
  int currentTime = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  int timeDecay = 0;
  double? rate = 10;
  double endT = 0.0;
  int timeAlive = 0;
  int timeToLive = 24;
  BoxConstraints sceneSize = BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Function? animate;
  Paint? painter;
  Paint? paintStroke;
  //List<List<String>> map = [];
  String csvFile = "";
  Size? tileSize = Size(54, 54);
  Size size = Size(0, 0);
  List<String> tilesList = tiles;
  Map<String, ui.Image> textureImages = {};
  ui.Image? textureImage;
  bool tilemapCreated = false;
  String baseURL = "assets/td/";
  String extensionStr = ".png";
  Map<String, dynamic> pathItems = {};
  List<Point<double>> gridPoints = [];
  List<List<vectorMath.Vector2>> cubicPoints = [];
  List<MazeLocation> path = [];
  Paint _paint = new Paint();

  /// Constructor
  TileMapPainter({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,
    required this.pathItems,

    /// <-- The map data
    required this.baseURL,
    required width,
    required height,

    /// <-- The tile size
    required Size tileSize,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,

    /// <-- Custom callback to call after Delay has passed
    this.animate,
  }) : super(repaint: controller) {
    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();
    this.tileSize = tileSize;

    /// default painter
    print("$width x $height");
    painter = Paint()
      ..color = Colors.white
      ..blendMode = ui.BlendMode.overlay
      ..style = PaintingStyle.fill;

    paintStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    this._paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    //loadMapData();
    List<List<int>> grid = [];

    /// make it dynamic
    Point<int> target = Point(3, 3);

    for (var i = 0; i < this.tilesList.length; i += 7) {
      grid.add([]);
      for (var j = i; j < i + 7; j++) {
        if (this.pathItems["paths"].indexOf(tilesList[j]) != -1) {
          grid[grid.length - 1].add(1);
        } else {
          grid[grid.length - 1].add(0);
        }
      }
    }

    grid[target.y][target.x] = 2;

    var flat = grid.expand((i) => i).toList();
    int counter = 0;

    /// get path with BFS

    getPath(Grid(grid.length, grid[0].length, grid));

    print("GRID IS: $tileSize $grid $gridPoints");
    for (var k = 0; k < this.tilesList.length; k++) {
      loadTileImages(this.tilesList[k]);
    }
  }

  void getPath(Grid grid) {
    gridPoints.clear();

    path = BFSSimple(grid: grid).findPath(MazeLocation(row: 12, col: 1), MazeLocation(row: 3, col: 3));
    //pathTiles = path;
    print("SOLUTION IS: $path");
    List<CubicBezier> quadBeziers = [];

    int pathLength = (path.length + ((path.length / 4))).round();
    for (var k = 0; k <= pathLength; k += 4) {
      if (k == 0) {
        path.insert(k, MazeLocation(row: path[0].row, col: path[0].col));
      } else {
        path.insert(k, MazeLocation(row: path[k - 1].row, col: path[k - 1].col));
      }
    }

    for (var i = 0; i < path.length; i += 4) {
      List<vectorMath.Vector2> currentPoint = [];
      int index = i;
      int index1 = i + 1;
      int index2 = i + 2;
      int index3 = i + 3;
      if (index1 >= path.length) {
        index1 = i;
        index2 = i;
        index3 = i;
      } else if (index2 >= path.length) {
        index2 = index1;
        index3 = index1;
      } else if (index3 >= path.length) {
        index3 = index2;
      }

      Point p0 = getPointFromCoordinates(path[index].getCol().toDouble(), path[index].getRow().toDouble());
      Point p1 = getPointFromCoordinates(path[index1].getCol().toDouble(), path[index1].getRow().toDouble());
      Point p2 = getPointFromCoordinates(path[index2].getCol().toDouble(), path[index2].getRow().toDouble());
      Point p3 = getPointFromCoordinates(path[index3].getCol().toDouble(), path[index3].getRow().toDouble());

      currentPoint = [
        vectorMath.Vector2(p0.x.toDouble(), p0.y.toDouble() + 10),
        vectorMath.Vector2(p1.x.toDouble(), p1.y.toDouble() + 10),
        vectorMath.Vector2(p2.x.toDouble(), p2.y.toDouble() + 10),
        vectorMath.Vector2(p3.x.toDouble(), p3.y.toDouble() + 10),
      ];

      cubicPoints.add(currentPoint);
      quadBeziers.add(CubicBezier(p0: currentPoint[0], p1: currentPoint[1], p2: currentPoint[2], p3: currentPoint[3]));
    }

    GameObject.shared.setCubicBeziers(quadBeziers);
  }

  /// uncomment to read CSV (preferable?)
  // void loadMapData() async {
  //   var d = new FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);
  //   final input = await rootBundle.loadString(this.csvFile);
  //   tilesList = CsvToListConverter(csvSettingsDetector: d).convert(input);
  //   print(tilesList);

  //   await loadTileImage();
  // }

  Future<ui.Image?> loadTileImages(String imageURL) async {
    /// cache these externally
    final ByteData data = await rootBundle.load(baseURL + imageURL + extensionStr);
    var textureImage = await Utils.shared.imageFromBytes(data);
    if (this.tileSize == null) {
      //this.tileSize = Size(textureImage.width.toDouble(), textureImage.height.toDouble());
    }
    textureImages[imageURL] = textureImage;
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;

    paintImage(canvas, size);
  }

  void paintImage(Canvas canvas, Size size) async {
    draw(canvas, size);

    //createTilemap(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Point<double> getPointFromCoordinates(double x, double y) {
    double finalX = (((x + 1) * tileSize!.width) - (tileSize!.width / 2)).roundToDouble();
    double finalY = (((y + 1) * tileSize!.height) - (tileSize!.height / 2)).roundToDouble();

    return Point(finalX, finalY);
  }

  void draw(Canvas canvas, Size size) {
    double cx = this.sceneSize.maxWidth / 2;
    double cy = this.sceneSize.maxHeight / 2;
    this.canvas = canvas;

    /// check if the controller is running
    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        /// in order to run in our required frames per second
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay && this.timeAlive == 0) {
          /// reset the time

          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;
        } else {}
      }
    } else {
      print("re-rendering points with no changes");
    }
    // TODO: add offset to show unit movement on the map
    createTilemap();
    drawCircle();
    drawRect();
    var cubic = GameObject.shared.getCubicBeziers();
    final Path path = Path();
    for (var i = 0; i < cubic.length; i++) {
      drawCurve(cubic[i], path);
    }
    path.close();
    canvas.drawPath(path, _paint);
  }

  void createTilemap() {
    if (this.textureImages.isNotEmpty) {
      var positionCounter = 0;
      var paint = new Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = false;

      for (var i = 0; i < this.tilesList.length; i += 7) {
        for (var j = 0; j < 7; j++) {
          String pos = this.tilesList[i + j];
          if (this.textureImages[pos] == null) {
            continue;
          }

          this.canvas!.drawImageRect(
                this.textureImages[pos]!,
                Rect.fromLTWH(0, 0, this.tileSize!.width, this.tileSize!.height),
                Rect.fromLTWH(j * this.tileSize!.width, positionCounter * this.tileSize!.height, this.tileSize!.width, this.tileSize!.height),
                paint,
              );
          //print("$tileSize $j $i");
        }

        positionCounter += 1;
        this.tilemapCreated = true;
      }
    }
  }

  void drawCurve(CubicBezier curve, Path path) {
    updateCanvas(curve.getStartPoint().x, curve.getStartPoint().y, null, () {
      final Path path = Path();

      path.moveTo(curve.getStartPoint().x, curve.getStartPoint().y);

      //path.relativeCubicTo(x1, y1, x2, y2)
      path.cubicTo(curve.p1.x, curve.p1.y, curve.p2.x, curve.p2.y, curve.p3.x, curve.p3.y);

      canvas!.drawPath(path, _paint);
    });
  }

  void drawPath() {
    final Paint fill = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 4;

    Path linepath = Path();

    for (var i = 0; i < gridPoints.length; i += 2) {
      double x = gridPoints[i].x;
      double y = gridPoints[i].y;
      if (i + 1 < gridPoints.length) {
        double x2 = gridPoints[i + 1].x;
        double y2 = gridPoints[i + 1].y;
        linepath.moveTo(x, y);
        linepath.lineTo(x2, y2);
        linepath.close();
      } else {
        continue;
      }
    }

    //linepath.close();
    this.canvas!.drawPath(linepath, fill);
  }

  void drawRect() {
    if (path.length > 0) {
      var _paint = Paint()
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = Colors.blue.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      for (var i = 0; i < path.length; i++) {
        updateCanvas(0, 0, null, () {
          double finalX = path[i].getCol() * tileSize!.width; //((x + 1) * tileSize!.width) - tileSize!.width / 2;
          double finalY = path[i].getRow() * tileSize!.height; //((y + 1) * tileSize!.height) - tileSize!.height / 2;
          Point point = Point(finalX, finalY);

          canvas!.drawRect(Rect.fromLTWH(point.x.toDouble(), point.y.toDouble(), tileSize!.width, tileSize!.height), _paint);
          //canvas.drawCircle(Offset(0, 0), radius, _paint);
        });
      }
    }
  }

  void drawCircle() {
    if (path.length > 0) {
      var _paint = Paint()
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = Colors.red.withOpacity(1)
        ..style = PaintingStyle.fill;

      for (var i = 0; i < path.length; i++) {
        int x = path[i].getCol();
        int y = path[i].getRow();
        double finalX = ((x + 1) * tileSize!.width) - tileSize!.width / 2;
        double finalY = ((y + 1) * tileSize!.height) - tileSize!.height / 2;
        Point point = getPointFromCoordinates(path[i].getCol().toDouble(), path[i].getRow().toDouble());
        //print("$x, $y");
        updateCanvas(0, 0, null, () {
          canvas!.drawRect(Rect.fromLTWH(finalX.toDouble(), finalY.toDouble(), 5, 5), _paint);
          //canvas.drawCircle(Offset(0, 0), radius, _paint);
        });
      }
    }
  }

  void updateCanvas(double? x, double? y, double? angle, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas!.save();

    if (translate) {
      canvas!.translate(_x, _y);
    }

    if (angle != null) {
      // double x1 = (_x * cos(angle)) - (_y * sin(angle));
      // double y1 = (_x * sin(angle)) + (_y * cos(angle));

      canvas!.translate(_x, _y);
      canvas?.rotate(angle);
    } else {
      //canvas?.rotate(0);
    }
    //canvas!.translate(0, 0);
    callback();
    canvas!.restore();
  }
}
