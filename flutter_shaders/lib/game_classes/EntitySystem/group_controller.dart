import 'dart:math';
import 'dart:ui';

import 'package:flutter_shaders/helpers/Rectangle.dart';
import 'package:vector_math/vector_math.dart';

class GroupController {
  Point<double> position = Point(0, 0);
  Size _size = Size(0, 0);
  bool _interactive = false;
  Function? _onEvent;
  int _zIndex = 0;
  String _id = "";
  List<dynamic> items = [];
  bool _alive = false;
  Offset _centerOffset = Offset(0, 0);
  bool enableDebug = false;

  GroupController(
      {required this.position,
      interactive,
      onEvent,
      zIndex,
      items,
      startAlive,
      centerOffset,
      enableDebug}) {
    this.interactive = interactive ?? false;
    this.onEvent = onEvent ?? null;
    this.zIndex = zIndex ?? 0;
    this.alive = startAlive ?? false;
    this._centerOffset = centerOffset ?? Offset(0, 0);
    this.enableDebug = enableDebug ?? false;
    this.size = this._calculateSize();
  }

  String get id {
    return this._id;
  }

  set id(String value) {
    this._id = value;
  }

  bool get alive {
    return this._alive;
  }

  set alive(bool value) {
    this._alive = value;
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

  void addItem(Point<double> position, dynamic item) {
    this.items.add({
      "object": item,
      "groupPosition": position,
    });
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
      if (item["object"].position.x + item["object"].size.width > width) {
        width = item["groupPosition"].x + item["object"].size.width;
      }

      if (item["object"].position.y + item["object"].size.height > height) {
        height = item["groupPosition"].y + item["object"].size.height;
      }

      //print("${item.size}");
    }

    return Size(width, height);
  }

  // update function
  void update(Canvas canvas,
      {double elapsedTime = 0.0, bool shouldUpdate = true}) {
    for (var item in this.items) {
      item["object"].position = Point(this.position.x + item["groupPosition"].x,
          this.position.y + item["groupPosition"].y);
      item["object"]
          .update(canvas, elapsedTime: elapsedTime, shouldUpdate: shouldUpdate);
    }
    this.size = _calculateSize();
    if (enableDebug == true) {
      drawDebugRect(canvas);
    }
  }

  void drawDebugRect(Canvas canvas) {
    final Paint border = Paint()
      ..color = Color.fromRGBO(0, 255, 0, 1.0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 2;
    updateCanvas(canvas, 0, 0, null, () {
      //print("group size is: ${this.size.width}, ${this.size.height}");
      canvas.drawRect(
          Rect.fromLTWH(this.position.x, this.position.y, this.size.width,
              this.size.height),
          border);
    });
  }

  void updateCanvas(Canvas canvas, double? x, double? y, double? rotate,
      VoidCallback callback,
      {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas.save();

    if (translate) {
      canvas.translate(_x, _y);
    }

    if (rotate != null) {
      canvas.translate(_x, _y);
      canvas.rotate(rotate);
    }
    callback();
    canvas.restore();
  }
}
