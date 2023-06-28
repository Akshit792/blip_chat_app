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

class SetUnReadMessagesAsReadEvent extends MessagesEvent {
  final BuildContext context;
  final Channel channel;

  SetUnReadMessagesAsReadEvent({
    required this.context,
    required this.channel,
  });
}

class PickImageMessageEvent extends MessagesEvent {
  final BuildContext context;
  final bool isSourceGallery;

  PickImageMessageEvent({
    required this.context,
    required this.isSourceGallery,
  });
}

class DeleteMessageEvent extends MessagesEvent {
  final BuildContext context;

  DeleteMessageEvent({
    required this.context,
  });
}

class SelectOrUnselectMessageEvent extends MessagesEvent {
  final BuildContext context;
  final bool isSelect;
  final Message message;
  final bool? isClear;

  SelectOrUnselectMessageEvent({
    required this.context,
    required this.isSelect,
    required this.message,
    this.isClear,
  });
}

class LaunchMessagelinkEvent extends MessagesEvent {
  final BuildContext context;
  final String link;

  LaunchMessagelinkEvent({
    required this.context,
    required this.link,
  });
}

class OnMessageListScroll extends MessagesEvent {
  OnMessageListScroll();
}
