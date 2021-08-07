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
  int? desiredFPS = 24;
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
  SpriteWidget({
    Key? key,
    required this.texturePath,
    this.jsonPath,
    required this.delimiters,
    this.startFrameName,
    this.startingIndex,
    this.desiredFPS,
    this.loop,
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
    Map<String, List<Map<String, dynamic>>> spriteData;
    File imageData = await loadImageTexture(widget.texturePath);
    if (widget.jsonPath != null && widget.jsonPath != "") {
      var data = loadJsonData(widget.jsonPath!);

      uiImage.ImageProperties props = await uiImage.FlutterNativeImage.getImageProperties(imageData.path);
      data.then((value) => {spriteData = parseJSON(value), loadSpriteImage(spriteData, imageData, true)});
    }
  }

  void loadSpriteImage(Map<String, List<Map<String, dynamic>>> spriteData, File path, bool all) async {
    uiImage.ImageProperties props = await uiImage.FlutterNativeImage.getImageProperties(path.path);
    print("${props.width} ${props.height} ${spriteData.length}");

    if (all == true) {
      Map<String, List<ui.Image>> spriteTexturesByFrameName = {};
      for (var item in widget.delimiters) {
        if (spriteData[item] != null) {
          spriteTexturesByFrameName[item] = [];
          List<Map<String, dynamic>> frames = spriteData[item]!;
          for (var i = 0; i < frames.length; i++) {
            File croppedFile = await uiImage.FlutterNativeImage.cropImage(path.path, frames[i]['x'], frames[i]['y'], frames[i]["width"], frames[i]['height']);

            Uint8List bytes = croppedFile.readAsBytesSync();
            ui.Image image = await loadImage(bytes);
            spriteTexturesByFrameName[item]!.add(image);
          }
        }
      }

      widget.setCache(widget.name, spriteTexturesByFrameName);

      spriteImages = spriteTexturesByFrameName[widget.startFrameName]!;
    } else {
      List<Map<String, dynamic>>? spriteToRender = widget.startFrameName != null ? spriteData[widget.startFrameName] : spriteData[widget.delimiters[0]];
      if (props.width != null && spriteData.length == 0) {
        for (var i = 0; i < props.width! / sliceWidth; i++) {
          File croppedFile = await uiImage.FlutterNativeImage.cropImage(path.path, sliceWidth * i, 0, sliceWidth, sliceHeight);

          Uint8List bytes = croppedFile.readAsBytesSync();
          ui.Image image = await loadImage(bytes);
          spriteImages.add(image);
        }
      } else {
        spriteImages.clear();
        if (spriteToRender != null) {
          /// do split based on json data x, y
          for (var i = 0; i < spriteToRender.length; i++) {
            File croppedFile = await uiImage.FlutterNativeImage.cropImage(path.path, spriteToRender[i]['x'], spriteToRender[i]['y'], spriteToRender[i]["width"], spriteToRender[i]['height']);

            Uint8List bytes = croppedFile.readAsBytesSync();
            ui.Image image = await loadImage(bytes);
            spriteImages.add(image);
          }
        }
      }
    }

    if (mounted) {
      setState(() => {});

      try {
        if (spriteImages.length > 0) {
          await path.delete(recursive: false);
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

  Future<File> loadImageTexture(String spriteTexture) async {
    final ByteData data = await rootBundle.load(spriteTexture);

    String dir = (await getApplicationDocumentsDirectory()).path;
    File path = await writeToFile(data, '$dir/tempfile1.png');

    return path;
  }

//write to app path
  Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
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

    print(sprites);
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
    print(spriteImages.length);
    if (spriteImages.length > 0) {
      return Positioned(
        left: widget.constraints["width"]! * 0.5 - spriteImages[0].width * (widget.scale ?? 1) * 0.5,
        top: widget.constraints["height"]! * 0.5 - spriteImages[0].height * (widget.scale ?? 1) * 0.5,
        child: Transform.scale(
          scale: widget.scale ?? 1.0,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: SpriteAnimator(controller: _spriteController, static: false, images: spriteImages, fps: 24, currentImageIndex: 0, loop: widget.loop == true ? LoopMode.Repeat : LoopMode.Single),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
