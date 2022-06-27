class MazePlayer {
  double _x = 0;
  double _y = 0;
  double width;
  double height;

  bool topKey = false;
  bool rightKey = false;
  bool bottomKey = false;
  bool leftKey = false;

  MazePlayer({required this.width, required this.height}) {}

  set x(double value) {
    this._x = value;
  }

  double get x {
    return this._x;
  }

  set y(double value) {
    this._y = value;
  }

  double get y {
    return this._y;
  }
}
