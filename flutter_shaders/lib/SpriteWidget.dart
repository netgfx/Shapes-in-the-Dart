import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_shaders/SpriteAnimator.dart';
import 'dart:ui' as ui;
import 'package:flutter_native_image/flutter_native_image.dart' as uiImage;
import 'package:flutter_shaders/helpers/utils.dart';

import 'package:path_provider/path_provider.dart';

class SpriteWidget extends StatefulWidget {
  int? startingIndex = 0;
  int desiredFPS = 24;
  bool? loop = true;
  final Map<String, int> constraints;
  final String texturePath;
  String? jsonPath;
  double? scale = 0.5;
  final List<String> delimiters;
  final String? startFrameName;
  bool? stopped = false;
  Map<String, List<Map<String, dynamic>>>? cache;
  Function setCache;
  String name;
  Offset position = Offset(0, 0);
  Function setTextureCache;
  Map<String, dynamic> directionObject = {};
  ui.Image? textureCache;
  SpriteWidget({
    Key? key,
    required this.texturePath,
    this.jsonPath,
    required this.delimiters,
    this.startFrameName,
    this.startingIndex,
    required this.desiredFPS,
    this.loop,
    required this.position,
    required this.directionObject,
    required this.constraints,
    this.stopped,
    this.scale,
    this.cache,
    required this.setTextureCache,
    this.textureCache,
    required this.name,
    required this.setCache,
  }) : super(key: key);

  @override
  _SpriteWidgetState createState() => _SpriteWidgetState();
}

class _SpriteWidgetState extends State<SpriteWidget> with TickerProviderStateMixin {
  late AnimationController _spriteController;
  List<ui.Image> spriteImages = [];
  Map<String, List<Map<String, dynamic>>> spriteData = {};
  late ui.Image? textureImage;
  int sliceWidth = 192;
  int sliceHeight = 212;
  late Animation<double> _animTween;
  late AnimationController aController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("init sprite");
    aController = AnimationController(duration: const Duration(milliseconds: 450), vsync: this);
    _spriteController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _spriteController.repeat();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (widget.cache == null) {
        print("re-run");
        loadSprite();
      } else {
        if (widget.cache != null) {
          if (widget.startFrameName != null) {
            print("loading from cache");
            setState(() {
              spriteData = widget.cache!;
              textureImage = widget.textureCache;
            });
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(SpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.cache != null) {
      if (widget.startFrameName != null) {
        print("loading from cache ${widget.loop}");
        if (widget.loop == false) {
          _spriteController.forward(from: 0);
        } else {
          _spriteController.repeat();
        }

        setState(() {
          spriteData = widget.cache!;
        });
      }
    }
  }

  @override
  void dispose() {
    _spriteController.dispose();

    super.dispose();
  }

  void loadSprite() async {
    final ByteData data = await rootBundle.load(widget.texturePath);
    this.textureImage = await Utils.shared.imageFromBytes(data);
    widget.setTextureCache(widget.name, this.textureImage);
    if (widget.jsonPath != null && widget.jsonPath != "") {
      var data = loadJsonData(widget.jsonPath!);
      data.then((value) => {
            setState(() {
              spriteData = parseJSON(value);
            }),
            widget.setCache(widget.name, spriteData)
          });
    }
  }

  AnimationController getAnimation() {
    aController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _animTween = Tween<double>(begin: getStart(), end: getEnd()).animate(
      CurvedAnimation(
        parent: aController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animTween.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        aController.dispose();
      }
    });

    aController.forward();

    return aController;
  }

  Future<Map<String, dynamic>> loadJsonData(String path) async {
    var jsonText = await rootBundle.loadString(path);
    Map<String, dynamic> data = json.decode(jsonText);
    return data;
  }

  Map<String, List<Map<String, dynamic>>> parseJSON(Map<String, dynamic> data) {
    Map<String, List<Map<String, dynamic>>> sprites = {};
    for (var key in widget.delimiters) {
      sprites[key] = [];
      data["frames"].forEach((innerKey, value) {
        final frameData = value['frame'];
        final int x = frameData['x'];
        final int y = frameData['y'];
        final int width = frameData['w'];
        final int height = frameData['h'];
        if ((innerKey as String).contains(key) == true) {
          sprites[key]!.add({"x": x, "y": y, "width": width, "height": height});
        }
      });
    }

    return sprites;
  }

  double getStart() {
    double value = widget.directionObject["oldX"].toDouble() == widget.position.dx.toDouble()
        ? widget.directionObject["oldY"].toDouble()
        : widget.directionObject["oldX"].toDouble();
    print("start value $value");
    return value;
  }

  double getEnd() {
    double value = widget.directionObject["oldX"].toDouble() == widget.position.dx.toDouble() ? widget.position.dy : widget.position.dx;
    print("end value $value");
    return value;
  }

  double getMovingXAxis(num offset) {
    print("X Offset $offset");
    double value = widget.directionObject["oldX"].toDouble() == widget.position.dx.toDouble() ? widget.position.dx : offset.toDouble();
    print("moving to X: $value");
    return value;
  }

  double getMovingYAxis(num offset) {
    print("Y Offset $offset");
    double value = widget.directionObject["oldY"].toDouble() == widget.position.dy.toDouble() ? widget.position.dy : offset.toDouble();
    print("moving to Y: $value");
    return value;
  }

  Tween<double> getTween() {
    return new Tween(begin: getStart(), end: getEnd());
  }

  AnimatedBuilder getTweenBuilder(BuildContext context, double s, double e) {
    print("start $s end $e");
    return AnimatedBuilder(
        animation: getAnimation(),
        builder: (BuildContext context, Widget? child) {
          print(">>>> ${_animTween.value}");
          return Positioned(
            left: getMovingXAxis(_animTween.value),
            top: getMovingYAxis(_animTween.value),
            child: Transform.scale(
              scale: widget.scale ?? 1.0,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: SpriteAnimator(
                      controller: _spriteController,
                      static: false,
                      images: spriteData,
                      texture: this.textureImage!,
                      fps: widget.desiredFPS,
                      currentFrame: widget.startFrameName!,
                      loop: widget.loop == true ? LoopMode.Repeat : LoopMode.Single),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (spriteData.isEmpty == false && this.textureImage != null) {
      return getTweenBuilder(context, getStart(), getEnd());
    } else {
      return Container();
    }
  }
}
