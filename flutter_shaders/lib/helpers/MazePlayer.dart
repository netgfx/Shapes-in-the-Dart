class MazePlayer {
  double _x = 0;
  double _y = 0;
  int blocksize = 0;
  double width;
  double height;
  int pureX = 0;
  int pureY = 0;

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
    this._x = current * this.blocksize;
    this.pureX = current.round();
  }

  void goRight() {
    var current = this._x;
    current = this._x - 1;
    this._x = current * this.blocksize;
    this.pureX = current.round();
  }

  void goTop() {
    var current = this._y;
    current = this._y + 1;
    this._y = current * this.blocksize;
    this.pureY = current.round();
  }

  void goBottom() {
    var current = this._y;
    current = this._y - 1;
    this._y = current * this.blocksize;
    this.pureY = current.round();
  }
}
