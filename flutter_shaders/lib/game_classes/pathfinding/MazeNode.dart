import 'package:flutter_shaders/game_classes/pathfinding/MazeLocation.dart';

/**
 * A node in grid.
 * This class holds some basic information about a node and custom
 * attributes may be added, depending on the algorithms' needs.
 * @constructor
 * @param {number} x - The x coordinate of the node on the grid.
 * @param {number} y - The y coordinate of the node on the grid.
 * @param {boolean} [walkable] - Whether this node is walkable.
 */
class Node {
  /**
     * The x coordinate of the node on the grid.
     * @type number
     */
  int x = 0;
  /**
     * The y coordinate of the node on the grid.
     * @type number
     */
  int y = 0;
  /**
     * Whether this node can be walked through.
     * @type boolean
     */
  bool walkable = false;

  bool opened = false;
  bool closed = false;
  Node? parent;

  Node({required this.x, required this.y, required this.walkable}) {}

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

  void setParent(Node value) {
    parent = value;
  }

  Node? getParent() {
    return parent;
  }

  MazeLocation getAsML() {
    return MazeLocation(row: x, col: y);
  }

  int getX() {
    return x;
  }

  int getY() {
    return y;
  }
}
