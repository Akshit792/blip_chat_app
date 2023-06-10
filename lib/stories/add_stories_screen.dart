import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddStoriesScreen extends StatefulWidget {
  const AddStoriesScreen({super.key});

  @override
  State<AddStoriesScreen> createState() => _AddStoriesScreenState();
}

class _AddStoriesScreenState extends State<AddStoriesScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      _isCameraInitialized = false;
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _isCameraInitialized = false;
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_isCameraInitialized)
          ? AspectRatio(
              aspectRatio: (1 / controller!.value.aspectRatio),
              child: controller!.buildPreview(),
            )
          : const SizedBox.shrink(),
    );
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    if (mounted) {
      setState(
        () {
          controller = cameraController;
        },
      );
    }

    cameraController.addListener(
      () {
        if (mounted) setState(() {});
      },
    );

    try {
      await cameraController.initialize();
    } on CameraException catch (e, s) {
      LogPrint.error(
        error: e,
        errorMsg: 'Camera Controller Initilize',
        stackTrace: s,
      );
    }

    if (mounted) {
      setState(
        () {
          _isCameraInitialized = controller!.value.isInitialized;
        },
      );
    }
  }
}


/*
1. Get all available cameras
2. setup the CameraController
3. Handle freeing the memory consumed by the camera in different app lifecycle
4. Get a full screen view
5. 
*/ 
