import 'dart:typed_data';

import 'package:delaunay/delaunay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/Fragment.dart';
import 'package:image/image.dart' as image;
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:args/args.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_animations/simple_animations.dart';
//import 'package:spring/spring.dart';
import 'package:supercharged/supercharged.dart';

enum AniProps { rotateX, rotateY, opacity, scale }

class Triangulator extends StatefulWidget {
  Triangulator({Key? key}) : super(key: key);

  @override
  _TriangulatorState createState() => _TriangulatorState();
}

class _TriangulatorState extends State<Triangulator> with AnimationMixin {
  String? finalImage = null;
  BoxConstraints? viewportConstraints;
  Delaunay? triangles;
  late AnimationController _controller;
  List<AnimationController> controllers = [];
  ui.Image? sourceImage;
  // final SpringController springController = SpringController(
  //   initialAnim: Motion.pause,
  // );
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      init();

      _controller = AnimationController(duration: 1.seconds, vsync: this);
    });
  }

  @override
  void dispose() {
    for (var item in controllers) {
      item.dispose();
    }

    controllers.clear();
    _controller.dispose();

    super.dispose();
  }

  // const String description =
  //   'delaunay_example.dart: An example program that creates a random delaunay '
  //   'trianulation png file with colors from an input image.';

  Future<int> init() async {
    final ArgParser argParser = ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        help: 'Print help',
        defaultsTo: false,
        negatable: false,
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Verbose output',
        defaultsTo: false,
        negatable: false,
      )
      ..addOption(
        'input',
        abbr: 'i',
        help: 'Input image from which to extract colors for triangles',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Path to the output file',
        defaultsTo: 'delaunay.png',
      )
      ..addOption(
        'points',
        abbr: 'p',
        help: 'Number of points',
        defaultsTo: '1000',
      )
      ..addOption(
        'seed',
        abbr: 's',
        help: 'RNG seed',
        defaultsTo: '42',
      );
    //final ArgResults argResults = argParser.parse(args);
    String dir = (await getApplicationDocumentsDirectory()).path;
    var _options = Options("$dir/delaunay.png", 100, 42, true, true, {});
    final Options? options = await _options.fromArgResults(null);

    final image.Image inputImage = options!.images["img"];
    sourceImage = options.images["uiImage"];

    final Random r = Random(options.seed);

    const double minX = 0.0;
    final double maxX = inputImage.width.toDouble();
    const double minY = 0.0;
    final double maxY = inputImage.height.toDouble();

    final image.Image img = image.Image(
      inputImage.width,
      inputImage.height,
    );

    final int numPoints = options.points;
    final List<Point<double>> points = <Point<double>>[];
    for (int i = 0; i < numPoints; i++) {
      points.add(Point<double>(r.nextDouble() * maxX, r.nextDouble() * maxY));
    }

    points.add(const Point<double>(minX, minY));
    points.add(Point<double>(minX, maxY));
    points.add(Point<double>(maxX, minY));
    points.add(Point<double>(maxX, maxY));

    final Delaunay triangulator = Delaunay.from(points);

    final Stopwatch sw = Stopwatch()..start();
    triangulator.initialize();

    if (options.verbose) {
      print('Triangulator initialized in ${sw.elapsedMilliseconds}ms for ${options.points} points');
    }

    sw.reset();
    sw.start();
    triangulator.processAllPoints();

    if (options.verbose) {
      print('Triangulated with ${triangulator.triangles.length ~/ 3} triangles '
          'in ${sw.elapsedMilliseconds}ms');
    }

    sw.reset();
    sw.start();

    /// assign to global
    triangles = triangulator;

    for (int i = 0; i < triangulator.triangles.length; i += 3) {
      final Point<double> a = triangulator.getPoint(
        triangulator.triangles[i],
      );
      final Point<double> b = triangulator.getPoint(
        triangulator.triangles[i + 1],
      );
      final Point<double> c = triangulator.getPoint(
        triangulator.triangles[i + 2],
      );
      final int color = inputImage.getPixel(
        (a.x.toInt() + b.x.toInt() + c.x.toInt()) ~/ 3,
        (a.y.toInt() + b.y.toInt() + c.y.toInt()) ~/ 3,
      );
      // drawTriangle(
      //   img,
      //   a.x.round(), a.y.round(),
      //   b.x.round(), b.y.round(),
      //   c.x.round(), c.y.round(),
      //   image.Color.fromRgb(0, 0, 0), // black
      //   color,
      // );

    }

    if (options.verbose) {
      print('Image drawn in ${sw.elapsedMilliseconds}ms.');
    }

    sw.reset();
    sw.start();
    final List<int> imageData = image.encodePng(img, level: 2);

    File(options.output).writeAsBytesSync(imageData, mode: FileMode.write, flush: true);
    sw.stop();
    if (options.verbose) {
      print('PNG document written in ${sw.elapsedMilliseconds}ms.');
    }

    print(options.output);
    if (mounted) {
      setState(() {
        finalImage = options.output;
      });
    }

    return 0;
  }

  Future<void> loadImages(List<String> data) async {
    var futures = <Future<ui.Image>>[];

    ///print(rootBundle.toString());
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
          setState(() => {sourceImage = values[0]}),
        });
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  List<Widget> getFragments() {
    List<Widget> list = [];

    if (triangles != null) {
      var counter = 0;

      for (int i = 0; i < triangles!.triangles.length; i += 3) {
        final Point<double> a = triangles!.getPoint(
          triangles!.triangles[i],
        );
        final Point<double> b = triangles!.getPoint(
          triangles!.triangles[i + 1],
        );
        final Point<double> c = triangles!.getPoint(
          triangles!.triangles[i + 2],
        );

        var delay = ((100 * counter) - (40 * counter)).round();

        AnimationController aController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
        controllers.add(aController);
        var _rotateXTween = Tween<double>(begin: 0.0, end: 30).animate(
          CurvedAnimation(
            parent: aController,
            curve: Curves.easeOutCubic,
          ),
        );
        var _rotateYTween = Tween<double>(begin: 0.0, end: -90).animate(
          CurvedAnimation(
            parent: aController,
            curve: Curves.easeOutCubic,
          ),
        );
        var _opacityTween = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: aController,
            curve: Curves.easeOutCubic,
          ),
        );
        var _sizeTween = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: aController,
            curve: Curves.easeOutCubic,
          ),
        );

        ///_tween.animatedBy(_controller);
        if (sourceImage != null) {
          print("DELAY: $delay");
          list.add(AnimatedBuilder(
              animation: aController,
              builder: (BuildContext context, Widget? child) {
                return Transform(
                  transform: Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                    //..rotateX(_rotateXTween.value)
                    //..rotateY(0)
                    ..scale(_sizeTween.value),
                  alignment: FractionalOffset.center,
                  child: Opacity(
                    opacity: _opacityTween.value, //value.get(AniProps.opacity).toDouble(),
                    child: Padding(
                      padding: EdgeInsets.only(top: 0, left: 0),
                      child: CustomPaint(
                        key: UniqueKey(),
                        painter: Fragment(p0: a, p1: b, p2: c, fps: 24, controller: _controller, image: sourceImage!, delay: delay),
                        isComplex: true,
                        willChange: true,
                        child: Container(),
                      ),
                    ),
                  ),
                );
              }));
        }

        counter++;
      }

      // list.add(Spring.opacity(
      //   startOpacity: 1.0,
      //   endOpacity: 0.0,
      //   springController: springController,
      //   animDuration: Duration(milliseconds: 10), //def=1s
      //   animStatus: (AnimStatus status) {
      //     print(status);
      //   },
      //   curve: Curves.easeOutSine, //def=Curves.easInOut
      //   delay: Duration(milliseconds: (100).round()), //def=0
      //   child: Padding(
      //     padding: EdgeInsets.only(top: 0, left: 0),
      //     child: Image.asset(
      //       "assets/bg.jpg",
      //       height: 518,
      //       fit: BoxFit.fill,
      //       alignment: Alignment.bottomCenter,
      //     ),
      //   ),
      // ));
    }

    return list;
  }

  void drawTriangle(
    image.Image img,
    int ax,
    int ay,
    int bx,
    int by,
    int cx,
    int cy,
    int lineColor,
    int fillColor,
  ) {
    void fillBottomFlat(int x1, int y1, int x2, int y2, int x3, int y3) {
      final double slope1 = (x2 - x1).toDouble() / (y2 - y1).toDouble();
      final double slope2 = (x3 - x1).toDouble() / (y3 - y1).toDouble();

      double curx1 = x1.toDouble();
      double curx2 = curx1;

      for (int sy = y1; sy <= y2; sy++) {
        final int cx1 = curx1.toInt();
        final int cx2 = curx2.toInt();
        image.drawLine(img, cx1, sy, cx2, sy, fillColor);
        curx1 += slope1;
        curx2 += slope2;
      }
    }

    void fillTopFlat(int x1, int y1, int x2, int y2, int x3, int y3) {
      final double slope1 = (x3 - x1).toDouble() / (y3 - y1).toDouble();
      final double slope2 = (x3 - x2).toDouble() / (y3 - y2).toDouble();

      double curx1 = x3.toDouble();
      double curx2 = curx1;

      for (int sy = y3; sy > y1; sy--) {
        final int cx1 = curx1.toInt();
        final int cx2 = curx2.toInt();
        image.drawLine(img, cx1, sy, cx2, sy, fillColor);
        curx1 -= slope1;
        curx2 -= slope2;
      }
    }

    // Sort points in ascending order by y coordinate.
    if (ay > cy) {
      final int tmpx = ax, tmpy = ay;
      ax = cx;
      ay = cy;
      cx = tmpx;
      cy = tmpy;
    }

    if (ay > by) {
      final int tmpx = ax, tmpy = ay;
      ax = bx;
      ay = by;
      bx = tmpx;
      by = tmpy;
    }

    if (by > cy) {
      final int tmpx = bx, tmpy = by;
      bx = cx;
      by = cy;
      cx = tmpx;
      cy = tmpy;
    }

    if (by == cy) {
      fillBottomFlat(ax, ay, bx, by, cx, cy);
    } else if (ay == by) {
      fillTopFlat(ax, ay, bx, by, cx, cy);
    } else {
      final int dy = by;
      final int dx = ax + (((by - ay).toDouble() / (cy - ay).toDouble()) * (cx - ax).toDouble()).toInt();

      fillBottomFlat(ax, ay, bx, by, dx, dy);
      fillTopFlat(bx, by, dx, dy, cx, cy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.black,
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
                _controller.repeat();
                //springController.play();
                var counter = 0;
                Future.delayed(Duration(milliseconds: 12000), () {
                  _controller.reset();
                });
                // for (var item in controllers) {
                //   var delay = ((200 * counter) - (40 * counter)).round();
                //   Future.delayed(Duration(milliseconds: delay), () {
                //     item.forward().orCancel;
                //   });
                //   counter += 1;
                // }
              },
              child: Stack(
                  fit: StackFit.passthrough,
                  children: finalImage != null
                      ? getFragments()
                      : [
                          Container(),
                        ]));
        }),
      ),
    );
  }
}

