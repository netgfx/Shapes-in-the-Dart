import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/MazeGenerator.dart';
import 'package:flutter_shaders/MazePainter.dart';
import 'package:flutter_shaders/ParticleEmitter.dart';
import 'package:flutter_shaders/SpriteAnimator.dart';
import 'package:flutter_native_image/flutter_native_image.dart' as uiImage;
import 'package:flutter_shaders/SpriteWidget.dart';
import 'package:path_provider/path_provider.dart';

import 'MazeGeneratorV2.dart';
import 'ShapeMaster.dart';

class MazeMode extends StatefulWidget {
  MazeMode({required Key key}) : super(key: key);

  @override
  _MazeModeState createState() => _MazeModeState();
}

class _MazeModeState extends State<MazeMode> with TickerProviderStateMixin {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 50.0;
  List<DrawingPoints?> points = [];
  bool showBottomList = false;
  double opacity = 1.0;
  List<ui.Image> spriteImages = [];
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.round : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.amber, Colors.black];
  Map<String, dynamic>? mazeData;
  late AnimationController _controller;
  late AnimationController _spriteController;
  Offset particlePoint = Offset(0, 0);
  Color _color = Colors.green;
  final _random = new Random();
  int sliceWidth = 192;
  int sliceHeight = 212;
  late Uint8List testImage;
  @override
  void initState() {
    super.initState();

    MazeGeneratorV2 mzg = MazeGeneratorV2(4, 6, 57392);
    // Curves.easeOutBack // explode
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _spriteController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    //_controller.addListener(() {setState(() {});}); no need to setState
    //_controller.drive(CurveTween(curve: Curves.bounceIn));
    _spriteController.repeat();
    //_controller.forward();
    //mazeData = mzg.init();
    List<String> imagePaths = [];
    // for (var i = 1; i < 19; i++) {
    //   if (i >= 10) {
    //     imagePaths.add("assets/monster/monster1_" + i.toString() + ".png");
    //   } else {
    //     imagePaths.add("assets/monster/monster1_0" + i.toString() + ".png");
    //   }
    // }

    loadSprite();

    //print(mazeData);
  }

  void loadSprite() async {
    List<Map<String, dynamic>> spriteData;
    File imageData = await loadImageTexture("assets/flying_monster.png");
    var data = loadJsonData();
    data.then((value) => {spriteData = parseJSON(value), loadSpriteImage(spriteData, imageData)});
  }

  Future<File> loadImageTexture(String spriteTexture) async {
    final ByteData data = await rootBundle.load(spriteTexture);

    String dir = (await getApplicationDocumentsDirectory()).path;
    File path = await writeToFile(data, '$dir/tempfile1.png');

    return path;
  }

  void loadSpriteImage(List<Map<String, dynamic>> spriteData, File path) async {
    uiImage.ImageProperties props = await uiImage.FlutterNativeImage.getImageProperties(path.path);

    print("${props.width} ${props.height} ${spriteData.length}");
    if (props.width != null && spriteData.length == 0) {
      for (var i = 0; i < props.width! / sliceWidth; i++) {
        File croppedFile = await uiImage.FlutterNativeImage.cropImage(path.path, sliceWidth * i, 0, sliceWidth, sliceHeight);

        Uint8List bytes = croppedFile.readAsBytesSync();
        ui.Image image = await loadImage(bytes);
        spriteImages.add(image);
      }
    } else {
      spriteImages.clear();

      /// do split based on json data x, y
      for (var i = 0; i < spriteData.length; i++) {
        print("${spriteData[i]["width"]}, ${spriteData[i]["height"]}");
        File croppedFile = await uiImage.FlutterNativeImage.cropImage(path.path, spriteData[i]['x'], spriteData[i]['y'], spriteData[i]["width"], spriteData[i]['height']);

        Uint8List bytes = croppedFile.readAsBytesSync();
        ui.Image image = await loadImage(bytes);
        spriteImages.add(image);
      }
    }

    if (mounted) {
      setState(() => {});

      try {
        if (spriteImages.length > 0) {
          // await path.delete(recursive: false);
        }
        print("deleted file");
      } catch (e) {
        print("error");
      }
    }

    //ui.decodeImageFromList(imgData, (result) {
    //spriteImages.add(imgData);
    //print(result);
    //var testImg = (result).toByteData(format: ui.ImageByteFormat.png);
    // testImg.then((value) => {
    //       setState(() => {testImage = value!.buffer.asUint8List()})
    //     });
    // });
  }

  Future<Map<String, dynamic>> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/flying_monster.json');
    Map<String, dynamic> data = json.decode(jsonText);
    return data;
  }

  List<Map<String, dynamic>> parseJSON(Map<String, dynamic> data) {
    List<Map<String, dynamic>> sprites = [];
    data["frames"].forEach((key, value) {
      final frameData = value['frame'];
      final int x = frameData['x'];
      final int y = frameData['y'];
      final int width = frameData['w'];
      final int height = frameData['h'];
      sprites.add({"x": x, "y": y, "width": width, "height": height});
    });

    print(sprites);
    return sprites;
  }

