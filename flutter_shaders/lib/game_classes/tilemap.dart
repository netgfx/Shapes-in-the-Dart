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
  String tilesFile = "";
  Size? tileSize = Size(54, 54);
  Size size = Size(0, 0);
  List<String> tilesList = tiles;
  Map<String, ui.Image> textureImages = {};
  ui.Image? textureImage;
  bool tilemapCreated = false;
  String baseURL = "assets/td/";
  String extensionStr = ".png";

  /// Constructor
  TileMapPainter({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,

    /// <-- The tiles to use for the map
    required this.tilesFile,

    /// <-- The map data
    required this.csvFile,
    required width,
    required height,

    /// <-- The tile size
    tileSize,

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

    //loadMapData();
    for (var i = 0; i < this.tilesList.length; i++) {
      loadTileImages(this.tilesList[i]);
    }
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
        } else {}
      }
    } else {
      print("re-rendering points with no changes");
    }
    // TODO: add offset to show unit movement on the map
    createTilemap(canvas);
  }

  void createTilemap(Canvas canvas) {
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

          canvas.drawImageRect(
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
