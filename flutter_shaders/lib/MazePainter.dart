import 'dart:async';
import 'dart:convert';
import "dart:math";
import "dart:ui";

import 'package:flutter/material.dart' as material;
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math.dart';

class MazePainter extends CustomPainter {
  Size size = Size(20, 20);
  double radius = 0.0;
  Canvas? canvas;
  Offset center = Offset(0, 0);
  double? angle = 0;
  material.Color color = material.Colors.black;
  List<List<bool>> path = [];
  int initialX = 0;
  int initialY = 0;
  int x = 0;
  int y = 0;
  int pathWidth = 50; //Width of the Maze Path
  int pathHeight = 50;
  int wall = 5; //Width of the Walls between Paths
  int outerWall = 2; //Width of the Outer most wall
  int width = 4; //Number paths fitted horisontally
  int height = 6; //Number paths fitted vertically
  int delay = 1; //Delay between algorithm cycles
  Color wallColor = Color(0xd24000); //Color of the walls
  Color pathColor = Color(0x222a33); //Color of the path
  List<List<int>> route = [];
  int offset = 0;
  late Function random;
  Timer? timer;
  List<Map<String, dynamic>> moves = [];
  Function callback = () {};
  Path linepath = Path();

  MazePainter(Map<String, dynamic> initialData, double maxWidth, double maxHeight, Function callback) {
    this.path = initialData["map"];
    this.initialX = initialData["initialX"];
    this.initialY = initialData["initialY"];
    this.route = initialData["route"];
    this.x = (size.width / 2).round() | 0;
    this.y = (size.height / 2).round() | 0;
    this.offset = initialData["offset"];
    this.random = initialData["random"];
    this.callback = callback;
    this.size = Size(maxWidth, maxHeight);
    linepath.moveTo(this.initialX.toDouble(), this.initialY.toDouble());
    moves.add({"type": "move", "value": Offset(this.initialX.toDouble(), this.initialY.toDouble())});
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.moves.clear();

    //print("paint was called");
    draw();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void draw() {
    //print("making a $type");
    //drawType();

    String mapObj =
        "{\"rows\":[[{\"left\":true,\"right\":false,\"up\":true,\"down\":false,\"visited\":true},{\"left\":false,\"right\":true,\"up\":true,\"down\":false,\"visited\":true},{\"left\":true,\"right\":false,\"up\":true,\"down\":false,\"visited\":true},{\"left\":false,\"right\":false,\"up\":true,\"down\":true,\"visited\":true},{\"left\":false,\"right\":false,\"up\":true,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":true,\"down\":true,\"visited\":true}],[{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":false,\"up\":true,\"down\":false,\"visited\":true},{\"left\":false,\"right\":false,\"up\":true,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":true,\"down\":false,\"visited\":true}],[{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":false,\"up\":false,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":false,\"down\":true,\"visited\":true},{\"left\":true,\"right\":false,\"up\":false,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":true,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true}],[{\"left\":true,\"right\":false,\"up\":false,\"down\":false,\"visited\":true},{\"left\":false,\"right\":true,\"up\":true,\"down\":false,\"visited\":true},{\"left\":true,\"right\":false,\"up\":true,\"down\":false,\"visited\":true},{\"left\":false,\"right\":false,\"up\":true,\"down\":false,\"visited\":true},{\"left\":false,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true}],[{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true}],[{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":false,\"up\":false,\"down\":false,\"visited\":true},{\"left\":false,\"right\":true,\"up\":false,\"down\":true,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":true,\"visited\":true},{\"left\":true,\"right\":false,\"up\":false,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":false,\"down\":true,\"visited\":true}],[{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":true,\"visited\":true},{\"left\":true,\"right\":false,\"up\":true,\"down\":false,\"visited\":true},{\"left\":false,\"right\":false,\"up\":true,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":true,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":true,\"down\":false,\"visited\":true}],[{\"left\":true,\"right\":false,\"up\":false,\"down\":false,\"visited\":true},{\"left\":false,\"right\":true,\"up\":true,\"down\":false,\"visited\":true},{\"left\":true,\"right\":false,\"up\":false,\"down\":false,\"visited\":true},{\"left\":false,\"right\":true,\"up\":true,\"down\":false,\"visited\":true},{\"left\":true,\"right\":false,\"up\":false,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":false,\"down\":true,\"visited\":true}],[{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":true,\"up\":false,\"down\":false,\"visited\":true},{\"left\":true,\"right\":false,\"up\":true,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":true,\"down\":false,\"visited\":true}],[{\"left\":true,\"right\":true,\"up\":false,\"down\":true,\"visited\":true},{\"left\":true,\"right\":false,\"up\":false,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":false,\"down\":true,\"visited\":true},{\"left\":true,\"right\":false,\"up\":false,\"down\":true,\"visited\":true},{\"left\":false,\"right\":false,\"up\":true,\"down\":true,\"visited\":true},{\"left\":false,\"right\":true,\"up\":false,\"down\":true,\"visited\":true}]]}";

    Map<String, dynamic> parsedObj = jsonDecode(mapObj) as Map<String, dynamic>;
    List<List<Map<String, dynamic>>> rows = [];
    for (var i = 0; i < parsedObj["rows"].length; i++) {
      print(parsedObj["rows"][i]);
      rows.add([]);
      for (var j = 0; j < parsedObj["rows"][i].length; j++) {
        print(parsedObj["rows"][i][j]);
        rows[i].add(parsedObj["rows"][i][j] as Map<String, dynamic>);
      }
    }
    print(" >>>> ${parsedObj["rows"].length}");

    pathWidth = (this.size.width / parsedObj["rows"][0].length).floor() - 5;
    pathHeight = pathWidth; //(this.size.height / parsedObj["rows"].length).floor() - 5;
    print("${this.size.width.floor()} ${this.size.height.floor()} $pathWidth, $pathHeight");
    drawPath(rows);

    //print(moves);
  }

  void drawType() {
    if (timer != null) {
      timer!.cancel();
    }
    final _random = new Random();
    final Paint fill = Paint()
      ..color = this.color
      ..style = material.PaintingStyle.stroke
      ..strokeCap = material.StrokeCap.butt
      ..strokeWidth = 4;

    final Path linepath = Path();

    var indexX = route.length - 1;
    var indexY = route.length - 1;
    if (indexX < route.length) {
      this.x = route[route.length - 1][0] | 0;

      if (1 < route.length) {
        this.y = route[route.length - 1][1] | 0;
      } else {
        this.y = 0;
      }
    } else {
      this.x = 0;
    }

    this.y = route[route.length - 1][1];

    List<List<int>> directions = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1]
    ];
    List<List<int>> alternatives = [];

