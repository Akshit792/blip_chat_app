import 'package:flutter/material.dart';

abstract class MessagesEvent {}

class SendMessageEvent extends MessagesEvent {
  final BuildContext context;

  SendMessageEvent({required this.context});
}
