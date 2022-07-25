import 'dart:async';
import 'dart:math';

class ActionManager {
  StreamController actionController = new StreamController.broadcast();
  StreamSubscription? listenable;
  // define constructor here
  ActionManager() {
    actionController.onCancel = () => {
          //   actionController.close(),
        };
  }

  set coords(Map<String, double> pos) {
    actionController.sink.add(pos);
  }

  Map<String, double> get coords {
    return this.coords;
  }

  sendAnimation(double x, double y, String spriteName, String frame) {
    //actionController.sink.add({x, y});
    actionController.add({"type": 'animation', "name": spriteName, "frame": frame, "data": Point(x, y)});
  }

  sendClick(double x, double y) {
    //actionController.sink.add({x, y});
    actionController.add({"type": 'click', "data": Point<double>(x, y)});
  }

  sendTop() {
    actionController.add("top"); // send an arbitrary event
  }

  sendBottom() {
    actionController.add("bottom"); // send an arbitrary event
  }

  sendLeft() {
    actionController.add("left"); // send an arbitrary event
  }

  sendRight() {
    actionController.add("right"); // send an arbitrary event
  }

  void addListener(Function(dynamic)? callback) async {
    if (listenable != null) {
      await listenable?.cancel();
    }
    listenable = this.actionDone.listen(callback);
  }

  Stream get actionDone => actionController.stream;
}
