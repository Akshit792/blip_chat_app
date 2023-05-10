// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/messages/bloc/messages_event.dart';
import 'package:blip_chat_app/messages/bloc/messages_state.dart';
import 'package:blip_chat_app/messages/message_image/message_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  StreamSubscription<int>? unreadCountSubscription;
  Channel? channel;
  List<XFile> selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  MessagesBloc() : super(InitialMessagesState()) {
    on<SetUnReadMessagesAsRead>((event, emit) async {
      try {
        channel = event.channel;
        unreadCountSubscription =
            event.channel.state!.unreadCountStream.listen(_unreadCountHandler);
      } on Exception catch (e, s) {
        LogPrint.error(
            error: e, errorMsg: 'Set Unread Messages As Read', stackTrace: s);
      }
    });
    on<SendMessageEvent>((event, emit) async {
      try {
        await channel!.sendMessage(event.message);
        emit(LoadedMessagesState());
      } on Exception catch (e, s) {
        LogPrint.error(error: e, errorMsg: 'Send Message Event', stackTrace: s);
      }
    });
    on<TakeImageMessageEvent>((event, emit) async {
      try {
        ImageSource source =
            event.isSourceGallery ? ImageSource.gallery : ImageSource.camera;

        if (event.isSourceGallery) {
          final List<XFile> images = await _imagePicker.pickMultiImage();
          // TODO:

          selectedImages.addAll(images);
        } else {
          XFile? selectedPicture = await _imagePicker.pickImage(source: source);

          if (selectedPicture != null) {
            selectedImages.add(selectedPicture);
          }
        }

        var arguments = {
          'channel': channel,
          'selected_images': selectedImages,
        };

        Navigator.of(event.context).push(
          MaterialPageRoute(
              builder: (context) {
                return const MessageImageScreen();
              },
              settings: RouteSettings(
                arguments: arguments,
              )),
        );
      } on Exception catch (e, s) {
        LogPrint.error(
            error: e, errorMsg: 'Take Image Message Event', stackTrace: s);
      }
    });
  }

  Future<void> _unreadCountHandler(int count) async {
    if (count > 0) {
      await channel!.markRead();
    }
  }

  void cancelUnreadCountStream() {
    if (unreadCountSubscription != null) {
      unreadCountSubscription!.cancel();
    }
  }

  void clearSelectedImages() {
    selectedImages.clear();
  }
}
