import 'dart:async';

class ActionManager {
  StreamController actionController = new StreamController.broadcast();

  // define constructor here
  ActionManager() {
    actionController.onCancel = () => {actionController.close()};
  }

  sendUp() {
    actionController.add("up"); // send an arbitrary event
  }

  sendDown() {
    actionController.add("down"); // send an arbitrary event
  }

  sendLeft() {
    actionController.add("left"); // send an arbitrary event
  }

  sendRight() {
    actionController.add("right"); // send an arbitrary event
  }

  Stream get actionDone => actionController.stream;
}
