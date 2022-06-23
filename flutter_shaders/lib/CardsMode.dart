import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/AnimatedBackground.dart';
import 'package:flutter_shaders/BGAnimator.dart';
import 'package:flutter_shaders/LetterParticles.dart';
import 'package:flutter_shaders/MazeGenerator.dart';
import 'package:flutter_shaders/MazePainter.dart';
import 'package:flutter_shaders/ParticleEmitter.dart';
import 'package:flutter_shaders/PhysicsEngine.dart';
import 'package:flutter_shaders/Shadows.dart';
import 'package:flutter_shaders/ShapeMaster.dart';
import 'package:flutter_shaders/SpriteAnimator.dart';
import 'package:flutter_native_image/flutter_native_image.dart' as uiImage;
import 'package:flutter_shaders/Starfield.dart';
import 'package:flutter_shaders/game_classes/TDEnemy.dart';
import 'package:flutter_shaders/game_classes/TDTower.dart';
import 'package:flutter_shaders/game_classes/TDWorld.dart';
import 'package:flutter_shaders/game_classes/enemy_driver.dart';
import 'package:flutter_shaders/game_classes/maze/maze_draw.dart';
import 'package:flutter_shaders/game_classes/path_follower.dart';
import 'package:flutter_shaders/game_classes/Tilemap.dart';
import 'package:flutter_shaders/game_classes/pathfinding/BFS.dart';
import 'package:flutter_shaders/game_classes/pathfinding/MazeLocation.dart' as ML;
import 'package:flutter_shaders/helpers/GameObject.dart';
import 'package:flutter_shaders/helpers/math/CubicBezier.dart';
import 'package:flutter_shaders/helpers/utils.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import 'package:simple_animations/simple_animations.dart';

/// test
import 'package:flutter_shaders/game_classes/maze/maze_builder.dart';

import 'package:path_provider/path_provider.dart';
import 'package:performance/performance.dart';
import 'package:dotted_border/dotted_border.dart';

import 'game_classes/pathfinding/MazeGrid.dart';
import 'game_classes/pathfinding/MazeNode.dart';

enum AniProps { rX, rY, rZ, scale }

class CardsMode extends StatefulWidget {
  CardsMode({required Key key}) : super(key: key);

  @override
  _CardsModeState createState() => _CardsModeState();
}

class _CardsModeState extends State<CardsMode> with TickerProviderStateMixin {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 50.0;
  bool showBottomList = false;
  double opacity = 1.0;
  List<ui.Image> spriteImages = [];
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.round : StrokeCap.round;
  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.amber, Colors.black];
  Map<String, dynamic>? mazeData;
  late AnimationController _controller;
  late AnimationController _starfieldController;
  final ValueNotifier<Offset> particlePoint = ValueNotifier<Offset>(Offset(0, 0));
  final ValueNotifier<Offset> particlePoint2 = ValueNotifier<Offset>(Offset(0, 0));
  Color _color = Colors.green;
  final _random = new Random();
  int _counter = 0;
  BoxConstraints? viewportConstraints;
  final ValueNotifier<int> counter = ValueNotifier<int>(0);
  List<List<Cell>> finalMaze = [];
  List<ML.MazeLocation> mazeSolution = [];
  bool isStopped = true; //global
  Offset _offset = Offset(0.1, 0.1);

  ///
  Duration _elapsed = Duration.zero;
  // 2. declare Ticker
  late final Ticker _ticker;

  TimelineTween<AniProps> createTween() => TimelineTween<AniProps>()
    ..addScene(begin: Duration.zero, end: const Duration(milliseconds: 2000))
        .animate(AniProps.rX, tween: Tween<double>(begin: 2.0 - 0.12, end: 0.0))
        .animate(AniProps.rY, tween: Tween<double>(begin: 0.01, end: 0))
        .animate(AniProps.rZ, tween: Tween<double>(begin: 2.0 + 0.25, end: 0))
        .animate(AniProps.scale, tween: Tween<double>(begin: 1.0, end: 2.0));

  @override
  void initState() {
    super.initState();

    // 3. initialize Ticker
    _ticker = this.createTicker((elapsed) {
      // 4. update state
      setState(() {
        _elapsed = elapsed;
      });

      var tween = createTween();
    });
    // 5. start ticker
    //_ticker.start();
    // Curves.easeOutBack // explode

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      //_letterController.repeat();
      //_controller.forward();

      /// generate maze
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void updateFn(double point) {
    //Utils.shared.delayedPrint("update received:  $point");
  }

  @override
  Widget build(BuildContext context) {
    var tween = createTween();

    return CustomPerformanceOverlay(
      child: Scaffold(
          backgroundColor: ui.Color.fromARGB(255, 255, 255, 255),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), color: ui.Color.fromARGB(255, 255, 255, 255)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[],
                      ),
                    ],
                  ),
                )),
          ),
          body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
            this.viewportConstraints = viewportConstraints;
            return GestureDetector(
              onTapDown: (details) {
                print("POINT OF CONTACT: ${details.globalPosition}");
                // _controller.repeat();
              },
              child: Stack(children: [
                Transform.translate(
                  offset: Offset(50, 100),
                  child: PlayAnimation<TimelineValue<AniProps>>(
                      delay: Duration(milliseconds: 500),
                      tween: tween, // define tween
                      //duration: const Duration(seconds: 2), // define duration
                      builder: (context, child, value) {
                        return Transform(
                          // Transform widget
                          transform: Matrix4.identity()
                            //..setEntry(3, 2, 0.001) // perspective
                            ..scale(value.get(AniProps.scale))
                            ..rotateX(value.get(AniProps.rX))
                            ..rotateY(value.get(AniProps.rY))
                            ..rotateZ(value.get(AniProps.rZ)),
                          alignment: FractionalOffset.center,
                          child: Stack(children: [
                            Container(
                              width: 200,
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xff7c94b6),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 8,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            Container(
                              width: 200,
                              height: 150,
                              decoration: BoxDecoration(
                                color: ui.Color.fromARGB(255, 239, 223, 10),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 8,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ]),
                        );
                      }),
                ),
              ]),
            );

            //);
          })),
    );
  }
}
