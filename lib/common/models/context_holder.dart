import 'package:flutter/material.dart';

// Provide global context
class ContextHolder {
  static final key = GlobalKey<NavigatorState>();

  // get current context.
  static BuildContext get currentContext {
    return key.currentContext!;
  }

  //get current widget.
  static Widget get currentWidget {
    return key.currentWidget!;
  }

  //get current overlay
  static OverlayState get currentOverlay {
    return key.currentState!.overlay!;
  }
}
