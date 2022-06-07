import 'package:flutter_shaders/game_classes/TDWorld.dart';

class GameObject {
  static GameObject shared = GameObject._();
  GameObject._();

  static GameObject get instance => shared;

  ///
  TDWorld? world = null;

  ///

  setWorld(TDWorld value) {
    this.world = value;
  }

  TDWorld? getWorld() {
    return this.world;
  }
}
