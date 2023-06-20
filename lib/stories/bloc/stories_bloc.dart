// ignore_for_file: use_build_context_synchronously

import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/stories/bloc/stories_event.dart';
import 'package:blip_chat_app/stories/bloc/stories_state.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';

class StoriesBloc extends Bloc<StoriesEvent, StoriesState> {
  CameraController? controller;
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentZoomLevel = 1.0;
  FlashMode? currentFlashMode;
  bool _isRearCameraSelected = true;
  bool _isPhotoMode = true;

  StoriesBloc() : super(InitialStoriesState()) {
    on<OnNewCameraSelected>(
      (event, emit) async {
        if (!event.isFlipMode) {
          emit(CameraNotInitilizedState());
        }

        final previousCameraController = controller;

        final CameraController cameraController = CameraController(
          event.cameraDescription,
          ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await previousCameraController?.dispose();

        controller = cameraController;

        try {
          await cameraController.initialize();

          cameraController
              .getMaxZoomLevel()
              .then((value) => maxAvailableZoom = value);

          cameraController
              .getMinZoomLevel()
              .then((value) => minAvailableZoom = value);

          currentFlashMode = controller!.value.flashMode;
        } on CameraException catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: 'Camera Controller Initilize',
            stackTrace: s,
          );
        }

        emit(CameraInitilizedState());
      },
    );
    on<ChangeCameraFlashModeEvent>(
      (event, emit) async {
        await controller?.setFlashMode(event.flashmode);
        emit(CameraInitilizedState());
      },
    );
    on<ChangeCameraZoomLevelEvent>(
      (event, emit) async {
        currentZoomLevel = event.zoomLevel;
        await controller!.setZoomLevel(currentZoomLevel);
        emit(CameraInitilizedState());
      },
    );
    on<FlipCameraEvent>((event, emit) async {
      _isRearCameraSelected = !_isRearCameraSelected;

      add(
        OnNewCameraSelected(
          cameraDescription: cameras[_isRearCameraSelected ? 0 : 1],
          isFlipMode: true,
          context: event.context,
        ),
      );
    });
  }

  void disposeCameraController() {
    controller!.dispose();
  }
}
