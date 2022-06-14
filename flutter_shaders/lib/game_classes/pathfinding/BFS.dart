//
//  BFS.dart
//  BFS-Showcase
//
//  Created by Mixalis Dobekidis on 6/5/21.
//

import 'package:flutter_shaders/game_classes/pathfinding/MazeLocation.dart';
import './MazeLocation.dart';
import './Grid.dart';

import 'Grid.dart';
import 'GridNode.dart';

class BFS {
  Grid grid = Grid(8, 8, []);

  BFS({required this.grid}) {}

  List<MazeLocation> findPath(MazeLocation start, MazeLocation end) {
    List<GridNode> openList = [];
    GridNode startNode = grid.getNodeAt(start.getRow(), start.getCol());
    GridNode endNode = grid.getNodeAt(end.getRow(), end.getCol());
    List<GridNode> neighbors = [];
    GridNode neighbor;
    GridNode node;
    int i = 0;
    int l = 0;

    openList.add(startNode);
    startNode.opened = true;

    while (openList.isEmpty == false) {
      node = openList.removeAt(0);
      startNode.setClosed(true);

      if ({'x': node.getAsML().getRow(), 'y': node.getAsML().getCol()}.toString() ==
          {'x': endNode.getAsML().getRow(), 'y': endNode.getAsML().getCol()}.toString()) {
        return backtrace(endNode);
      }

      neighbors = grid.getNeighbors(node);

      i = 0;
      l = neighbors.length;
      for (i = 0; i < l; i++) {
        neighbor = neighbors[i];

        if (neighbor.getClosed() == true || neighbor.getOpened() == true) {
          continue;
        }

        openList.add(neighbor);
        neighbor.setOpened(true);
        neighbor.setParent(node);
      }
    }

    print("will return empty arr");
    return [];
  }

  List<MazeLocation> backtrace(GridNode node) {
    var _node = node;
    List<MazeLocation> path = [MazeLocation(row: _node.x, col: _node.y)];
    while (_node.getParent() != null) {
      _node = _node.getParent()!;
      path.add(MazeLocation(row: _node.getX(), col: _node.getY()));
    }
    return path.reversed.toList();
  }
}
