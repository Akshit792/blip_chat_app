// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/messages/message_image/bloc/message_event_state.dart';
import 'package:blip_chat_app/messages/message_image/bloc/message_image_bloc.dart';
import 'package:blip_chat_app/messages/message_image/bloc/message_image_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class MessageImageScreen extends StatefulWidget {
  const MessageImageScreen({super.key});

  @override
  State<MessageImageScreen> createState() => _MessageImageScreenState();
}

class _MessageImageScreenState extends State<MessageImageScreen> {
  late Channel channel;
  late List<XFile> selectedImages;
  late List<File> imagesList = [];
  int selectedImageIndex = 0;
  String captionText = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageImageBloc, MessageImageState>(
      builder: (context, state) {
        var messageImageBloc = BlocProvider.of<MessageImageBloc>(context);

        if (state is InitialMessagesImageState ||
            state is LoadedCropImageState) {
          channel = messageImageBloc.channel;
          imagesList = messageImageBloc.imagesList;
          selectedImages = messageImageBloc.selectedImages;
        }

        selectedImageIndex = messageImageBloc.selectedDataIndex;

        return WillPopScope(
          onWillPop: () async {
            messageImageBloc.clearImages(context: context);
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: ColorConstants.yellow,
              leading: IconButton(
                onPressed: () {
                  messageImageBloc.clearImages(context: context);

                  Navigator.of(context).maybePop();
                },
                icon: const Icon(
                  Icons.close,
                  color: ColorConstants.black,
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      messageImageBloc.add(
                        CropSelectedImageEvent(
                          context: context,
                          imageFile: imagesList[selectedImageIndex],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.crop,
                      color: ColorConstants.black,
                    )),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            body: Container(
              height: double.infinity,
              width: double.infinity,
              color: ColorConstants.black,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: (imagesList.isNotEmpty)
                  ? Stack(
                      children: [
                        SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: Image(
                            image: FileImage(
                              imagesList[selectedImageIndex],
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 60,
                              width: double.infinity,
                              color: Colors.grey.withOpacity(0.15),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ListView.builder(
                                  itemCount: imagesList.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        messageImageBloc.add(
                                          ChangeSelectedImageEvent(
                                              context: context,
                                              currentIndex: index),
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        margin: const EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                          border: (selectedImageIndex == index)
                                              ? Border.all(
                                                  color: ColorConstants.yellow)
                                              : null,
                                        ),
                                        child: Image(
                                          image: FileImage(
                                            imagesList[index],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 45),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                      child: TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: captionText,
                                      ),
                                    ),
                                    maxLines: null,
                                    onChanged: (val) {
                                      captionText = val;
                                    },
                                    decoration: InputDecoration(
                                      hintText: ('Add a caption...'),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintStyle: const TextStyle(
                                        color: ColorConstants.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 20,
                                      ),
                                      border: InputBorder.none,
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: ColorConstants.grey,
                                            width: 1.4,
                                          )),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: ColorConstants.grey,
                                          width: 1.4,
                                        ),
                                      ),
                                    ),
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 10),
                                    child: Material(
                                      type: MaterialType.circle,
                                      color: ColorConstants.yellow,
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        onTap: () async {
                                          if (state
                                              is! SendingMessageImageState) {
                                            messageImageBloc.add(
                                              SendMessageImageAttachmentEvent(
                                                  context: context,
                                                  captionText: captionText),
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: (state
                                                  is SendingMessageImageState)
                                              ? Container(
                                                  height: 30,
                                                  width: 30,
                                                  alignment: Alignment.center,
                                                  child:
                                                      const CircularProgressIndicator
                                                          .adaptive(
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.send,
                                                  color: Colors.black,
                                                  size: 20,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  : const Text('No images'),
            ),
          ),
        );
      },
    );
  }
}
