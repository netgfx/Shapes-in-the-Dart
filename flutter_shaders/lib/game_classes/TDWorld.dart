import 'package:flutter_shaders/helpers/Rectangle.dart';

import '../helpers/utils.dart';

class TDWorld {
  List<dynamic> _displayList = [];
  // {type:'group|solo', name:'any from display list'}
  //List<Map<String, dynamic>> colliders = [];
  Map<String, List<dynamic>> groups = {};
  Map<String, int> dictionary = {};
  TDWorld() {}

  List<dynamic> get displayList {
    return _displayList;
  }

  set displayList(List<dynamic> list) {
    _displayList = list;
  }

  void add(dynamic item, String? group) {
    _displayList.add(item);
    dictionary[item.name] = _displayList.length - 1;
    if (group != null) {
      groups[group]?.add(item);
    }
  }

  void update(canvas, List<Map<String, dynamic>> colliders) {
    checkCollisions(colliders);
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
    for (var i = 0; i < colliders.length; i++) {
      if (colliders[i]['a'].type == "solo" && colliders[i]['b'].type == "solo") {
        var objA = this.displayList[this.dictionary[colliders[i]['a'].name]!];
        var objB = this.displayList[this.dictionary[colliders[i]['b'].name]!];
        bool result = Utils.shared.intersects(objA.getBounds(), objB.getBounds());
        //print(result);
      }
    }
  }
}
