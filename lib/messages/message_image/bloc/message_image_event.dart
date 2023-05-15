import 'dart:io';

import 'package:flutter/material.dart';

abstract class MessageImageEvent {}

class ChangeSelectedImageEvent extends MessageImageEvent {
  final BuildContext context;
  final int currentIndex;

  ChangeSelectedImageEvent({
    required this.context,
    required this.currentIndex,
  });
}

class CropSelectedImageEvent extends MessageImageEvent {
  final BuildContext context;
  final File imageFile;

  CropSelectedImageEvent({
    required this.context,
    required this.imageFile,
  });
}

class SendMessageImageAttachmentEvent extends MessageImageEvent {
  final BuildContext context;
  final String captionText;

  SendMessageImageAttachmentEvent({
    required this.context,
    required this.captionText,
  });
}
