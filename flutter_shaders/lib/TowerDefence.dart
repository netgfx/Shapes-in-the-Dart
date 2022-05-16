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
import 'package:flutter_shaders/game_classes/path_follower.dart';
import 'package:flutter_shaders/helpers/border.dart';

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
  String batFirstFrame = "fly/Fly2_Bats";
  bool batLoop = true;
  Map<String, dynamic> spriteCache = {};
  Point lightSource = Point(50, 50);

  @override
  void initState() {
    super.initState();

    // Curves.easeOutBack // explode

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _bgController = AnimationController(vsync: this, duration: Duration(seconds: 1));

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      //_letterController.repeat();
      _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Color randomColor(double alpha) {
    int r = (_random.nextDouble() * 255).floor();
    int g = (_random.nextDouble() * 255).floor();
    int b = (_random.nextDouble() * 255).floor();
    int a = (alpha * 255).floor();

    return Color.fromARGB(a, r, g, b);
  }

  void _onPanUpdate(BuildContext context, DragUpdateDetails details) {
    //checkCollision();
    setState(() {
      lightSource = Point(details.localPosition.dx, details.localPosition.dy);
    });
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
            return Stack(children: [
              Transform.translate(
                  offset: Offset(0, 40),
                  child: CustomPaint(
                    key: UniqueKey(),
                    painter: PathFollowerCanvas(
                      controller: _controller,
                      width: viewportConstraints.maxWidth,
                      height: viewportConstraints.maxHeight,
                      fps: 60,
                      color: Colors.black,
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
            ]);

            //);
          })),
    );
  }
}
