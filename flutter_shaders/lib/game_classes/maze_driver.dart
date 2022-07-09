import 'dart:core';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/game_classes/maze/maze_builder.dart';
import 'package:flutter_shaders/game_classes/maze/maze_draw.dart';
import 'package:flutter_shaders/game_classes/mazeplayer_draw.dart';

import 'package:flutter_shaders/helpers/Camera.dart';
import 'package:flutter_shaders/helpers/GameObject.dart';
import 'package:flutter_shaders/helpers/MazePlayer.dart';
import 'package:flutter_shaders/helpers/Rectangle.dart';
import 'package:flutter_shaders/helpers/action_manager.dart';
import 'package:flutter_shaders/helpers/math/CubicBezier.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:flutter/painting.dart" as painter;
import "../helpers//utils.dart";

class MazeDriverCanvas extends CustomPainter {
  List<Map<String, dynamic>> points = [];

  Color color = Colors.black;
  var index = 0;
  var offset = 0;
  AnimationController? controller;
  Canvas? canvas;
  int delay = 500;
  int currentTime = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  int timeDecay = 0;
  double rate = 1.0;
  final _random = new Random();
  int timeToLive = 24;
  double width = 100;
  double height = 100;
  int curveIndex = 0;
  var computedPoint = vectorMath.Vector2(0, 0);
  double computedAngle = 0.0;
  List<List<vectorMath.Vector2>> curve = [];
  List<CubicBezier> quadBeziers = [];
  Function? update;
  Paint _paint = new Paint();
  int blockSize = 8;
  BoxConstraints sceneSize = BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);
  ui.BlendMode? blendMode = ui.BlendMode.src;
  Rectangle worldBounds = Rectangle(x: 0, y: 0, width: 0, height: 0);
  Camera? _camera;
  MazePlayer player = MazePlayer(height: 4, width: 4, blocksize: 8);
  bool maxRightReached = false;
  List<List<Cell>> maze = [];
  MazeDrawer? mazeMap;
  MazePlayerDrawer? mazePlayer;
  ActionManager actions;
  var listenable;
  //

  /// Constructor
  MazeDriverCanvas({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,

    /// <-- The delay until the animation starts
    required this.width,
    required this.height,
    required this.blockSize,
    required this.maze,
    required this.actions,

    /// <-- The particles blend mode (default: BlendMode.src)
    this.blendMode,
  }) : super(repaint: controller) {
    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();
    this._paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.yellow
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    /// calculate world bounds
    this.worldBounds = Rectangle(x: 0, y: 0, width: this.width, height: this.height);

    this._camera = Camera(x: 0, y: 0, canvasSize: Size(width * 0.6, (this.blockSize * 24) * 0.8), mapSize: Size(this.blockSize * 24, this.blockSize * 24));

    /// make maze
    mazeMap = MazeDrawer(maze: maze, blockSize: blockSize);

    /// make player
    mazePlayer = MazePlayerDrawer(blockSize: blockSize);
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;

    if (listenable != null) {
      listenable.cancel();
    } else {
      listenable = actions.actionDone.listen((event) {
        print(event.toString());
        switch (event.toString()) {
          case "left":
            {
              bool result = getWalkableAt("left");
              if (result == true) {
                this.player.goLeft();
              }
            }
            break;
          case "right":
            {
              bool result = getWalkableAt("right");
              if (result == true) {
                this.player.goRight();
              }
            }
            break;
          case "top":
            {
              bool result = getWalkableAt("top");
              if (result == true) {
                this.player.goTop();
              }
            }
            break;
          case "bottom":
            {
              bool result = getWalkableAt("bottom");
              if (result == true) {
                this.player.goBottom();
              }
            }
        }
      });
    }

    if (_camera != null) {
      canvas.clipRect(Rect.fromLTWH(0, 0, _camera!.getCameraBounds().width, _camera!.getCameraBounds().height));
      Rect bounds = _camera!.getCameraBounds();
      //moveCanvas(bounds.left * -1, bounds.top, () {});
      // print("$bounds, ${this.player.x}");
    }

    // update player
    if (mazePlayer != null) {
      mazePlayer!.update(canvas, this.player);
    }

    paintImage(canvas, size);

    /// draw the map and cull it based on camera Rect
    mazeMap!.update(canvas, this._camera!.getCameraBounds());
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
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay) {
          /// reset the time

          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;
          if (this.player.x >= this.width / 2) {
            maxRightReached = true;
          }

          if (this.player.x == 0) {
            //maxRightReached = false;
          }

          if (maxRightReached == true) {
            //this.player.x -= this.rate;
          } else {
            //this.player.x += this.rate;
          }
          this._camera?.focus(this.player);
        } else {}
      } else {
        print("no elapsed duration");
      }
    } else {
      print("no controller running");
    }
  }

  bool getWalkableAt(String direction) {
    var realX = this.player.x;
    var realY = this.player.y;
    //console.log("checking ", x, y, realX, realY)
    Cell? result;
    int length = this.maze.length;
    for (var i = 0; i < length; i++) {
      result = this.maze[i].firstWhereOrNull((o) => o.x == realX && o.y == realY);
      if (result != null) {
        break;
      }
    }

    if (result != null) {
      return !result.getPropertyByKey(direction);
    } else {
      return false;
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
