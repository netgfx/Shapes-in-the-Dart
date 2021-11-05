import 'dart:math';
import 'dart:ui';

class Star {
  double x;
  double y;
  double z;
  double radius;
  double progress = 0.0;
  Color color;
  int timeAlive;
  int currentTime;
  double timeToLive;
  double renderDelay = 0;
  double opacity = 1.0;
  Paint? painter;

  Star(
      {required this.x,
      required this.y,
      required this.z,
      required this.radius,
      required this.progress,
      required this.color,
      required this.timeAlive,
      required this.currentTime,
      required this.timeToLive,
      required this.opacity,
      required this.painter}) {
    //print("init particle");
  }

  double getX() {
    return x;
  }

  double getY() {
    return y;
  }

  double getZ() {
    return z;
  }

  double getRadius() {
    return radius;
  }

  double getProgress() {
    return progress;
  }

  Color getColor() {
    return color;
  }

  int getCurrentTime() {
    return currentTime;
  }

  int getTimeAlive() {
    return timeAlive;
  }

  double getTimeToLive() {
    return timeToLive;
  }

  double getRenderDelay() {
    return renderDelay;
  }

  double getOpacity() {
    return opacity;
  }

  Paint? getPainter() {
    return painter;
  }
}
