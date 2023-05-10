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
  late XFile imageData;
  late File image;

  @override
  void didChangeDependencies() {
    var routeData = ModalRoute.of(context)!.settings.arguments;

    if (routeData != null && routeData is Map) {
      channel = routeData['channel'];
      imageData = routeData['image'];
      image = File(imageData.path);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: ColorConstants.black,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Image(image: FileImage(image)),
      ),
    );
  }
}
