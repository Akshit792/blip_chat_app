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
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;

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
          ? Stack(
              children: [
                Container(
                  color: ColorConstants.black,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    width: double.infinity,
                    child: controller!.buildPreview(),
                  ),
                ),
                Container(
                  height: 100,
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    left: 10,
                    top: MediaQuery.of(context).size.height * 0.76,
                    right: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _currentZoomLevel,
                          min: _minAvailableZoom,
                          max: _maxAvailableZoom,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white30,
                          onChanged: (value) async {
                            setState(
                              () {
                                _currentZoomLevel = value;
                              },
                            );
                            await controller!.setZoomLevel(value);
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${_currentZoomLevel.toStringAsFixed(1)}x',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
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

    try {
      await cameraController.initialize();

      cameraController
          .getMaxZoomLevel()
          .then((value) => _maxAvailableZoom = value);

      cameraController
          .getMinZoomLevel()
          .then((value) => _minAvailableZoom = value);

      cameraController.addListener(
        () {
          if (mounted) setState(() {});
        },
      );
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
