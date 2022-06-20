//
//  Grid.dart
//  BFS-Showcase
//
//  Created by Mixalis Dobekidis on 6/5/21.
//

import 'package:flutter_shaders/game_classes/pathfinding/MazeLocation.dart';
import './MazeLocation.dart';
import 'GridNode.dart';

class Grid {
  int width = 0;
  int height = 0;
  List<List<GridNode>> matrix = [];
  bool usesBlocks = true;
  var map2D = [
    [1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 1, 1, 0, 0],
    [0, 0, 0, 1, 1, 0, 0],
    [0, 0, 0, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 0, 0],
    [1, 1, 1, 1, 1, 0, 0],
    [1, 1, 0, 0, 0, 0, 0],
    [1, 1, 0, 0, 0, 0, 0]
  ];

  /*[
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 0, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 0, 0, 1],
    [1, 0, 0, 0, 1, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 2]
  ];*/

  Grid(int _width, int _height, List<List<int>> map2D, {bool usesBlocks = true}) {
    this.width = _width;
    this.height = _height;
    this.map2D = map2D;
    this.usesBlocks = usesBlocks;
    matrix = createMatrix();
    print("> $_width, $_height");
  }

  List<List<GridNode>> createMatrix() {
    List<List<GridNode>> finalResult = [];

    var maze = map2D;

    for (var index = 0; index < maze.length; index++) {
      finalResult.add([]);
      for (var innerIndex = 0; innerIndex < maze[index].length; innerIndex++) {
        Cell type = getVectorTypeBy(MazeLocation(row: index, col: innerIndex));
        finalResult[index].add(GridNode(x: index, y: innerIndex, type: type));
      }
    }

    return finalResult;
  }

  Cell getVectorTypeBy(MazeLocation point) {
    int maxRow = width;
    int maxCol = height;

    if (point.getRow() < 0) {
      return Cell.notFound;
    }

    if (point.getCol() < 0) {
      return Cell.notFound;
    }

    if (point.getRow() > maxRow || point.getCol() > maxCol) {
      return Cell.notFound;
    }

    if (map2D[point.getRow()][point.getCol()] == 0) {
      return Cell.blocked;
    } else if (map2D[point.getRow()][point.getCol()] == 1) {
      return Cell.empty;
    } else if (map2D[point.getRow()][point.getCol()] == 2) {
      return Cell.goal;
    } else if (map2D[point.getRow()][point.getCol()] == 5) {
      return Cell.key;
    } else {
      return Cell.notFound;
    }
  }

  bool isWalkableAt(int x, int y) {
    if (isInside(x, y)) {
      return (matrix[x][y].getType() != Cell.blocked);
    } else {
      return false;
    }
  }

  bool isInside(int x, int y) {
    return (x >= 0 && x < width) && (y >= 0 && y < height);
  }

  GridNode getNodeAt(int x, int y) {
    return matrix[x][y];
  }

  List<GridNode> getNeighbors(GridNode node) {
    int x = node.getX();
    int y = node.getY();
    List<GridNode> neighbors = [];

    // ↑
    if (isWalkableAt(x - 1, y)) {
      neighbors.add(matrix[x - 1][y]);
    }
    // →
    if (isWalkableAt(x, y + 1)) {
      neighbors.add(matrix[x][y + 1]);
    }
    // ↓
    if (isWalkableAt(x + 1, y)) {
      neighbors.add(matrix[x + 1][y]);
    }
    // ←
    if (isWalkableAt(x, y - 1)) {
      neighbors.add(matrix[x][y - 1]);
    }

    return neighbors;
  }
}
