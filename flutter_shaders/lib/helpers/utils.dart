import 'dart:math';

class Utils {
  static Utils shared = Utils._();
  final _random = new Random();
  Utils._();

  static Utils get instance => shared;

  double doubleInRange(double start, double end) {
    if (start == end) {
      return start;
    } else {
      return _random.nextDouble() * (end - start) + start;
    }
  }

  double randomDelay({double min = 0.005, double max = 0.05}) {
    if (min == max) {
      return min;
    } else {
      return doubleInRange(min, max);
    }
  }

  double easeOutBack(double x) {
    const c1 = 1.70158;
    const c3 = c1 + 1;

    return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2);
  }

  double easeOutCirc(double x) {
    return sqrt(1 - pow(x - 1, 2));
  }

  double easeOutQuart(double x) {
    return 1 - pow(1 - x, 4).toDouble();
  }

  double easeOutQuad(double x) {
    return 1 - (1 - x) * (1 - x);
  }

  double easeOutCubic(double x) {
    return 1 - pow(1 - x, 3).toDouble();
  }

  double easeOutSine(double x) {
    return sin((x * pi) / 2);
  }

  double easeOutQuint(double x) {
    return 1 - pow(1 - x, 5).toDouble();
  }

  double easeInOutBack(double x) {
    const c1 = 1.70158;
    const c2 = c1 * 1.525;

    return x < 0.5 ? (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2 : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
  }
}
