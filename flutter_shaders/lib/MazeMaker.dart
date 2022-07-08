import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_shaders/game_classes/maze/maze_draw.dart';
import 'package:flutter_shaders/game_classes/maze_driver.dart';

import 'package:flutter_shaders/game_classes/pathfinding/BFS.dart';
import 'package:flutter_shaders/game_classes/pathfinding/MazeLocation.dart' as ML;
import 'package:flutter_shaders/helpers/action_manager.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;

/// test
import 'package:flutter_shaders/game_classes/maze/maze_builder.dart';

import 'package:performance/performance.dart';
import 'package:dotted_border/dotted_border.dart';

import 'game_classes/pathfinding/MazeGrid.dart';
import 'game_classes/pathfinding/MazeNode.dart';

class MazeMaker extends StatefulWidget {
  MazeMaker({required Key key}) : super(key: key);

  @override
  _MazeMakerState createState() => _MazeMakerState();
}

class _MazeMakerState extends State<MazeMaker> with TickerProviderStateMixin {
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
  ActionManager actions = ActionManager();

  ///
  Duration _elapsed = Duration.zero;
  // 2. declare Ticker
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    // 3. initialize Ticker
    _ticker = this.createTicker((elapsed) {
      // 4. update state
      setState(() {
        _elapsed = elapsed;
      });
    });

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.repeat();

      /// generate maze
      generateMaze();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    actions.actionController.close();
    super.dispose();
  }

  /**
   * Generate the maze
   */
  void generateMaze() {
    int size = 24;
    Random rand = Random();
    final stopwatch = Stopwatch()..start();
    List<List<Cell>> maze = generate(width: size, height: size, closed: true, seed: 100);
    // rand.nextInt(100000000)

    // for (var i = 0; i < maze.length; i++) {
    //   List<Cell> blocks = maze[i].toList();
    // }

    // List<List<Node>> matrix = getMatrix(size, size, maze);
    // MazeGrid grid = MazeGrid(width: size, height: size, matrix: matrix, maze: maze);
    // List<ML.MazeLocation> solution =
    //     BFS(width: size, height: size, grid: grid).findPath(ML.MazeLocation(row: 0, col: 0), ML.MazeLocation(row: maze.length - 1, col: maze.length - 1));

    setState(() {
      finalMaze = maze;
      //mazeSolution = solution;
    });

    print('generate maze executed in ${stopwatch.elapsed}');
  }

  List<List<Node>> getMatrix(int rows, int columns, List<List<Cell>> maze) {
    List<List<Node>> matrix = [];
    for (var i = 0; i < rows; i++) {
      matrix.add([]);
      for (var j = 0; j < columns; j++) {
        matrix[i].add(Node(x: maze[i][j].x.round(), y: maze[i][j].y.round(), walkable: true));
      }
    }

    return matrix;
  }

  void updateFn(double point) {
    //Utils.shared.delayedPrint("update received:  $point");
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
          backgroundColor: ui.Color.fromARGB(255, 0, 0, 0),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), color: ui.Color.fromARGB(255, 0, 0, 0)),
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
                offset: Offset(50, 100),
                child: RepaintBoundary(
                    child: CustomPaint(
                  size: ui.Size(200, 400),
                  key: UniqueKey(),
                  isComplex: true,
                  painter: MazeDriverCanvas(
                    controller: _controller,
                    maze: finalMaze,
                    blockSize: 16,
                    fps: 24,
                    actions: actions,
                    //solution: this.mazeSolution,
                    width: viewportConstraints.maxWidth,
                    height: viewportConstraints.maxHeight,
                  ),
                  child: Container(constraints: BoxConstraints(maxWidth: viewportConstraints.maxWidth, maxHeight: viewportConstraints.maxHeight)),
                )),
              ),

              /// Down
              Positioned(
                  key: UniqueKey(),
                  child: GestureDetector(
                    key: UniqueKey(),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      //print("POINT OF CONTACT: ${details.globalPosition}");
                      actions.sendDown();
                      // _controller.repeat();
                    },
                    child: AbsorbPointer(absorbing: true, child: Image(image: AssetImage('assets/maze/arrowDown.png'))),
                  ),
                  bottom: 50,
                  left: viewportConstraints.maxWidth / 2 - 50),

              /// Up
              Positioned(
                  key: UniqueKey(),
                  child: GestureDetector(
                    key: UniqueKey(),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      //print("POINT OF CONTACT: ${details.globalPosition}");
                      actions.sendUp();
                      // _controller.repeat();
                    },
                    child: Image(image: AssetImage('assets/maze/arrowUp.png')),
                  ),
                  bottom: 200,
                  left: viewportConstraints.maxWidth / 2 - 50),

              /// Left
              Positioned(
                  key: UniqueKey(),
                  child: GestureDetector(
                    key: UniqueKey(),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      //print("POINT OF CONTACT: ${details.globalPosition}");
                      actions.sendLeft();
                      // _controller.repeat();
                    },
                    child: Image(image: AssetImage('assets/maze/arrowLeft.png')),
                  ),
                  bottom: 100,
                  left: viewportConstraints.maxWidth / 2 - 100),

              /// Right
              Positioned(
                  key: UniqueKey(),
                  child: GestureDetector(
                    key: UniqueKey(),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      //print("POINT OF CONTACT: ${details.globalPosition}");
                      actions.sendRight();
                      // _controller.repeat();
                    },
                    child: Image(image: AssetImage('assets/maze/arrowRight.png')),
                  ),
                  bottom: 200,
                  left: viewportConstraints.maxWidth / 2 + 100)
            ]);

            //);
          })),
    );
  }
}
