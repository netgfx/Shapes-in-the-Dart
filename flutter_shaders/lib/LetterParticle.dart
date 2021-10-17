import 'dart:math';
import 'dart:ui';

class LetterParticle {
  double x;
  double y;
  double radius;
  double speed = 0.1;
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
      required this.speed,
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

  double getSpeed() {
    return speed;
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
