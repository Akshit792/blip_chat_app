import 'package:flutter/widgets.dart';

abstract class ChannelsEvent {}

class InitilizeChannelListControllerEvent extends ChannelsEvent {
  final BuildContext context;

  InitilizeChannelListControllerEvent({required this.context});
}

class LoadMoreChannelsEvent extends ChannelsEvent {
  final BuildContext context;

  LoadMoreChannelsEvent({required this.context});
}
