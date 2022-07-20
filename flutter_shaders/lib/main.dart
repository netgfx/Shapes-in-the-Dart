import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/QuestShape.dart';
import './ShapeMaster.dart';
import 'package:vector_math/vector_math.dart' as Vec;
import "./Screen.dart";
import 'package:fast_poisson_disk_sampling/fast_poisson_disk_sampling.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:lottie/lottie.dart';
import 'package:statsfl/statsfl.dart';
import 'Router.dart';

void main() {
  runApp(Padding(padding: EdgeInsets.only(top: 50), child: StatsFl(height: 60, align: Alignment.topCenter, maxFps: 60, child: MyApp())));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: "GameScene",
      routes: routes,
      home: MyHomePage(
        title: 'Shapes in the Dart',
        key: UniqueKey(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  Offset position = Offset(10, 10);
  final containerKey1 = GlobalKey();
  final containerKey2 = GlobalKey();
  late RenderBox maskArea;
  List<List<double>> points = [];
  String currentLevel = "level1";
  List<QuestShape> currentLevelQueue = [];
  Color bgColor = Color.fromARGB(255, 148, 23, 183);
  Map<String, Map<String, dynamic>> currentNodes = {};
  double timerValue = 1.0;
  bool gameOver = false;
  Map<String, List<ShapeType>> shapesPerLevel = {
    "level1": [
      ShapeType.Circle,
      ShapeType.Rect,
      ShapeType.RoundedRect,
      ShapeType.Triangle,
    ],
    "level2": [ShapeType.Circle, ShapeType.Rect, ShapeType.RoundedRect, ShapeType.Triangle, ShapeType.Heart, ShapeType.Star5, ShapeType.Hexagon]
  };

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      var p = FastPoissonDiskSampling(
          shape: Size((MediaQuery.of(context).size.width - 50).ceil().toDouble(), (MediaQuery.of(context).size.height - 210).ceil().toDouble()),
          radius: 190,
          maxTries: 50,
          minDistance: 0,
          rng: null);

      print("Size is: ${(MediaQuery.of(context).size.width - 25).ceil().toDouble()} ${(MediaQuery.of(context).size.height - 25).ceil().toDouble()}");
      setState(() {
        points = p.fill();
      });

      print("POINTS: $points} LENGTH: ${points.length}");

      generateRandomShapes(points);

      maskArea = containerKey1.currentContext!.findRenderObject() as RenderBox;

      // start animatioin
      animateValue();
    });

    generateQuestShapes();
  }

  /// animate the timer value
  void animateValue() {
    AnimationController controller = AnimationController(duration: const Duration(milliseconds: 15000), vsync: this);
    Animation<double> progress = Tween<double>(begin: 1, end: 0).animate(controller);
    progress.addListener(() {
      setState(() {
        timerValue = progress.value;
      });
    });
    progress.addStatusListener((status) {
      //check if status is complete and if all shapes have been found
      if (status == AnimationStatus.completed) {
        bool haveShapeUnmarked = false;
        currentLevelQueue.forEach((element) {
          if (element.isFound == false) {
            haveShapeUnmarked = true;
          }
        });

        if (haveShapeUnmarked) {
          print("Game over!");
          gameOver = true;
          showLossAlert();
        }
      }
    });
    controller.forward();
  }

  void showVictoryAlert() {
    Alert(
        context: context,
        title: "Victory!",
        content: Column(children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            'You Won the round!',
            textAlign: TextAlign.center,
          ),
          Lottie.asset('assets/win.json', width: 200, fit: BoxFit.fill),
        ]),
        buttons: [
          DialogButton(
            onPressed: () => {Navigator.pop(context)},
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void showLossAlert() {
    Alert(
        context: context,
        title: "Game Over...",
        content: Column(children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            'You Lost the round!',
            textAlign: TextAlign.center,
          ),
          Lottie.asset('assets/loss.json', width: 200, fit: BoxFit.fill),
        ]),
        buttons: [
          DialogButton(
            onPressed: () => {Navigator.pop(context)},
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void _onPanStart(BuildContext context, DragStartDetails details) {
    print(details.globalPosition.dy);
  }

  void _onPanUpdate(BuildContext context, DragUpdateDetails details, Offset offset) {
    //checkCollision();
    setState(() {
      position = details.localPosition;
    });
    currentNodes.forEach((key, value) {
      if (value["matched"] == false) {
        bool result = checkCollision(maskArea, Size(40, 40), value["offset"]);
        if (result == true) {
          int nextIndex = getFirstNotFoundShape();
          print("next index: $nextIndex");
          if (nextIndex != -1) {
            if (currentLevelQueue[nextIndex].getShape() == value["shape"]) {
              currentLevelQueue[nextIndex].setFound(true);
              currentLevelQueue[nextIndex].setColor(Colors.green);
              value["matched"] = true;
              // check if there is another left
              int newNextIndex = getFirstNotFoundShape();
              if (newNextIndex == -1) {
                if (gameOver == false) {
                  showVictoryAlert();
                }
              }
            }
          } else {
            print("Victory!");
            if (gameOver == true) {
              showVictoryAlert();
            }
          }
          return;
        }
      }
    });
  }

  void _onPanEnd(BuildContext context, DragEndDetails details) {
    print(details.velocity);
  }

  void _onPanCancel(BuildContext context) {
    print("Pan canceled !!");
  }

  bool checkCollision(RenderBox box1, Size box2Size, Offset box2Offset) {
    bool result = false;
    if (containerKey1.currentContext != null) {
      //RenderBox box1 = containerKey1.currentContext!.findRenderObject() as RenderBox;
      //RenderBox box2 = containerKey2.currentContext!.findRenderObject() as RenderBox;

      final size1 = box1.size;
      final size2 = box2Size;

      var position1 = box1.localToGlobal(Offset(0, -76));
      //position1 = Offset(position1.dx + size1.width * 0.5, position1.dy + size1.height * 0.5);
      var position2 = box2Offset;
      //position2 = Offset(position2.dx + size2.width * 0.5, position2.dy + size2.height * 0.5);
      Rect rect1 = position1 & size1;
      Rect rect2 = position2 & size2;

      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1.height > position2.dy);

      final overlap = rectOverlap(rect1, rect2);

      if (overlap == true) {
        print('\nContainers collide: $position1, $size1, $position2, $size2, $collide $overlap <<<<<<<<\n');
      } else {
        //print('\nContainers collide: $position1, $position2\n');
      }
      result = overlap;
    }

    return result;
  }

  bool rectOverlap(Rect A, Rect B) {
    bool xOverlap = valueInRange(A.center.dx.toInt(), B.center.dx.toInt(), B.center.dx.toInt() + (B.width * 0.5).toInt()) ||
        valueInRange(B.center.dx.toInt(), A.center.dx.toInt(), A.center.dx.toInt() + (A.width * 0.5).toInt());

    bool yOverlap = valueInRange(A.center.dy.toInt(), B.center.dy.toInt(), B.center.dy.toInt() + (B.height * 0.5).toInt()) ||
        valueInRange(B.center.dy.toInt(), A.center.dy.toInt(), A.center.dy.toInt() + (A.height * 0.5).toInt());

    return xOverlap && yOverlap;
  }

  bool valueInRange(int value, int min, int max) {
    return (value >= min) && (value <= max);
  }

  List<Widget> getShapes(BoxConstraints viewportConstraints) {
    print("repainting the shapes");
    List<Widget> shapes = [];
    List<ShapeType> eligibleShapes = shapesPerLevel[currentLevel]!;
    final _random = new Random();

    currentNodes.forEach((key, value) {
      Widget widgetObj = Positioned(
          top: value["offset"].dy,
          left: value["offset"].dx,
          child: CustomPaint(
            key: value["key"],
            painter: ShapeMaster(
                type: value["shape"],
                size: Size(40, 40),
                radius: 40.0,
                center: Offset(0, 0),
                angle: null,
                color: currentNodes[value["key"].toString()]!["color"] as Color),
            child: Container(),
          ));

      shapes.add(widgetObj);
    });

    return shapes;
  }

  List<Widget> getQuestShapes() {
    //shapes are pre-cached

    List<Widget> finalList = [];

    Map<String, int> numberOfShapesPerLevel = {"level1": 3, "level2": 5};
    ShapeType shape;
    for (var i = 0; i < numberOfShapesPerLevel[currentLevel]!; i++) {
      shape = currentLevelQueue[i].getShape();
      finalList.add(
        CustomPaint(
          key: UniqueKey(),
          painter: ShapeMaster(type: shape, size: Size(50, 50), radius: 25.0, center: Offset(0, 0), angle: null, color: currentLevelQueue[i].getColor()),
          isComplex: true,
          willChange: false,
          child: Container(),
        ),
      );
    }
    return finalList;
  }

  void generateRandomShapes(List<List<double>> pointsList) {
    currentNodes.clear();
    Map<String, Map<String, dynamic>> finalList = {};
    Map<String, int> numberOfShapesPerLevel = {"level1": 3, "level2": 5};
    List<ShapeType> eligibleShapes = shapesPerLevel[currentLevel]!;
    ShapeType shape;
    final _random = new Random();
    // first make sure to create the quest shapes
    // then some randoms
    for (var i = 0; i < pointsList.length; i++) {
      double x = pointsList[i][0];
      double y = pointsList[i][1];
      GlobalKey _key = GlobalKey();

      // normalize within bounds
      if (x < 40) {
        x = 40;
      }

      if (y < 40) {
        y = 40;
      }

      if (currentLevelQueue.length > i) {
        shape = currentLevelQueue[i].getShape();
      } else {
        shape = eligibleShapes[_random.nextInt(eligibleShapes.length)];
      }

      finalList.putIfAbsent(
          _key.toString(),
          () => {
                "key": _key,
                "isFound": false,
                "color": Colors.white70,
                "widgetObj": null,
                "size": Size(40, 40),
                "offset": Offset(x, y),
                "shape": shape,
                "matched": false
              });

      setState(() {
        currentNodes = finalList;
      });
    }
  }

  void generateQuestShapes() {
    currentLevelQueue.clear();
    final _random = new Random();
    Map<String, int> numberOfShapesPerLevel = {"level1": 3, "level2": 5};
    List<ShapeType> eligibleShapes = shapesPerLevel[currentLevel]!;
    ShapeType shape;
    for (var i = 0; i < numberOfShapesPerLevel[currentLevel]!; i++) {
      shape = eligibleShapes[_random.nextInt(eligibleShapes.length)];
      currentLevelQueue.add(QuestShape(shape, Colors.white, false));
    }
  }

  int getFirstNotFoundShape() {
    return currentLevelQueue.indexWhere((element) => element.getFound() == false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return GestureDetector(
            onPanStart: (details) => _onPanStart(context, details),
            onPanUpdate: (details) => _onPanUpdate(context, details, position),
            onPanEnd: (details) => _onPanEnd(context, details),
            onPanCancel: () => _onPanCancel(context),
            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                  height: viewportConstraints.maxHeight - 80,
                  child: Stack(children: [
                    points.length > 0 ? RepaintBoundary(child: Stack(children: getShapes(viewportConstraints))) : SizedBox(),
                    ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return RadialGradient(
                            radius: 50,
                            center: Alignment.topCenter,
                            colors: <Color>[Colors.black, Colors.black54],
                            tileMode: TileMode.clamp,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcOut,
                        child: Stack(children: [
                          Container(
                            width: viewportConstraints.maxWidth,
                            height: viewportConstraints.maxHeight,
                            color: Colors.transparent,
                            clipBehavior: Clip.none,
                          ),
                          Transform.translate(
                              offset: Offset(position.dx - 100, position.dy - 100),
                              child: Container(
                                key: containerKey1,
                                width: 100,
                                height: 100,
                                constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
                                decoration: BoxDecoration(
                                    color: Colors.black, // Color does not matter but should not be transparent
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(blurRadius: 8, offset: const Offset(0, 0), color: Colors.black, spreadRadius: 2),
                                      BoxShadow(blurRadius: 8, offset: const Offset(0, 0), color: Colors.black, spreadRadius: 2)
                                    ]),
                                child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.0),
                                          Colors.black.withOpacity(0.4),
                                        ],
                                        center: AlignmentDirectional(0.0, 0.0),
                                        focal: AlignmentDirectional(0.0, 0.0),
                                        radius: 0.6,
                                        focalRadius: 0.001,
                                        stops: [0.75, 1.0],
                                      ),
                                    )),
                              )),
                        ])),
                  ])),
              LinearProgressIndicator(
                value: timerValue,
                backgroundColor: Colors.purple,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                minHeight: 5.0,
              ),
              SizedBox(
                child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: getQuestShapes(),
                    )),
                height: 70,
              )
            ]));
      }),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