    for (var i = 0; i < directions.length; i++) {
      int indexY = (directions[i][1] + y) * 2;
      int indexX = (directions[i][0] + x) * 2;
      if (indexY < this.path.length && indexY >= 0) {
        if (indexX < this.path[indexY].length && indexX >= 0) {
          if (this.path[indexY][indexX] == false) {
            alternatives.add(directions[i]);
          }
        }
      }
    }

    if (alternatives.length == 0) {
      route.removeLast();
      if (route.length > 0) {
        double offsetX = route[route.length - 1][0] * (pathWidth + wall) + offset.toDouble();
        double offsetY = route[route.length - 1][1] * (pathWidth + wall) + offset.toDouble();
        //linepath.moveTo(offsetX, offsetY);
        moves.add({"type": "move", "value": Offset(offsetX, offsetY)});
        //timer = Timer(Duration(milliseconds: 500), drawType);
        drawType();
      }

      print(moves);
      moves.add({"type": "close", "value": ""});
      this.callback(moves);
      //drawPath(moves);
      return;
    }

    int randomNum = random();
    print(randomNum);
    int randIndex = randomNum * alternatives.length | 0;
    List<int> direction = alternatives[randIndex];
    route.add([direction[0] + x, direction[1] + y]);

    double offsetX = ((direction[0] + x) * (pathWidth + wall) + offset).toDouble();
    double offsetY = ((direction[1] + y) * (pathWidth + wall) + offset).toDouble();
    //linepath.lineTo(offsetX, offsetY);
    moves.add({"type": "line", "value": Offset(offsetX, offsetY)});
    path[(direction[1] + y) * 2][(direction[0] + x) * 2] = true;
    path[direction[1] + y * 2][direction[0] + x * 2] = true;

    print("$linepath $canvas");
    //linepath.close();
    moves.add({"type": "draw", "value": ""});
    //this.canvas!.drawPath(linepath, fill);
    //timer = Timer(Duration(milliseconds: 500), drawType);
    drawType();
  }

  void drawPath(List<List<Map<String, dynamic>>> movesList) {
    final Paint fill = Paint()
      ..color = this.color
      ..style = material.PaintingStyle.stroke
      ..strokeCap = material.StrokeCap.butt
      ..strokeWidth = 4;
    print(movesList.length);
    Path linepath = Path();

    /// {left: true, right: false, up: true, down: false, visited: true}
    for (var i = 0; i < movesList.length; i++) {
      for (var j = 0; j < movesList[i].length; j++) {
        double x = (pathWidth * j).toDouble(); // column blocks
        double y = (pathHeight * i).toDouble(); // row blocks
        print("$x, $y, $i, $j ${movesList[i][j]}");
        if (movesList[i][j]["up"] == true) {
          linepath.moveTo(x, y);
          linepath.lineTo((x + pathWidth).toDouble(), y);
          linepath.close();
        }

        if (movesList[i][j]["down"] == true) {
          linepath.moveTo(x, y + pathHeight);
          linepath.lineTo(x + pathWidth, y + pathHeight);
          linepath.close();
        }

        if (movesList[i][j]["left"] == true) {
          linepath.moveTo(x, y);
          linepath.lineTo(x, y + pathHeight);
          linepath.close();
        }

        if (movesList[i][j]["right"] == true) {
          linepath.moveTo(x + pathWidth, y);
          linepath.lineTo(x + pathWidth, y + pathHeight);
          linepath.close();
        }
      }
    }

    //linepath.close();
    this.canvas!.drawPath(linepath, fill);
  }

  void changeColor(Color color) {}

  void drawStar(int num, Paint paint, {double initialAngle = 0}) {
    rotate(() {
      final Path path = Path();
      for (int i = 0; i < num; i++) {
        final double radian = radians(initialAngle + 360 / num * i.toDouble());
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

  void rotate(VoidCallback callback) {
    canvas!.save();
    canvas!.translate(center.dx, center.dy);

    canvas!.rotate(angle!);
    callback();
    canvas!.restore();
  }
}
