import 'dart:io';

import 'package:blip_chat_app/common/constants.dart';
import 'package:flutter/material.dart';
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

  @override
  void didChangeDependencies() {
    _initiliseData();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
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
                  Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.grey.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.6),
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
                              height: 60,
                              width: 60,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                border: (selectedImageIndex == index)
                                    ? Border.all(color: ColorConstants.yellow)
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
                ],
              )
            : const Text('No images'),
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
}