class Options {
  Options(this.output, this.points, this.seed, this.verbose, this.help, this.images);

  Future<Options?> fromArgResults(ArgResults? results) async {
    // final bool verbose = results['verbose']!;
    // final int? points = int.tryParse(results['points']!);
    // if (points == null || points <= 0) {
    //   stderr.writeln('--points must be a strictly positive integer');
    //   return null;
    // }
    // final int? seed = int.tryParse(results['seed']!);
    // if (seed == null || seed <= 0) {
    //   stderr.writeln('--seed must be a strictly positive integer');
    //   return null;
    // }
    // if (!results.wasParsed('input') && !results['help']!) {
    //   stderr.writeln('Please supply an image with the --input flag.');
    //   return null;
    // }

    var image = await _imageFromArgResults(results, true);
    String dir = (await getApplicationDocumentsDirectory()).path;

    return Options(
      "$dir/delaunay.png",
      doubleInRange(20, 40).round(),
      doubleInRange(1, 1000).round(),
      true,
      true,
      image!,
    );
  }

  double doubleInRange(double start, double end) {
    final _random = new Random();
    if (start == end) {
      return start;
    } else {
      return _random.nextDouble() * (end - start) + start;
    }
  }

  Future<File> loadImageTexture() async {
    final ByteData data = await rootBundle.load("assets/bg.jpg");

    String dir = (await getApplicationDocumentsDirectory()).path;
    File path = await writeToFile(data, '$dir/tempfile1.png');

    return path;
  }

