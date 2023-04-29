import 'package:flutter/widgets.dart';

abstract class ChannelsEvent {}

class InitilizeChannelListControllerEvent extends ChannelsEvent {
  final BuildContext context;

  InitilizeChannelListControllerEvent({required this.context});
}
