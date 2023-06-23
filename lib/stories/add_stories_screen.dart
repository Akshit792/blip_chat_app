// ignore_for_file: use_build_context_synchronously

import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/stories/bloc/stories_bloc.dart';
import 'package:blip_chat_app/stories/bloc/stories_event.dart';
import 'package:blip_chat_app/stories/bloc/stories_state.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddStoriesScreen extends StatefulWidget {
  const AddStoriesScreen({super.key});

  @override
  State<AddStoriesScreen> createState() => _AddStoriesScreenState();
}

class _AddStoriesScreenState extends State<AddStoriesScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController animationController;
  bool _isPhotoMode = true;
  late StoriesBloc storiesBloc;
  double turns = 0.0;
  bool isCaptureButtonPressed = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    WidgetsBinding.instance.addObserver(this);

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    super.initState();
  }

  @override
  void didChangeDependencies() {
    storiesBloc = BlocProvider.of<StoriesBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    storiesBloc.disposeCameraController();
    animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = storiesBloc.controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      storiesBloc.add(
        OnNewCameraSelected(
          context: context,
          cameraDescription: cameraController.description,
        ),
      );
    }
  }

  void _flipCamera() {
    turns = (turns == 0.0) ? 0.5 : 0.0;

    animationController.forward();

    BlocProvider.of<StoriesBloc>(context)
        .add(FlipCameraEvent(context: context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoriesBloc, StoriesState>(
      builder: (context, state) {
        if (state is InitialStoriesState) {
          storiesBloc.add(
            OnNewCameraSelected(
              context: context,
              cameraDescription: cameras[0],
            ),
          );

          return _flipCameraIndicator();
        }

        if (state is CameraNotInitilizedState) {
          return _flipCameraIndicator();
        }

        return Scaffold(
            body: Stack(
          children: [
            (state is CameraInitilizedState)
                ? Container(
                    color: ColorConstants.black,
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      width: double.infinity,
                      child: storiesBloc.controller!.buildPreview(),
                    ),
                  )
                : _flipCameraIndicator(),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.14,
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
                        var flashModeData = Constants.cameraFlashModes[index];
                        return SizedBox(
                          height: 50,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(200),
                              onTap: () async {
                                FlashMode? currentFlashMode;
                                double jumpIndexValue = index + 1;

                                if (jumpIndexValue ==
                                    Constants.cameraFlashModes.length) {
                                  jumpIndexValue = 0;
                                }

                                if (flashModeData['mode'] == 'flash_on') {
                                  currentFlashMode = FlashMode.torch;
                                } else if (flashModeData['mode'] ==
                                    'flash_off') {
                                  currentFlashMode = FlashMode.off;
                                } else {
                                  currentFlashMode = FlashMode.auto;
                                }

                                storiesBloc.add(
                                  ChangeCameraFlashModeEvent(
                                    context: context,
                                    flashmode: currentFlashMode,
                                  ),
                                );

                                final desiredOffset = jumpIndexValue * 50.0;

                                _scrollController.animateTo(
                                  desiredOffset,
                                  duration: const Duration(milliseconds: 500),
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
                top: MediaQuery.of(context).size.height * 0.65,
                right: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: storiesBloc.currentZoomLevel,
                      min: storiesBloc.minAvailableZoom,
                      max: storiesBloc.maxAvailableZoom,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                      onChanged: (value) async {
                        storiesBloc.add(
                          ChangeCameraZoomLevelEvent(
                            context: context,
                            zoomLevel: value,
                          ),
                        );
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
                        '${storiesBloc.currentZoomLevel.toStringAsFixed(1)}x',
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
                top: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  InkWell(
                    onTap: () async {
                      isCaptureButtonPressed = true;
                      setState(() {});

                      await Future.delayed(
                        const Duration(
                          milliseconds: 200,
                        ),
                      );

                      isCaptureButtonPressed = false;
                      setState(() {});

                      storiesBloc.add(
                        TakePictureEvent(context: context),
                      );
                    },
                    child: AnimatedContainer(
                      height: isCaptureButtonPressed ? 80 : 70,
                      width: isCaptureButtonPressed ? 80 : 70,
                      curve: Curves.easeIn,
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4.0,
                          color: Colors.white,
                        ),
                      ),
                      child: AnimatedContainer(
                        height: isCaptureButtonPressed ? 70 : 50,
                        width: isCaptureButtonPressed ? 70 : 50,
                        margin: const EdgeInsets.all(8),
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
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
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SizedBox(
                height: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(
                            () {
                              _isPhotoMode = !_isPhotoMode;
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 7,
                            horizontal: 20,
                          ),
                          decoration: (_isPhotoMode)
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: ColorConstants.yellow,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                )
                              : null,
                          child: Text(
                            'Image',
                            style: TextStyle(
                              color: (_isPhotoMode)
                                  ? ColorConstants.yellow
                                  : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(
                            () {
                              _isPhotoMode = !_isPhotoMode;
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 7,
                            horizontal: 20,
                          ),
                          decoration: (!_isPhotoMode)
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: ColorConstants.yellow,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                )
                              : null,
                          child: Text(
                            'Video',
                            style: TextStyle(
                              color: (_isPhotoMode)
                                  ? Colors.white
                                  : ColorConstants.yellow,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
      },
    );
  }

  Widget _flipCameraIndicator() {
    return Container(
      height: double.infinity,
      alignment: Alignment.center,
      color: Colors.black,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: double.infinity,
        color: ColorConstants.grey.withOpacity(0.1),
      ),
    );
  }
}
