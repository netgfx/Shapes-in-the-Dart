import 'dart:math';
import 'dart:ui';

class LetterParticle {
  double x;
  double y;
  double radius;
  double progress = 0.0;
  Color color;
  Point endPath;
  int timeAlive;
  int currentTime;
  double timeToLive;
  double renderDelay = 0;
  double opacity = 1.0;
  Paint? painter;

  LetterParticle(
      {required this.x,
      required this.y,
      required this.radius,
      required this.progress,
      required this.endPath,
      required this.color,
      required this.timeAlive,
      required this.currentTime,
      required this.timeToLive,
      required this.renderDelay,
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

  double getRadius() {
    return radius;
  }

  double getProgress() {
    return progress;
  }

  Color getColor() {
    return color;
  }

  Point getEndPath() {
    return endPath;
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
