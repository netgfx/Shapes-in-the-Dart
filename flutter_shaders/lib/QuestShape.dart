import 'dart:ui';

import 'package:flutter/material.dart';

import 'ShapeMaster.dart';

class QuestShape {
  bool isFound = false;
  Color color = Colors.white;
  ShapeType type = ShapeType.Rect;

  QuestShape(ShapeType type, Color color, bool isFound) {
    this.type = type;
    this.color = color;
    this.isFound = isFound;
  }

  void setFound(bool found) {
    this.isFound = found;
  }

  bool getFound() {
    return this.isFound;
  }

  void setColor(Color color) {
    this.color = color;
  }

  ShapeType getShape() {
    return this.type;
  }

  Color getColor() {
    return this.color;
  }
}
