import 'dart:ui';

import 'package:flutter_shaders/helpers/Rectangle.dart';

import '../../helpers/utils.dart';

class TDWorld {
  List<dynamic> _displayList = [];
  // {type:'group|solo', name:'any from display list'}
  //List<Map<String, dynamic>> colliders = [];
  Map<String, List<dynamic>> groups = {};
  Map<String, int> dictionary = {};
  Canvas? _canvas = null;
  Size _worldBounds = Size(0, 0);
  TDWorld() {
    print("world init");
  }

  Canvas? get canvas {
    return this._canvas;
  }

  void set canvas(Canvas? value) {
    this._canvas = value;
  }

  void set worldBounds(Size bounds) {
    this._worldBounds = bounds;
  }

  Size get worldBounds {
    return this._worldBounds;
  }

  List<dynamic> get displayList {
    return _displayList;
  }

  set displayList(List<dynamic> list) {
    _displayList = list;
  }

  String add(dynamic item, String? group) {
    _displayList.add(item);
    print("added ${item}");
    if (group != null) {
      groups[group]?.add(item);
    }

    return _displayList.length.toString();
  }

  void remove(dynamic item, String? group) {
    _displayList.removeWhere((element) => element.id == item.id);
    if (group != null) {
      groups[group]?.removeWhere((element) => element.id == item.id);
    }
  }

  /// Update all items in the display list
  void update() {
    //checkCollisions(colliders);
    int length = _displayList.length;
    for (var i = 0; i < length; i++) {
      if (_displayList[i].alive == true) {
        _displayList[i].update(this.canvas);
      }
    }
  }

  /** 
   * check collision between two elements
  */
  bool checkCollision(Map<String, dynamic> colliders) {
    bool result = false;
    if (colliders['a']['type'] == "solo" && colliders['b']['type'] == "solo") {
      // we should check if collidables are 'alive' probably also
      // if they are on the display list

      var objA = colliders['a']['object'];
      var objB = colliders['b']['object'];

      if (objA.alive == true && objB.alive == true) {
        result = Utils.shared.intersects(objA.getBounds(), objB.getBounds());
      }
      //print(result);
    }

    return result;
  }

  void checkCollisions(List<Map<String, dynamic>> colliders) {
    int length = colliders.length;
    for (var i = 0; i < length; i++) {
      if (colliders[i]['a'].type == "solo" && colliders[i]['b'].type == "solo") {
        var objA = this.displayList[this.dictionary[colliders[i]['a'].name]!];
        var objB = this.displayList[this.dictionary[colliders[i]['b'].name]!];
        bool result = Utils.shared.intersects(objA.getBounds(), objB.getBounds());
        //print(result);
      }
    }
  }
}
