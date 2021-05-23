import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_shaders/MazeGenerator.dart';

class MazeGeneratorV2 {
  final _random = new Random();
  int pathWidth = 50; //Width of the Maze Path
  int wall = 2; //Width of the Walls between Paths
  int outerWall = 2; //Width of the Outer most wall
  int width = 4; //Number paths fitted horisontally
  int height = 6; //Number paths fitted vertically
  int delay = 1; //Delay between algorithm cycles
  int x = 0; //width/2;        //Horisontal starting position
  int y = 0; //height/2;      //Vertical starting position
  double seed = 0; //Math.random()*100000|0//Seed for random numbers
  Color wallColor = Color(0xd24000); //Color of the walls
  Color pathColor = Color(0x222a33); //Color of the path
  Function random = () {};

  Function randomGen(int? _seed) {
    int seed = _seed ?? DateTime.now().microsecondsSinceEpoch;
    return () {
      seed = (seed * 9301 + 49297) % 233280;
      return seed ~/ 233280;
    };
  }

  MazeGeneratorV2(int width, int height, int? seed) {
    this.x = (width / 2).round() | 0;
    this.y = (height / 2).round() | 0;
    seed = (_random.nextDouble() * 100000).toInt() | 0;
    random = randomGen(seed);
  }

  Map<String, dynamic> init() {
    int offset = (pathWidth / 2 + outerWall).round();
    List<List<bool>> map = [];
    //canvas = document.querySelector('canvas')
    //ctx = canvas.getContext('2d')
    int canvasWidth = outerWall * 2 + width * (pathWidth + wall) - wall;
    int canvasHeight = outerWall * 2 + height * (pathWidth + wall) - wall;
    //ctx.fillStyle = wallColor
    //ctx.fillRect(0,0,canvas.width,canvas.height)
    random = randomGen(57392);
    //ctx.strokeStyle = pathColor
    //ctx.lineCap = 'square'
    //ctx.lineWidth = pathWidth
    //ctx.beginPath()
    for (var i = 0; i < height * 2; i++) {
      map.add([]);
      for (var j = 0; j < width * 2; j++) {
        map[i].add(false);
      }
    }
    print("$map $x $y");
    map[y * 2][x * 2] = true;
    List<List<int>> route = [
      [x, y]
    ];
    int initialX = x * (pathWidth + wall) + offset;
    int initialY = y * (pathWidth + wall) + offset;

    return {"random": random, "map": map, "route": route, "initialX": initialX, "initialY": initialY, "canvasWidth": canvasWidth, "canvasHeight": canvasHeight, "offset": offset};
  }
}
