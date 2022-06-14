//
//  GridNode.dart
//  BFS-Showcase
//
//  Created by Mixalis Dobekidis on 6/5/21.
//

import 'package:flutter_shaders/game_classes/pathfinding/MazeLocation.dart';
import './Grid.dart';

import './MazeLocation.dart';

class GridNode {
  int x = 0;
  int y = 0;
  Cell type;
  bool opened = false;
  bool closed = false;
  GridNode? parent;

  GridNode({required this.x, required this.y, required this.type}) {}

  int getX() {
    return x;
  }

  int getY() {
    return y;
  }

  void setClosed(bool value) {
    closed = value;
  }

  void setOpened(bool value) {
    opened = value;
  }

  bool getClosed() {
    return closed;
  }

  bool getOpened() {
    return opened;
  }

  void setParent(GridNode value) {
    parent = value;
  }

  GridNode? getParent() {
    return parent;
  }

  Cell getType() {
    return type ?? Cell.empty;
  }

  MazeLocation getAsML() {
    return MazeLocation(row: x, col: y);
  }
}
