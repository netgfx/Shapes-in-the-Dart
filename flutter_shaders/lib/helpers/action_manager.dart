import 'dart:async';
import 'dart:math';

enum PointerEvents { CLICK, DRAG_START, DRAG_MOVE, DRAG_END, TAP, LONG_TAP }

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
    actionController.add({"type": PointerEvents.CLICK, "data": Point<double>(x, y)});
  }

  sendDragStart(double x, double y) {
    actionController.add({"type": PointerEvents.DRAG_START, "data": Point<double>(x, y)});
  }

  sendDragMove(double x, double y) {
    actionController.add({"type": PointerEvents.DRAG_MOVE, "data": Point<double>(x, y)});
  }

  sendDragEnd(double x, double y) {
    actionController.add({"type": PointerEvents.DRAG_END, "data": Point<double>(x, y)});
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
