import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bezier/bezier.dart';
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
import 'package:flutter_shaders/game_classes/enemy_driver.dart';
import 'package:flutter_shaders/game_classes/path_follower.dart';
import 'package:flutter_shaders/game_classes/tilemap.dart';
import 'package:flutter_shaders/helpers/utils.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;

import 'package:path_provider/path_provider.dart';
import 'package:performance/performance.dart';
import 'package:dotted_border/dotted_border.dart';

class TowerDefence extends StatefulWidget {
  TowerDefence({required Key key}) : super(key: key);

  @override
  _TowerDefenceState createState() => _TowerDefenceState();
}

class _TowerDefenceState extends State<TowerDefence> with TickerProviderStateMixin {
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

  late AnimationController _bgController;
  late AnimationController _starfieldController;
  final ValueNotifier<Offset> particlePoint = ValueNotifier<Offset>(Offset(0, 0));
  final ValueNotifier<Offset> particlePoint2 = ValueNotifier<Offset>(Offset(0, 0));
  Color _color = Colors.green;
  final _random = new Random();
  int _counter = 0;
  BoxConstraints? viewportConstraints;
  final ValueNotifier<int> counter = ValueNotifier<int>(0);
  Uint8List? testImage;
  ui.Image? bgImage;

  bool isStopped = true; //global
  List<CubicBezier> quadBeziers = [];
  List<TDTower> towers = [];
  @override
  void initState() {
    super.initState();

    // Curves.easeOutBack // explode

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _bgController = AnimationController(vsync: this, duration: Duration(seconds: 1));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      //_letterController.repeat();
      _controller.repeat();

      /// add tower
      towers.add(TDTower(position: Point(120, 500), baseType: "base1", turretType: "cannon1", rof: 800.0, scale: 1));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void updateFn(double point) {
    //Utils.shared.delayedPrint("update received:  $point");
  }

  double calculateY(double y) {
    return viewportConstraints!.maxHeight - (viewportConstraints!.maxHeight - y) - 60;
  }

  List<List<vectorMath.Vector2>> getCurves() {
    if (viewportConstraints != null) {
      List<List<vectorMath.Vector2>> cubicPoints = [
        [
          vectorMath.Vector2(85.7, calculateY(804.0)),
          vectorMath.Vector2(78.9, calculateY(728.0)),
          vectorMath.Vector2(137.1, calculateY(722.3)),
          vectorMath.Vector2(181.1, calculateY(718.3)),
        ],
        [
          vectorMath.Vector2(181.1, calculateY(718.3)),
          vectorMath.Vector2(250.3, calculateY(741.1)),
          vectorMath.Vector2(276.6, calculateY(714.9)),
          vectorMath.Vector2(269.1, calculateY(598.3)),
        ],
        [
          vectorMath.Vector2(269.1, calculateY(598.3)),
          vectorMath.Vector2(269, calculateY(443.4)),
          vectorMath.Vector2(208.6, calculateY(400.1)),
          vectorMath.Vector2(104.0, calculateY(398.1)),
        ],
        [
          vectorMath.Vector2(104.0, calculateY(398.1)),
          vectorMath.Vector2(27, calculateY(415.4)),
          vectorMath.Vector2(16, calculateY(362.1)),
          vectorMath.Vector2(16, calculateY(262.1)),
        ],
        [
          vectorMath.Vector2(16, calculateY(262.1)),
          vectorMath.Vector2(18.9, calculateY(120)),
          vectorMath.Vector2(75.4, calculateY(120)),
          vectorMath.Vector2(151.4, calculateY(120)),
        ]
      ];

      for (var i = 0; i < cubicPoints.length; i++) {
        quadBeziers.add(CubicBezier(cubicPoints[i]));
      }

      return cubicPoints;
    } else {
      return [];
    }
  }

  Widget roundedRectBorderWidget() {
    return DottedBorder(
      strokeWidth: 2,
      color: Colors.green,
      borderType: BorderType.RRect,
      radius: Radius.circular(12),
      padding: EdgeInsets.all(6),
      dashPattern: [12, 2],
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
        child: Container(
          height: 200,
          width: 200,
          color: ui.Color.fromARGB(255, 146, 30, 255),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                _controller.repeat();
              },
              //   onTapCancel: () {
              //     setState(() {
              //       points.add(null);
              //     });
              //   },
              child: Stack(children: [
                Transform.translate(
                    offset: Offset(0, 60),
                    child: CustomPaint(
                      key: UniqueKey(),
                      painter: TileMapPainter(
                        tilesFile: "",
                        csvFile: "",
                        tileSize: Size((viewportConstraints.maxWidth / 7).roundToDouble(), (viewportConstraints.maxWidth / 7).roundToDouble()),
                        controller: _controller,
                        width: viewportConstraints.maxWidth,
                        height: viewportConstraints.maxHeight,
                        fps: 60,
                      ),
                      isComplex: true,
                      willChange: false,
                      child: Container(),
                    )),
                Transform.translate(
                    offset: Offset(0, 40),
                    child: CustomPaint(
                      key: UniqueKey(),
                      painter: EnemyDriverCanvas(
                        controller: _controller,
                        width: viewportConstraints.maxWidth,
                        height: viewportConstraints.maxHeight,
                        update: updateFn,
                        enemies: [
                          TDEnemy(
                              type: "larva",
                              maxCurves: getCurves().length,
                              life: 100,
                              speed: 0.0025,
                              quadBeziers: quadBeziers,
                              scale: 0.25,
                              position: Point<double>(getCurves()[0][0].x, getCurves()[0][0].y))
                        ],
                        towers: towers,
                        fps: 60,
                        curve: getCurves(),
                        quadBeziers: quadBeziers,
                      ),
                      isComplex: true,
                      willChange: false,
                      child: Container(),
                    )),
                // CustomPaint(
                //   key: UniqueKey(),
                //   painter: ShapeMaster(
                //     type: ShapeType.Circle,
                //     size: Size(40, 40),
                //     radius: 40.0,
                //     center: Offset(0, 0),
                //     angle: null,
                //     color: Colors.black,
                //   ),
                //   child: Container(),
                // )
                // Transform.translate(
                //     offset: Offset(110, 110),
                //     child: Container(

                //       height: 200,
                //       width: 200,
                //       color: ui.Color.fromARGB(255, 192, 33, 33),
                //     )),
                // Transform.translate(offset: Offset(100, 100), child: roundedRectBorderWidget()),
              ]),
            );

            //);
          })),
    );
  }
}
