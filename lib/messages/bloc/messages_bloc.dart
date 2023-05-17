// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:blip_chat_app/common/models/context_holder.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/messages/bloc/messages_event.dart';
import 'package:blip_chat_app/messages/bloc/messages_state.dart';
import 'package:blip_chat_app/messages/message_image/bloc/message_event_state.dart';
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
    on<PickImageMessageEvent>((event, emit) async {
      try {
        ImageSource source =
            event.isSourceGallery ? ImageSource.gallery : ImageSource.camera;

        if (event.isSourceGallery) {
          final List<XFile> images = await _imagePicker.pickMultiImage();

          selectedImages.addAll(images);
        } else {
          XFile? selectedPicture = await _imagePicker.pickImage(source: source);

          if (selectedPicture != null) {
            selectedImages.add(selectedPicture);
          }
        }

        if (selectedImages.isNotEmpty) {
          List<File> imagesList =
              selectedImages.map((imageData) => File(imageData.path)).toList();

          Navigator.of(ContextHolder.currentContext).push(
            MaterialPageRoute(
              builder: (context) {
                return BlocProvider<MessageImageBloc>(
                  create: (BuildContext context) => MessageImageBloc(
                    channel: channel!,
                    imagesList: imagesList,
                    selectedImages: selectedImages,
                  ),
                  child: const MessageImageScreen(),
                );
              },
            ),
          );
        } else {
          //TODO: An error dialog
        }
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
