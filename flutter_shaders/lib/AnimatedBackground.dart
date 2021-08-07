import 'package:flutter/widgets.dart';
import 'package:simple_animations/simple_animations.dart';

class AnimatedBackground extends StatelessWidget {
  BoxConstraints constraints;
  double start = 0;
  AnimatedBackground({Key? key, required this.constraints, s}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween(begin: start, end: this.constraints.maxHeight * 2),
        duration: Duration(seconds: 5),
        onEnd: () => {start = 0},
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
