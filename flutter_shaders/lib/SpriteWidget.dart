import 'package:flutter/widgets.dart';
import 'package:flutter_shaders/SpriteAnimator.dart';
import 'dart:ui' as ui;

class SpriteWidget extends StatelessWidget {
  final int startingIndex;
  final int desiredFPS;
  final bool loop;
  final Map<String, int> constraints;
  final AnimationController spriteController;
  List<ui.Image>? spriteImages = [];
  SpriteWidget({Key? key, required this.startingIndex, required this.desiredFPS, required this.loop, required this.constraints, required this.spriteController, this.spriteImages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (spriteImages != null) {
      return Positioned(
        left: this.constraints["width"]! * 0.5 - spriteImages![0].width * 0.5,
        top: this.constraints["height"]! * 0.5 - spriteImages![0].height * 0.5,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: SpriteAnimator(controller: this.spriteController, loop: true, images: spriteImages!, fps: 24, currentImageIndex: 0),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
