import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

abstract class StoriesEvent {}

class OnNewCameraSelected extends StoriesEvent {
  final BuildContext context;
  final CameraDescription cameraDescription;
  final bool isFlipMode;

  OnNewCameraSelected({
    required this.cameraDescription,
    required this.context,
    this.isFlipMode = false,
  });
}

class FlipCameraEvent extends StoriesEvent {
  final BuildContext context;

  FlipCameraEvent({
    required this.context,
  });
}

class ChangeCameraFlashModeEvent extends StoriesEvent {
  final BuildContext context;
  final FlashMode flashmode;

  ChangeCameraFlashModeEvent({
    required this.context,
    required this.flashmode,
  });
}

class ChangeCameraZoomLevelEvent extends StoriesEvent {
  final BuildContext context;
  final double zoomLevel;

  ChangeCameraZoomLevelEvent({
    required this.context,
    required this.zoomLevel,
  });
}

class TakePictureEvent extends StoriesEvent {
  final BuildContext context;

  TakePictureEvent({
    required this.context,
  });
}
