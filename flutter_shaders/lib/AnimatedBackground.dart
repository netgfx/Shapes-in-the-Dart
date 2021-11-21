import 'package:flutter/widgets.dart';

class AnimatedBackground extends StatelessWidget {
  final BoxConstraints constraints;
  final double start;
  AnimatedBackground({Key? key, required this.constraints, required this.start}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double s = this.start;
    return TweenAnimationBuilder(
        tween: Tween(begin: s, end: this.constraints.maxHeight * 2),
        duration: Duration(seconds: 5),
        onEnd: () => {s = 0},
        builder: (context, num offset, _) {
          return Positioned(
            top: 0,
            bottom: -constraints.maxHeight,
            left: 0,
            width: constraints.maxWidth,
            child: Transform.translate(
              offset: Offset(0, offset.toDouble()),
              child: FittedBox(
                child: Image(
                  width: constraints.maxWidth,
                  image: AssetImage("assets/forest.png"),
                ),
                fit: BoxFit.fitWidth,
                clipBehavior: Clip.none,
              ),
            ),
          );
        });
  }
}
