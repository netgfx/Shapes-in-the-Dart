import 'package:flutter/material.dart';
import 'package:flutter_shaders/AnimatedBorder.dart';
import 'package:flutter_shaders/BlendModeView.dart';
import 'package:flutter_shaders/GameMode.dart';
import 'package:flutter_shaders/MazeMode.dart';
import 'package:flutter_shaders/Triangulator.dart';
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
  'GameMode': (context) => GameMode(
        key: UniqueKey(),
      ),
  'AnimatedBorder': (context) => AnimatedBorder(
        key: UniqueKey(),
      ),
  'BlendMode': (context) => BlendModeView(
        key: UniqueKey(),
      ),
  'Menu': (context) => Menu(
        key: UniqueKey(),
      ),
  'Triangulator': (context) => Triangulator(
        key: UniqueKey(),
      ),
  //'MessageReply': (context) => MessageReply(key: UniqueKey()),
};
