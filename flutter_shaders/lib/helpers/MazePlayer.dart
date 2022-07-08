class MazePlayer {
  double _x = 0;
  double _y = 0;
  int blocksize = 0;
  double width;
  double height;

  bool topKey = false;
  bool rightKey = false;
  bool bottomKey = false;
  bool leftKey = false;

  MazePlayer({required this.width, required this.height, required this.blocksize}) {}

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

  void goLeft() {
    var current = this._x;
    current = this._x + 1;
    this._x = current;
  }

  void goRight() {
    var current = this._x;
    current = this._x - 1;
    this._x = current;
  }

  void goUp() {
    var current = this._y;
    current = this._y + 1;
    this._y = current;
  }

  void goDown() {
    var current = this._y;
    current = this._y - 1;
    this._y = current;
  }
}
