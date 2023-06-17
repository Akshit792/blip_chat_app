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
  final ScrollController _scrollController = ScrollController();
  CameraController? controller;
  FlashMode? _currentFlashMode;
  bool _isCameraInitialized = false, _isRearCameraSelected = true;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;
  double turns = 0.0;

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

  void _flipCamera() {
    setState(() {
      _isCameraInitialized = false;
    });

    _isRearCameraSelected = !_isRearCameraSelected;

    onNewCameraSelected(
      cameras[_isRearCameraSelected ? 0 : 1],
    );

    turns = (turns == 0.0) ? 0.5 : 0.0;

    setState(() {});
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
                  padding: const EdgeInsets.only(top: 5),
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.10,
                  ),
                  height: 60,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 70,
                        width: 60,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(200),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 70,
                        width: 60,
                        alignment: Alignment.center,
                        child: ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: Constants.cameraFlashModes.length,
                          itemBuilder: (context, index) {
                            var flashModeData =
                                Constants.cameraFlashModes[index];
                            return SizedBox(
                              height: 50,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(200),
                                  onTap: () async {
                                    double jumpIndexValue = index + 1;

                                    if (jumpIndexValue ==
                                        Constants.cameraFlashModes.length) {
                                      jumpIndexValue = 0;
                                    }

                                    if (flashModeData['mode'] == 'flash_on') {
                                      _currentFlashMode = FlashMode.torch;
                                    } else if (flashModeData['mode'] ==
                                        'flash_off') {
                                      _currentFlashMode = FlashMode.off;
                                    } else {
                                      _currentFlashMode = FlashMode.auto;
                                    }

                                    await controller!.setFlashMode(
                                      _currentFlashMode ?? FlashMode.off,
                                    );

                                    final desiredOffset = jumpIndexValue * 50.0;

                                    _scrollController.animateTo(
                                      desiredOffset,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  },
                                  child: Icon(
                                    flashModeData['icon'],
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 100,
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    left: 10,
                    top: MediaQuery.of(context).size.height * 0.67,
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
                ),
                Container(
                  height: 80,
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.78,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      SizedBox(
                        height: 50,
                        width: 60,
                        child: Material(
                          color: Colors.transparent,
                          child: AnimatedRotation(
                            turns: turns,
                            duration: const Duration(milliseconds: 300),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(200),
                              onTap: _flipCamera,
                              child: const Icon(
                                Icons.flip_camera_android,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

      _currentFlashMode = controller!.value.flashMode;

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
