import 'package:flutter/material.dart';
import 'package:flutter_shaders/AnimatedBorder.dart';
import 'package:flutter_shaders/BlendModeView.dart';
import 'package:flutter_shaders/GameMode.dart';
import 'package:flutter_shaders/MazeMaker.dart';
import 'package:flutter_shaders/EffectsMode.dart';
import 'package:flutter_shaders/TowerDefence.dart';
import 'package:flutter_shaders/Triangulator.dart';
import 'Menu.dart';
import 'main.dart';

Map<String, Widget Function(BuildContext)> routes = {
  'Main': (context) => MyHomePage(
        title: "Shapes in the Dart",
        key: UniqueKey(),
      ),
  // When navigating to the "/second" route, build the SecondScreen widget.
  'EffectsMode': (context) => EffectsMode(
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
  'TowerDefence': (context) => TowerDefence(key: UniqueKey()),
  'MazeMaker': (context) => MazeMaker(key: UniqueKey())
  //'MessageReply': (context) => MessageReply(key: UniqueKey()),
};
