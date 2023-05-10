// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/messages/bloc/messages_bloc.dart';
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
  bool isDataInitilised = false;
  int selectedImageIndex = 0;
  String captionText = '';

  @override
  void didChangeDependencies() {
    _initiliseData();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        clearImages();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              clearImages();
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.close),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.crop)),
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
          child: imagesList.isNotEmpty
              ? Stack(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        width: double.infinity,
                        child: Image(
                            image: FileImage(imagesList[selectedImageIndex]))),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            width: double.infinity,
                            color: Colors.grey.withOpacity(0.15),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.54),
                            child: ListView.builder(
                                itemCount: imagesList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      selectedImageIndex = index;
                                      setState(() {});
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
                                Flexible(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: captionText,
                                      ),
                                    ),
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintText: 'Add a caption...',
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintStyle: const TextStyle(
                                        color: ColorConstants.grey,
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
                                  ),
                                )),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Material(
                                    type: MaterialType.circle,
                                    color: ColorConstants.yellow,
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      onTap: () async {
                                        List<Attachment> attachments = [];
                                        for (var imagesData in imagesList) {
                                          attachments.add(Attachment(
                                              file: AttachmentFile(
                                                  size: imagesData.lengthSync(),
                                                  path: imagesData.path)));
                                        }

                                        Message message = Message(
                                            text: captionText,
                                            attachments: attachments);
                                        await channel.sendMessage(message);

                                        clearImages();
                                        Navigator.of(context).maybePop();
                                      },
                                      child: Container(
                                        height: 45,
                                        width: 45,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
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
                    ),
                  ],
                )
              : const Text('No images'),
        ),
      ),
    );
  }

  void _initiliseData() {
    if (!isDataInitilised) {
      var routeData = ModalRoute.of(context)!.settings.arguments;

      if (routeData != null && routeData is Map) {
        channel = routeData['channel'];
        selectedImages = routeData['selected_images'];

        if (selectedImages.isNotEmpty) {
          for (var imageData in selectedImages) {
            imagesList.add(File(imageData.path));
          }
        }
      }
      isDataInitilised = true;
    }
  }

  void clearImages() {
    BlocProvider.of<MessagesBloc>(context).clearSelectedImages();
  }
}