  //write to app path
  Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<Map<String, dynamic>?> _imageFromArgResults(ArgResults? results, bool verbose) async {
    //final String inputImagePath =
    image.Image inputImage;
    final File inputFile = await loadImageTexture();
    if (!inputFile.existsSync()) {
      stderr.writeln('--input image does not exist.');
      return null;
    }
    final Stopwatch sw = Stopwatch();
    sw.start();
    final List<int> imageData = inputFile.readAsBytesSync();
    ui.Image img = await loadImage(inputFile.readAsBytesSync());
    // ui.decodeImageFromList(inputFile.readAsBytesSync(), (result) {
    //   img = result;
    // });

    if (verbose) {
      final int kb = imageData.length >> 10;
      print('Image data (${kb}KB) read in ${sw.elapsedMilliseconds}ms');
    }
    sw.reset();
    inputImage = image.decodeImage(imageData)!;
    sw.stop();
    if (verbose) {
      final int w = inputImage.width;
      final int h = inputImage.height;
      print('Image data ${w}x$h decoded in ${sw.elapsedMilliseconds}ms');
    }
    return {"img": inputImage, "uiImage": img};
  }

  final String output;
  final int points;
  final int seed;
  final bool verbose;
  final bool help;
  //final image.Image? inputImage;
  final Map<String, dynamic> images;
}
