import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

abstract class MessagesEvent {}

class SendMessageEvent extends MessagesEvent {
  final BuildContext context;
  final Message message;

  SendMessageEvent({
    required this.context,
    required this.message,
  });
}

class SetUnReadMessagesAsRead extends MessagesEvent {
  final BuildContext context;
  final Channel channel;

  SetUnReadMessagesAsRead({
    required this.context,
    required this.channel,
  });
}

class TakeImageMessageEvent extends MessagesEvent {
  final BuildContext context;
  final bool isSourceGallery;

  TakeImageMessageEvent({
    required this.context,
    required this.isSourceGallery,
  });
}
