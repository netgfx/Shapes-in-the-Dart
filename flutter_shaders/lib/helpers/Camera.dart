import 'dart:ui';
import 'package:vector_math/vector_math.dart' as vectorMath;
import 'package:flutter_shaders/helpers/MazePlayer.dart';

class Camera {
  double x;
  double y;
  Size canvasSize = Size(0, 0);
  Size mapSize = Size(0, 0);

  Camera({required this.x, required this.y, required Size this.canvasSize, required Size this.mapSize}) {}

  focus(MazePlayer player) {
    // Account for half of player w/h to make their rectangle centered
    this.x = this.clamp(player.x - canvasSize.width / 2 + player.width / 2, 0, mapSize.width - canvasSize.width);
    this.y = this.clamp(player.y - canvasSize.height / 2 + player.height / 2, 0, mapSize.height - canvasSize.height);
    //print("${this.x}, ${this.y}");
  }

  double clamp(double coord, double min, double max) {
    if (coord < min) {
      return min;
    } else if (coord > max) {
      return max;
    } else {
      return coord;
    }
  }

  Rect getCameraBounds() {
    return Rect.fromLTWH(this.x, this.y, this.canvasSize.width, this.canvasSize.height);
  }
}
