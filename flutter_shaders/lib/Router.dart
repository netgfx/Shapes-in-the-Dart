import 'package:flutter/material.dart';
import 'package:flutter_shaders/MazeMode.dart';
import 'Menu.dart';
import 'main.dart';

Map<String, Widget Function(BuildContext)> routes = {
  'Main': (context) => MyHomePage(
        title: "Shapes in the Dart",
        key: UniqueKey(),
      ),
  // When navigating to the "/second" route, build the SecondScreen widget.
  'MazeMode': (context) => MazeMode(
        key: UniqueKey(),
      ),
  'Menu': (context) => Menu(
        key: UniqueKey(),
      ),
  //'MessageReply': (context) => MessageReply(key: UniqueKey()),
};
