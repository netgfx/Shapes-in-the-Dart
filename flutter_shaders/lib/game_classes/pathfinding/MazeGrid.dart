import 'package:collection/collection.dart';
import 'package:flutter_shaders/game_classes/maze/maze_builder.dart';
import 'package:flutter_shaders/game_classes/pathfinding/MazeNode.dart';
import 'dart:collection';

/**
 * The Grid class, which serves as the encapsulation of the layout of the nodes.
 * @constructor
 * @param {number|Array<Array<(number|boolean)>>} width_or_matrix Number of columns of the grid, or matrix
 * @param {number} height Number of rows of the grid.
 * @param {Array<Array<(number|boolean)>>} [matrix] - A 0-1 matrix
 *     representing the walkable status of the nodes(0 or false for walkable).
 *     If the matrix is not supplied, all the nodes will be walkable.
 * @param {Array<Array<Object>>} [maze] the maze that is pre-generated (with walls)  */
class MazeGrid {
  List<List<Cell>> maze = [];

  /**
     * The number of columns of the grid.
     * @type number
     */
  int width = 0;
  /**
     * The number of rows of the grid.
     * @type number
     */
  int height = 0;

  List<List<Node>> nodes = [];

  List<List<Node>> matrix = [];

  MazeGrid({required this.width, required this.height, required this.matrix, required this.maze}) {
    /**
     * A 2D array of nodes.
     */
    this.nodes = _buildNodes(width, height, this.matrix);
  }

/**
 * Build and return the nodes.
 * @private
 * @param {number} width
 * @param {number} height
 * @param {Array<Array<number|boolean>>} [matrix] - A 0-1 matrix representing
 *     the walkable status of the nodes.
 * @see Grid
 */
  List<List<Node>> _buildNodes(int width, int height, List<List<Node>> matrix) {
    List<List<Node>> nodes = List.generate(height, (int index) => []);

    for (int i = 0; i < height; ++i) {
      nodes[i] = List.generate(width, (int index) => new Node(x: 0, y: 0, walkable: true));
      for (int j = 0; j < width; ++j) {
        nodes[i][j] = new Node(x: j, y: i, walkable: true);
      }
    }

    if (matrix.length != height || matrix[0].length != width) {
      print("Matrix size does not fit");
    }

    return nodes;
  }

  Node getNodeAt(x, y) {
    return this.nodes[y][x];
  }

  getWalkableAt(int x, int y, String direction, List<List<Cell>> maze) {
    var realX = x;
    var realY = y;
    //console.log("checking ", x, y, realX, realY)
    Cell? result;
    for (var i = 0; i < maze.length; i++) {
      result = maze[i].firstWhereOrNull((o) => o.x == realX && o.y == realY);
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

/**
 * Determine whether the node at the given position is walkable.
 * (Also returns false if the position is outside the grid.)
 * @param {number} x - The x coordinate of the node.
 * @param {number} y - The y coordinate of the node.
 * @return {boolean} - The walkability of the node.
 */
  bool isWalkableAt(int x, int y) {
    bool result = this.isInside(x, y) && this.nodes[y][x].walkable;
    return result;
  }

/**
 * Determine whether the position is inside the grid.
 * XXX: `grid.isInside(x, y)` is wierd to read.
 * It should be `(x, y) is inside grid`, but I failed to find a better
 * name for this method.
 * @param {number} x
 * @param {number} y
 * @return {boolean}
 */
  bool isInside(int x, int y) {
    return x >= 0 && x < this.width && y >= 0 && y < this.height;
  }

/**
 * Set whether the node on the given position is walkable.
 * NOTE: throws exception if the coordinate is not inside the grid.
 * @param {number} x - The x coordinate of the node.
 * @param {number} y - The y coordinate of the node.
 * @param {boolean} walkable - Whether the position is walkable.
 */
  void setWalkableAt(int x, int y, bool walkable) {
    this.nodes[y][x].walkable = walkable;
  }

/**
 * Get the neighbors of the given node.
 *
 *     offsets      diagonalOffsets:
 *  +---+---+---+    +---+---+---+
 *  |   | 0 |   |    | 0 |   | 1 |
 *  +---+---+---+    +---+---+---+
 *  | 3 |   | 1 |    |   |   |   |
 *  +---+---+---+    +---+---+---+
 *  |   | 2 |   |    | 3 |   | 2 |
 *  +---+---+---+    +---+---+---+
 *
 *  When allowDiagonal is true, if offsets[i] is valid, then
 *  diagonalOffsets[i] and
 *  diagonalOffsets[(i + 1) % 4] is valid.
 * @param {Node} node
 * @param {DiagonalMovement} diagonalMovement
 */
  List<Node> getNeighbors(Node node, {bool? diagonalMovement = false}) {
    int x = node.x;
    int y = node.y;
    List<Node> neighbors = [];
    bool s0 = false, d0 = false, s1 = false, d1 = false, s2 = false, d2 = false, s3 = false, d3 = false;
    List<List<Node>> nodes = this.nodes;

    // ↑
    if (getWalkableAt(x, y, "top", this.maze) && this.isWalkableAt(x, y - 1)) {
      neighbors.add(nodes[y - 1][x]);
      s0 = true;
    }
    // →
    if (getWalkableAt(x, y, "right", this.maze) && this.isWalkableAt(x + 1, y)) {
      neighbors.add(nodes[y][x + 1]);
      s1 = true;
    }
    // ↓
    if (getWalkableAt(x, y, "bottom", this.maze) && this.isWalkableAt(x, y + 1)) {
      neighbors.add(nodes[y + 1][x]);
      s2 = true;
    }
    // ←
    if (getWalkableAt(x, y, "left", this.maze) && this.isWalkableAt(x - 1, y)) {
      neighbors.add(nodes[y][x - 1]);
      s3 = true;
    }

    return neighbors;
  }
}