//write to app path
  Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  void dispose() {
    _controller.dispose();
    _spriteContro
     


    super.dispose();
  }

  Color randomColor(double alpha) {
    int r = (_random.nextDouble() * 255).floor();
    int g = (_random.nextDouble() * 255).floor();
    int b = (_random.nextDouble() * 255).floor();
    int a = (alpha * 255).floor();

    return Color.fromARGB(a, r, g, b);
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
                      boxShadow: [BoxShadow(blurRadius: 4, offset: const Offset(0, 0), color: Colors.black, spreadRadius: 2), BoxShadow(blurRadius: 2, offset: const Offset(0, 0), color: Colors.black, spreadRadius: 8)]),
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
    callback.then((values) => {
          bits = values[0].toByteData(format: ui.ImageByteFormat.png),
          bits.then((value) => {
                //memImg = Image.memory(value!.buffer.asUint8List()),

                if (mounted)
                  {
                    spriteImages = values,
                    print("setting image $value"),
                    setState(() => {testImage = value!.buffer.asUint8List()})
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            icon: Icon(Icons.album),
                            onPressed: () {
                              setState(() {
                                if (selectedMode == SelectedMode.StrokeWidth) showBottomList = !showBottomList;
                                selectedMode = SelectedMode.StrokeWidth;
                              });
                            }),
                        IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.opacity),
                            onPressed: () {
                              setState(() {
                                if (selectedMode == SelectedMode.Opacity) showBottomList = !showBottomList;
                                selectedMode = SelectedMode.Opacity;
                              });
                            }),
                        IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                showBottomList = false;
                                points.clear();
                              });
                            }),
                      ],
                    ),
                  ],
                ),
              )),
        ),
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return GestureDetector(
            onTapDown: (details) {
              setState(() {
                // RenderBox? renderBox = context.findRenderObject() as RenderBox;
                // points.add(DrawingPoints(
                //     points: renderBox.globalToLocal(details.globalPosition),
                //     paint: Paint()
                //       ..strokeCap = strokeCap
                //       ..isAntiAlias = true
                //       ..color = selectedColor.withOpacity(opacity)
                //       ..strokeWidth = strokeWidth));
                // points.add(null);
                particlePoint = details.globalPosition;
                _color = randomColor(1.0);
              });

              _controller.repeat();
            },
            onTapCancel: () {
              setState(() {
                points.add(null);
              });
            },
            // onPanUpdate: (details) {
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
              spriteImages.length > 0
                  ? SpriteWidget(startingIndex: 0, desiredFPS: 24, loop: true, constraints: {"width": viewportConstraints.maxWidth.toInt(), "height": viewportConstraints.maxHeight.toInt()}, spriteController: _spriteController)
                  : Container(),
              ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return RadialGradient(
                      radius: 50,
                      center: Alignment.topCenter,
                      colors: <Color>[Colors.black, Colors.black54],
                      tileMode: TileMode.clamp,
                    ).createShader(bounds);
                  },
                  //blendMode: BlendMode.srcOut,
                  child: Stack(children: [
                    Container(
                      width: viewportConstraints.maxWidth,
                      height: viewportConstraints.maxHeight,
                      color: Colors.transparent,
                      clipBehavior: Clip.none,
                    ),

                    // mazeData != null
                    //     ? Padding(
                    //         padding: EdgeInsets.only(top: 50, left: 5),
                    //         child: CustomPaint(
                    //           key: UniqueKey(),
                    //           painter: MazePainter(mazeData!, viewportConstraints.maxWidth, viewportConstraints.maxHeight, (data) {}),
                    //           isComplex: true,
                    //           willChange: false,
                    //           child: Container(),
                    //         ))
                    //   : Container(),

                    Stack(
                      children: getCircles(),
                    ),
                    // CustomPaint(
                    //   size: Size.infinite,
                    //   painter: DrawingPainter(
                    //     pointsList: points,
                    //   ),
                    // ),
                  ])),
              Transform.translate(
                offset: particlePoint,
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: UniqueKey(),
                    isComplex: true,
                    willChange: true,
                    child: Container(),
                    // painter: ParticleEmitter(
                    //     listenable: _controller,
                    //     controller: _controller,
                    //     particleSize: Size(50, 50),
                    //     minParticles: 50,
                    //     center: Offset.zero,
                    //     color: _color,
                    //     radius: 10,
                    //     type: ShapeType.Circle,
                    //     endAnimation: EndAnimation.SCALE_DOWN,
                    //     particleType: ParticleType.FIRE,
                    //     spreadBehaviour: SpreadBehaviour.CONTINUOUS,
                    //     minimumSpeed: 0.1,
                    //     maximumSpeed: 0.2,
                    //     timeToLive: {"min": 50, "max": 250},
                    //     hasBase: true,
                    //     blendMode: BlendMode.srcOver,
                    //     delay: 2)
                    //             //
                    //             // FOUNTAIN
                    //             //
                    painter: ParticleEmitter(
                        listenable: _controller,
                        controller: _controller,
                        particleSize: Size(64, 64),
                        minParticles: 40,
                        center: Offset.zero,
                        color: null,
                        radius: 10,
                        type: ShapeType.Star5,
                        endAnimation: EndAnimation.FADE_OUT,
                        particleType: ParticleType.FOUNTAIN,
                        spreadBehaviour: SpreadBehaviour.ONE_TIME,
                        minimumSpeed: 0.1,
                        maximumSpeed: 0.5,
                        timeToLive: {"min": 500, "max": 2000},
                        hasBase: false,
                        blendMode: BlendMode.srcOver,
                        hasWalls: false,
                        wallsObj: {"bottom": (viewportConstraints.maxHeight - particlePoint.dy).toInt()},
                        delay: 100),
                  ),
                ),
              ),
            ]),
          );
        }));
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
