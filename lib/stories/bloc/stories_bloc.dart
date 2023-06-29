// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/stories/bloc/stories_event.dart';
import 'package:blip_chat_app/stories/bloc/stories_state.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_bloc.dart';
import 'package:blip_chat_app/view_images/view_images_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

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
          ResolutionPreset.veryHigh,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await previousCameraController?.dispose();

        controller = cameraController;

        try {
          await cameraController.initialize();

          cameraController.getMaxZoomLevel().then(
                (value) => maxAvailableZoom = value,
              );

          cameraController.getMinZoomLevel().then(
                (value) => minAvailableZoom = value,
              );

          currentFlashMode = controller!.value.flashMode;
        } on CameraException catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: 'Camera Controller Initilize',
            stackTrace: s,
          );
        }

        emit(
          CameraInitilizedState(),
        );
      },
    );
    on<ChangeCameraFlashModeEvent>(
      (event, emit) async {
        if (controller != null && controller!.value.isInitialized) {
          currentFlashMode = event.flashmode;

          await controller?.setFlashMode(
            currentFlashMode ?? FlashMode.off,
          );

          emit(
            CameraInitilizedState(),
          );
        }
      },
    );
    on<ChangeCameraZoomLevelEvent>(
      (event, emit) async {
        if (controller != null && controller!.value.isInitialized) {
          currentZoomLevel = event.zoomLevel;

          await controller!.setZoomLevel(
            currentZoomLevel,
          );

          emit(
            CameraInitilizedState(),
          );
        }
      },
    );
    on<FlipCameraEvent>(
      (event, emit) async {
        _isRearCameraSelected = !_isRearCameraSelected;

        add(
          OnNewCameraSelected(
            context: event.context,
            isFlipMode: true,
            cameraDescription: cameras[_isRearCameraSelected ? 0 : 1],
          ),
        );
      },
    );
    on<TakePictureEvent>(
      (event, emit) async {
        if (controller != null && controller!.value.isInitialized) {
          if (controller!.value.isTakingPicture) {
            LogPrint.info(infoMsg: 'Old picture state');
          } else {
            try {
              XFile? rawImage = await controller!.takePicture();

              File imageFile = File(rawImage.path);

              int currentUnix = DateTime.now().millisecondsSinceEpoch;

              final directory = await getApplicationDocumentsDirectory();

              String fileFormat = imageFile.path.split('.').last;

              await imageFile.copy(
                '${directory.path}/$currentUnix.$fileFormat',
              );

              Navigator.of(event.context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return BlocProvider(
                      create: (BuildContext context) => ViewImageBloc(
                        imagesUrl: [rawImage.path],
                        isImageTypeNetwork: false,
                      ),
                      child: const ViewImageScreen(),
                    );
                  },
                ),
              );
            } catch (e, s) {
              LogPrint.error(
                  error: e, errorMsg: 'Take Pictire Events', stackTrace: s);
            }
          }
        }
      },
    );
  }

  void disposeCameraController() {
    controller!.dispose();
  }
}
