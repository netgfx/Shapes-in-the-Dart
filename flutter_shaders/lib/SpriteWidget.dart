import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  final String path;
  SpriteWidget({Key? key, required this.path, this.startingIndex, this.desiredFPS, this.loop, required this.constraints}) : super(key: key);

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

    _spriteController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _spriteController.repeat();
    print("re-run");
    loadSprite();
  }

  @override
  void dispose() {
    _spriteController.dispose();

    super.dispose();
  }

  void loadSprite() async {
    List<Map<String, dynamic>> spriteData;
    File imageData = await loadImageTexture(widget.path);
    var data = loadJsonData();
    uiImage.ImageProperties props = await uiImage.FlutterNativeImage.getImageProperties(imageData.path);
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

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

//write to app path
  Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  Widget build(BuildContext context) {
    print(spriteImages.length);
    if (spriteImages.length > 0) {
      return Positioned(
        left: widget.constraints["width"]! * 0.5 - spriteImages[0].width * 0.5,
        top: widget.constraints["height"]! * 0.5 - spriteImages[0].height * 0.5,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: SpriteAnimator(controller: _spriteController, loop: true, images: spriteImages, fps: 24, currentImageIndex: 0),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
