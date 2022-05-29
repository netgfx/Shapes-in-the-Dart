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
import 'package:flutter_shaders/SpriteAnimator.dart';
import 'package:flutter_shaders/Starfield.dart';
import 'package:flutter_shaders/game_classes/flip_image.dart';
import 'package:flutter_shaders/game_classes/thunder_painter.dart';
import 'package:flutter_shaders/game_classes/tilemap.dart';
import 'package:flutter_shaders/helpers/utils.dart';

import 'package:path_provider/path_provider.dart';
import 'package:performance/performance.dart';

import 'ShapeMaster.dart';
import 'SpriteWidget.dart';

class GameMode extends StatefulWidget {
  GameMode({required Key key}) : super(key: key);

  @override
  _GameModeState createState() => _GameModeState();
}

class _GameModeState extends State<GameMode> with TickerProviderStateMixin {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 50.0;
  List<DrawingPoints?> points = [];
  bool showBottomList = false;
  double opacity = 1.0;
  List<ui.Image> spriteImages = [];
  StrokeCap strokeCap = StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.amber, Colors.black];
  Map<String, dynamic>? mazeData;
  late AnimationController _controller;

  late AnimationController _bgController;

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
  Map<String, ui.Image> textureCache = {};
  Map<String, dynamic>? imageData;
  final ValueNotifier<Map<String, dynamic>> spriteDirection = ValueNotifier<Map<String, dynamic>>({
    "direction": "PlayerDownStand/ds",
    "x": 0.0,
    "y": 0.0,
    "oldX": 0.0,
    "oldY": 0.0,
    "loop": true,
    "fps": 5,
    "endFrameName": null,
  });

  ///
  CharacterParticleEffect lettersEffect = CharacterParticleEffect.SPREAD;
  @override
  void initState() {
    super.initState();

    // Curves.easeOutBack // explode

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _bgController = AnimationController(vsync: this, duration: Duration(seconds: 1));

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      //initScrollBG();

      getImageDataFromAtlas();
      _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();

    super.dispose();
  }

  void getImageDataFromAtlas() async {
    var data = await Utils.shared.loadSprite("runes", "assets/runes.json", "assets/runes.png", [
      "grey",
      "red",
    ], (img, texture) {
      print("image saved on cache");
    }, (name, texture) {});

    if (mounted) {
      setState(() {
        imageData = data;
      });
    }
  }

  Color randomColor(double alpha) {
    int r = (_random.nextDouble() * 255).floor();
    int g = (_random.nextDouble() * 255).floor();
    int b = (_random.nextDouble() * 255).floor();
    int a = (alpha * 255).floor();

    return Color.fromARGB(a, r, g, b);
  }

  void initScrollBG() async {
    await loadImages(["assets/forest.png"]);
    _bgController.repeat();
  }

  List<Widget> getCircles() {
    List<Widget> finalList = [];

    for (var i = 0; i < points.length; i++) {
      if (points[i] == null) {
        continue;
      }
      finalList.add(
        Transform.translate(
            offset: Offset(points[i]!.points.dx - 20, points[i]!.points.dy - 20),
            child: PhysicalModel(
                color: Colors.yellow,
                shape: BoxShape.circle,
                elevation: 5,
                shadowColor: Colors.orange.shade300,
                child: Container(
                  key: UniqueKey(),
                  width: 40,
                  height: 40,
                  constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black, // Color does not matter but should not be transparent
                      //borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(blurRadius: 4, offset: const Offset(0, 0), color: Colors.black, spreadRadius: 2),
                        BoxShadow(blurRadius: 2, offset: const Offset(0, 0), color: Colors.black, spreadRadius: 8)
                      ]),
                  child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.yellow.withOpacity(0.0),
                            Colors.yellow.withOpacity(0.6),
                          ],
                          center: AlignmentDirectional(0.0, 0.0),
                          focal: AlignmentDirectional(0.0, 0.0),
                          radius: 0.6,
                          focalRadius: 0.001,
                          stops: [0.75, 1.0],
                        ),
                      )),
                ))),
      );
    }

    return finalList;
  }

  Future<void> loadImages(List<String> data) async {
    var futures = <Future<ui.Image>>[];
    print(rootBundle.toString());
    for (var d in data) {
      final ByteData data = await rootBundle.load(d);
      Future<ui.Image> image = loadImage(new Uint8List.view(data.buffer));
      futures.add(image);
    }
    //Image memImg;
    Future<ByteData?> bits;

    var callback = Future.wait(futures);
    ui.Image img;
    callback.then((values) => {
          setState(() => {bgImage = values[0]}),
          bits = values[0].toByteData(format: ui.ImageByteFormat.png),
          bits.then((value) => {
                //memImg = Image.memory(value!.buffer.asUint8List()),

                if (mounted)
                  {
                    spriteImages = values,
                    print("setting image $value"),
                  }
              })
        });
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  sec5Timer() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (isStopped) {
        timer.cancel();
      }

      if (_counter >= 5) {
        setState(() {
          isStopped = true;
        });
      } else {
        _controller.repeat();
        showParticles();
      }
    });
  }

  void showParticles() {
    print(viewportConstraints);
    if (viewportConstraints != null) {
      double randX = doubleInRange(50, viewportConstraints!.maxWidth - 50);
      double randY = doubleInRange(50, viewportConstraints!.maxHeight / 2);
      double rand2X = doubleInRange(50, viewportConstraints!.maxWidth - 50);
      double rand2Y = doubleInRange(50, viewportConstraints!.maxHeight / 2);
      particlePoint.value = Offset(randX, randY);
      particlePoint2.value = Offset(rand2X, rand2Y);

      _counter++;
    }
  }

  double doubleInRange(double start, double end) {
    if (start == end) {
      return start;
    } else {
      return _random.nextDouble() * (end - start) + start;
    }
  }

  void playFly() {
    setState(() {
      batFirstFrame = "fly/Fly2_Bats";
      batLoop = true;
    });
  }

  void playExplode() {
    setState(() {
      batFirstFrame = "death/Death_animations";
      batLoop = false;
    });
  }

  void cacheSpriteImages(String uniqueKey, Map<String, List<Map<String, dynamic>>> images) {
    spriteCache[uniqueKey] = images;
    print("Saved $uniqueKey with ${images.length} images to cache");
  }

  void cacheSpriteTexture(String uniqueKey, ui.Image texture) {
    this.textureCache[uniqueKey] = texture;
    print("Saved $uniqueKey texture to cache");
  }

  void _onPanUpdate(BuildContext context, DragUpdateDetails details) {
    //checkCollision();
  }

  void animationUpdate() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      spriteDirection.value["oldX"] = spriteDirection.value["x"];
      spriteDirection.value["oldY"] = spriteDirection.value["y"];
      spriteDirection.value["direction"] = spriteDirection.value["endFrameName"];
      spriteDirection.value["loop"] = true;
      spriteDirection.value["fps"] = 5;
      spriteDirection.value["endFrameName"] = null;
      print(spriteDirection.value["direction"]);
      spriteDirection.notifyListeners();
    });
  }

  List<Widget> makeRunes() {
    List<Widget> list = [];
    int count = 0;

    list.add(
      CustomPaint(
        //key: UniqueKey(),
        painter: FlipImage(
          controller: this._controller,
          imageData: this.imageData!,
          front: "grey",
          back: "red",
          fps: 60,
          delay: 1000 + 150 * count, //Utils.shared.randomDelay(min: 1000, max: 2000).ceil(),
          ease: Easing.EASE_OUT_CUBIC,
        ),

        isComplex: true,
        willChange: false,
        child: Container(),
      ),
    );

    return list;

    // for (var i = 0; i < 4; i++) {
    //   for (var j = 0; j < 3; j++) {
    //     list.add(
    //       CustomPaint(
    //         //key: UniqueKey(),
    //         painter: FlipImage(
    //           controller: this._controller,
    //           imageData: this.imageData!,
    //           front: "grey",
    //           back: "red",
    //           fps: 60,
    //           delay: 1000 + 150 * count, //Utils.shared.randomDelay(min: 1000, max: 2000).ceil(),
    //           ease: Easing.EASE_OUT_CUBIC,
    //         ),

    //         isComplex: true,
    //         willChange: false,
    //         child: Container(),
    //       ),
    //     );
    //     count += 1;
    //   }
    // }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPerformanceOverlay(
      child: Scaffold(
          backgroundColor: Colors.grey.shade800,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), color: Colors.black),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                              color: Colors.white,
                              icon: Icon(Icons.chevron_left),
                              onPressed: () {
                                spriteDirection.value["direction"] = "PlayerLeftMove/lm";
                                spriteDirection.value["endFrameName"] = "PlayerLeftStand/ls";
                                spriteDirection.value["fps"] = 13;
                                spriteDirection.value["loop"] = false;

                                spriteDirection.value["oldX"] = spriteDirection.value["x"];
                                spriteDirection.value["oldY"] = spriteDirection.value["y"];
                                spriteDirection.value["x"] = spriteDirection.value["x"] - 16;

                                spriteDirection.notifyListeners();
                              }),
                          Column(
                            children: [
                              IconButton(
                                  color: Colors.white,
                                  icon: Icon(Icons.expand_less),
                                  onPressed: () {
                                    spriteDirection.value["direction"] = "PlayerUpMove/um";
                                    spriteDirection.value["endFrameName"] = "PlayerUpStand/us";
                                    spriteDirection.value["fps"] = 13;
                                    spriteDirection.value["loop"] = false;
                                    spriteDirection.value["oldX"] = spriteDirection.value["x"];
                                    spriteDirection.value["oldY"] = spriteDirection.value["y"];
                                    spriteDirection.value["y"] = spriteDirection.value["y"] - 16;

                                    spriteDirection.notifyListeners();
                                  }),
                              IconButton(
                                  color: Colors.white,
                                  icon: Icon(Icons.expand_more),
                                  onPressed: () {
                                    spriteDirection.value["direction"] = "PlayerDownMove/dm";
                                    spriteDirection.value["endFrameName"] = "PlayerDownStand/ds";
                                    spriteDirection.value["fps"] = 13;
                                    spriteDirection.value["loop"] = false;

                                    spriteDirection.value["oldX"] = spriteDirection.value["x"];
                                    spriteDirection.value["oldY"] = spriteDirection.value["y"];
                                    spriteDirection.value["y"] = spriteDirection.value["y"] + 16;

                                    spriteDirection.notifyListeners();
                                  }),
                            ],
                          ),
                          IconButton(
                              color: Colors.white,
                              icon: Icon(Icons.chevron_right),
                              onPressed: () {
                                spriteDirection.value["direction"] = "PlayerRightMove/rm";
                                spriteDirection.value["endFrameName"] = "PlayerRightStand/rs";
                                spriteDirection.value["fps"] = 13;
                                spriteDirection.value["loop"] = false;
                                spriteDirection.value["oldX"] = spriteDirection.value["x"];
                                spriteDirection.value["oldY"] = spriteDirection.value["y"];

                                spriteDirection.value["x"] = spriteDirection.value["x"] + 16;

                                spriteDirection.notifyListeners();
                              }),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
          body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
            this.viewportConstraints = viewportConstraints;
            return GestureDetector(
              //   onTapDown: (details) {
              //     // setState(() {
              //     //   particlePoint = details.globalPosition;
              //     // });
              //     particlePoint.value = details.globalPosition;
              //     _controller.repeat();
              //   },
              //   onTapCancel: () {
              //     setState(() {
              //       points.add(null);
              //     });
              //   },

              onPanUpdate: (details) => _onPanUpdate(context, details),
              //   setState(() {
              //     RenderBox? renderBox = context.findRenderObject() as RenderBox;
              //     points.add(DrawingPoints(
              //         points: renderBox.globalToLocal(details.globalPosition),
              //         paint: Paint()
              //           ..strokeCap = strokeCap
              //           ..isAntiAlias = true
              //           ..color = selectedColor.withOpacity(opacity)
              //           ..strokeWidth = strokeWidth));
              //   });
              // },
              // onPanStart: (details) {
              //   setState(() {
              //     RenderBox renderBox = context.findRenderObject() as RenderBox;
              //     points.add(DrawingPoints(
              //         points: renderBox.globalToLocal(details.globalPosition),
              //         paint: Paint()
              //           ..strokeCap = strokeCap
              //           ..isAntiAlias = true
              //           ..color = selectedColor.withOpacity(opacity)
              //           ..strokeWidth = strokeWidth));
              //   });
              // },
              // onPanEnd: (details) {
              //   setState(() {
              //     points.add(null);
              //   });
              // },
              child: Stack(children: [
                this.imageData != null
                    ? Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: GridView.count(
                            crossAxisCount: 3,
                            // Generate 100 widgets that display their index in the List.
                            children: makeRunes()),
                      )
                    : Container(),

                /// STARFIELD
                // Positioned(
                //   top: 0,
                //   left: 0,
                //   child: Padding(
                //     padding: EdgeInsets.only(top: 0, left: 0),
                //     child: CustomPaint(
                //       key: UniqueKey(),
                //       painter: ThunderPainter(
                //         controller: _controller,
                //         color: Colors.white,
                //         fps: 30,
                //         animate: () => {},
                //       ),
                //     ),
                //   ),
                // ),
                // ValueListenableBuilder<Map<String, dynamic>>(
                //   valueListenable: spriteDirection,
                //   builder: (BuildContext context, Map<String, dynamic> value, Widget? child) {
                //     print(value);
                //     return SpriteWidget(
                //         //key: UniqueKey(),
                //         constraints: {
                //           "width": viewportConstraints.maxWidth.toInt(),
                //           "height": viewportConstraints.maxHeight.toInt(),
                //         },
                //         directionObject: value,
                //         texturePath: "assets/knight.png",
                //         jsonPath: "assets/knight.json",
                //         delimiters: [
                //           "PlayerDownMove/dm",
                //           "PlayerDownStand/ds",
                //           "PlayerLeftMove/lm",
                //           "PlayerLeftStand/ls",
                //           "PlayerRightMove/rm",
                //           "PlayerRightStand/rs",
                //           "PlayerUpMove/um",
                //           "PlayerUpStand/us",
                //         ],
                //         startFrameName: spriteDirection.value["direction"],
                //         endFrameName: spriteDirection.value["endFrameName"],
                //         loop: spriteDirection.value["loop"],
                //         scale: 0.80,
                //         position: Offset(spriteDirection.value["x"] as double, spriteDirection.value["y"] as double),
                //         desiredFPS: spriteDirection.value["fps"],
                //         setTextureCache: cacheSpriteTexture,
                //         setCache: cacheSpriteImages,
                //         endAnimationCallback: animationUpdate,
                //         cache: spriteCache["knight"],
                //         textureCache: this.textureCache["knight"],
                //         name: "knight");
                //   },
                // ),
              ]),
            );
            //);
          })),
    );
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({required this.pointsList});
  List<DrawingPoints?> pointsList;
  List<Offset> offsetPoints = [];
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        var path = Path();
        path.addOval(Rect.fromCircle(center: pointsList[i]!.points, radius: 25.0));
        //canvas.drawLine(pointsList[i]!.points, pointsList[i + 1]!.points, pointsList[i]!.paint);
        canvas.drawShadow(path.shift(Offset(pointsList[i]!.points.dx - 5, pointsList[i]!.points.dy - 5)), Colors.black54, 5.0, true);
        canvas.drawPath(path, pointsList[i]!.paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        // offsetPoints.add(pointsList[i]!.points);
        // offsetPoints.add(Offset(pointsList[i]!.points.dx + 0.1, pointsList[i]!.points.dy + 0.1));
        // canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i]!.paint);
        var path = Path();
        path.addOval(Rect.fromCircle(center: pointsList[i]!.points, radius: 25.0));
        canvas.drawShadow(path, Colors.black87, 5.0, true);
        canvas.drawPath(path, pointsList[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({required this.points, required this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }
