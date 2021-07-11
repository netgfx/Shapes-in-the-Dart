import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart' as uiImage;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:image/image.dart' as libImage;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class BlendModeView extends StatefulWidget {
  BlendModeView({Key? key}) : super(key: key);

  @override
  _BlendModeViewState createState() => _BlendModeViewState();
}

class _BlendModeViewState extends State<BlendModeView> {
  ui.Image? patImage;
  String logoImage = "assets/logo.png";
  double _currentSliderValue = 100;
  late File tempPath;
  late File _image;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    loadPatImage("assets/pat/pat1.png");
  }

  void loadPatImage(String path) async {
    ui.Image tempImg = await getImage(path);

    if (mounted) {
      setState(() {
        patImage = tempImg;
        _currentSliderValue = 100;
      });
    }
  }

  Future<ui.Image> getImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    ui.Image image = await loadImage(new Uint8List.view(data.buffer));

    String dir = (await getApplicationDocumentsDirectory()).path;
    File _path = await writeToFile(data, '$dir/tempfile1.png');
    tempPath = _path;

    return image;
  }

  //write to app path
  Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void resizePatImage() async {
    //print("resize run $logoImage");
    if (patImage != null) {
      Uint8List bytes = await tempPath.readAsBytes();

      int w = (1024 * _currentSliderValue / 100).round();
      int h = (1024 * _currentSliderValue / 100).round();

      Uint8List list = await testComporessList(bytes, w, h);

      ui.decodeImageFromList(list, (result) {
        print(result);
        setState(() {
          patImage = result;
        });
      });
    }
  }

  Future<Uint8List> testComporessList(Uint8List list, int width, int height) async {
    var result = await FlutterImageCompress.compressWithList(list, minHeight: width, minWidth: height, format: CompressFormat.png);
    //print(list.length);
    //print(result.length);
    return result;
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera() async {
    final PickedFile? image = await _picker.getImage(source: ImageSource.camera, imageQuality: 50);
    if (image == null) {
      return;
    }
    tempPath = File(image.path);
    Uint8List finalImage = await image.readAsBytes();
    Uint8List list = await testComporessList(finalImage, 1024, 1024);
    ui.decodeImageFromList(list, (result) {
      setState(() {
        patImage = result;
      });
    });
  }

  _imgFromGallery() async {
    final PickedFile? image = await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (image == null) {
      return;
    }
    tempPath = File(image.path);
    Uint8List finalImage = await image.readAsBytes();
    Uint8List list = await testComporessList(finalImage, 1024, 1024);
    ui.decodeImageFromList(list, (result) {
      setState(() {
        patImage = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white10,
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Stack(fit: StackFit.expand, children: [
            ShaderMask(
                shaderCallback: (Rect bounds) {
                  print(">>>>>> $patImage");
                  return patImage != null
                      ? ImageShader(patImage!, TileMode.repeated, TileMode.repeated, Float64List.fromList(Matrix4.identity().storage))
                      : RadialGradient(
                          radius: 100,
                          center: Alignment.topCenter,
                          colors: <Color>[Colors.deepPurple, Colors.black87],
                          tileMode: TileMode.clamp,
                        ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Stack(children: [
                  Image(
                    image: AssetImage(logoImage),
                    fit: BoxFit.fill,
                  ),
                ])),
            Positioned(
                top: 600,
                left: 20,
                right: 20,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: viewportConstraints.maxWidth - 200, maxHeight: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                            onTap: () {
                              _showPicker(context);
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/upload.png"),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                            onTap: () {
                              loadPatImage("assets/pat/pat1.png");
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/pat/pat1.png"),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                            onTap: () {
                              loadPatImage("assets/pat/pat2.png");
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/pat/pat2.png"),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                            onTap: () {
                              loadPatImage("assets/pat/pat3.png");
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/pat/pat3.png"),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                            onTap: () {
                              loadPatImage("assets/pat/pat4.png");
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/pat/pat4.png"),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                            onTap: () {
                              loadPatImage("assets/pat/pat5.png");
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/pat/pat5.png"),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                            onTap: () {
                              loadPatImage("assets/pat/pat6.jpg");
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/pat/pat6.jpg"),
                            ))
                      ],
                    ),
                  )),
                )),
            Positioned(
                bottom: 50,
                child: SizedBox(
                    width: viewportConstraints.maxWidth,
                    child: Slider(
                        value: _currentSliderValue,
                        min: 10,
                        max: 100,
                        divisions: 5,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _currentSliderValue = value;
                          });
                          resizePatImage();
                        }))),
          ]);
        }));
  }
}
