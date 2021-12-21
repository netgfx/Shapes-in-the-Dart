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
  Map<String, List<ui.Image>>? cache;
  Function setCache;
  String name;
  Offset position = Offset(0, 0);
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
    required this.constraints,
    this.stopped,
    this.scale,
    this.cache,
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
  late ui.Image textureImage;
  int sliceWidth = 192;
  int sliceHeight = 212;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("init sprite");
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
              spriteImages = widget.cache![widget.startFrameName]!;
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
          spriteImages = widget.cache![widget.startFrameName]!;
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
    this.textureImage = await imageFromBytes(data);

    if (widget.jsonPath != null && widget.jsonPath != "") {
      var data = loadJsonData(widget.jsonPath!);
      data.then((value) => {
            setState(() {
              spriteData = parseJSON(value);
            }),
          });
    }
  }

  Future<ui.Image> imageFromBytes(ByteData data) async {
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
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

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (spriteData.isEmpty == false) {
      return Positioned(
        left: widget.position.dx,
        top: widget.position.dy,
        child: Transform.scale(
          scale: widget.scale ?? 1.0,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: SpriteAnimator(
                  controller: _spriteController,
                  static: false,
                  images: spriteData,
                  texture: this.textureImage,
                  fps: widget.desiredFPS,
                  currentFrame: widget.startFrameName!,
                  loop: widget.loop == true ? LoopMode.Repeat : LoopMode.Single),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
