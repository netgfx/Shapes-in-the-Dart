import 'dart:math';
import 'dart:ui';

class GroupController {
  Point<double> position = Point(0, 0);
  Size _size = Size(0, 0);
  bool _interactive = false;
  Function? _onEvent;
  int _zIndex = 0;
  String _id = "";
  List<dynamic> items = [];
  bool _alive = false;

  GroupController({required this.position, interactive, onEvent, zIndex, items, startAlive}) {
    this.interactive = interactive ?? false;
    this.onEvent = onEvent ?? null;
    this.zIndex = zIndex ?? 0;
    this.alive = startAlive ?? false;
    this.size = this._calculateSize();
  }

  String get id {
    return this._id;
  }

  set id(String value) {
    this._id = value;
  }

  bool get alive {
    return _alive;
  }

  set alive(bool value) {
    _alive = value;
  }

  bool get interactive {
    return _interactive;
  }

  void set interactive(bool value) {
    this._interactive = value;
  }

  void set onEvent(Function? value) {
    this._onEvent = value;
  }

  Function? get onEvent {
    return this._onEvent;
  }

  void set size(Size value) {
    this._size = value;
  }

  Size get size {
    return this._size;
  }

  void set zIndex(int value) {
    this._zIndex = value;
  }

  int get zIndex {
    return this._zIndex;
  }

  void addItem(dynamic item) {
    this.items.add(item);
  }

  void removeItemById(String id) {
    this.items.removeWhere((element) => element.id == id);
  }

  void removeItemByIndex(int index) {
    this.items.removeAt(index);
  }

  Size _calculateSize() {
    double width = 0;
    double height = 0;

    for (var item in this.items) {
      // check the further x+width for max
      if (item.x + item.size.width > width) {
        width = item.x + item.size.width;
      }

      if (item.y + item.size.height > height) {
        height = item.y + item.size.height;
      }
    }

    print("group size is: $width, $height");

    return Size(width, height);
  }

  // update function
  void update(Canvas canvas, {double elapsedTime = 0.0, bool shouldUpdate = true}) {
    for (var item in this.items) {
      item.position = Point(this.position.x + item.position.x, this.position.y + item.position.y);
      item.update(canvas, elapsedTime: elapsedTime, shouldUpdate: shouldUpdate);
    }
  }
}
