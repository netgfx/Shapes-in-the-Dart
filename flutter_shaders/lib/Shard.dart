import 'dart:math';
import 'dart:ui';

class Shard {
  Point<double> a;
  Point<double> b;
  Point<double> c;
  double speed = 0.1;
  Color color = Color.fromARGB(1, 0, 0, 0);
  int timeAlive;
  double timeToLive;
  double renderDelay = 0;
  int opacity = 255;
  double scale = 1.0;
  double rotateX = 0;
  double rotateY = 0;
  Paint painter;

  Shard(
      {required this.a,
      required this.b,
      required this.c,
      required this.speed,
      required this.color,
      required this.timeAlive,
      required this.timeToLive,
      required this.renderDelay,
      required this.opacity,
      required this.painter}) {
    //print("init particle");
  }

  Point<double> getA() {
    return a;
  }

  Point<double> getB() {
    return b;
  }

  Point<double> getC() {
    return c;
  }

  double getSpeed() {
    return speed;
  }

  Color getColor() {
    return color;
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

  int getOpacity() {
    return opacity;
  }

  double getScale() {
    return scale;
  }

  double getRotationX() {
    return rotateX;
  }

  double getRotationY() {
    return rotateY;
  }

  Paint getPainter() {
    return painter;
  }
}
