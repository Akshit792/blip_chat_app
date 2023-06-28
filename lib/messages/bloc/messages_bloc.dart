// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:blip_chat_app/common/helpers.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/messages/bloc/messages_event.dart';
import 'package:blip_chat_app/messages/bloc/messages_state.dart';
import 'package:blip_chat_app/messages/message_image/bloc/message_event_state.dart';
import 'package:blip_chat_app/messages/message_image/message_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  StreamSubscription<int>? unreadCountSubscription;
  Channel channel;
  Member otherUser;
  List<XFile> selectedImages = [];
  List<Message> selectedMessages = [];
  final ImagePicker _imagePicker = ImagePicker();

  MessagesBloc({
    required this.channel,
    required this.otherUser,
  }) : super(InitialMessagesState()) {
    on<SetUnReadMessagesAsReadEvent>(
      (event, emit) async {
        try {
          unreadCountSubscription =
              channel.state!.unreadCountStream.listen(_unreadCountHandler);
        } on Exception catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: ('Set Unread Messages As Read'),
            stackTrace: s,
          );
        }
      },
    );
    on<SendMessageEvent>(
      (event, emit) async {
        try {
          await channel.sendMessage(event.message);
        } on Exception catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: ('Send Message Event'),
            stackTrace: s,
          );
          CustomFlutterToast.error(
            message: ('Message Not Send'),
          );
        }
      },
    );
    on<PickImageMessageEvent>(
      (event, emit) async {
        try {
          ImageSource source = (event.isSourceGallery)
              ? ImageSource.gallery
              : ImageSource.camera;

          if (event.isSourceGallery) {
            final List<XFile> images = await _imagePicker.pickMultiImage();

            selectedImages.addAll(images);
          } else {
            XFile? selectedPicture =
                await _imagePicker.pickImage(source: source);

            if (selectedPicture != null) {
              selectedImages.add(selectedPicture);
            }
          }

          if (selectedImages.isNotEmpty) {
            List<File> imagesList = selectedImages
                .map((imageData) => File(imageData.path))
                .toList();

            Navigator.of(event.context).push(
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    create: (BuildContext context) => MessageImageBloc(
                      channel: channel,
                      imagesList: imagesList,
                      selectedImages: selectedImages,
                    ),
                    child: const MessageImageScreen(),
                  );
                },
              ),
            );

            clearSelectedImages();
          }
        } on Exception catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: ('Take Image Message Event'),
            stackTrace: s,
          );
          CustomFlutterToast.error(
            message: ('Unable To Pick Image'),
          );
        }
      },
    );
    on<DeleteMessageEvent>(
      (event, emit) async {
        try {
          for (var message in selectedMessages) {
            channel.deleteMessage(message, hard: false);
          }
          selectedMessages.clear();
          emit(LoadedMessagesState());
        } on Exception catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: 'Delete Message Event',
            stackTrace: s,
          );
          CustomFlutterToast.error(
            message: 'Unable to delete messages',
          );
        }
      },
    );
    on<SelectOrUnselectMessageEvent>(
      (event, emit) {
        try {
          if (event.isClear == null || !event.isClear!) {
            bool isMessageAlreadyExist = selectedMessages
                .any((message) => message.id == event.message.id);

            if (isMessageAlreadyExist) {
              if (!event.isSelect) {
                selectedMessages
                    .removeWhere((message) => message.id == event.message.id);
              }
            } else {
              if (event.message.user!.id != otherUser.userId) {
                if (event.isSelect) selectedMessages.add(event.message);
              }
            }
          } else {
            selectedMessages.clear();
          }

          emit(LoadedMessagesState());
        } on Exception catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: 'Select Unselect Message Event',
            stackTrace: s,
          );
        }
      },
    );
    on<LaunchMessagelinkEvent>(
      (event, emit) async {
        try {
          Uri linkUrl = Uri.parse(event.link);

          await canLaunchUrl(linkUrl)
              ? await launchUrl(linkUrl)
              : CustomFlutterToast.error(
                  message: 'could_not_launch_this_app',
                );
        } catch (e, s) {
          CustomFlutterToast.error(message: 'Unable to open link');
          LogPrint.error(
            error: e,
            errorMsg: 'Launch Message Link Event',
            stackTrace: s,
          );
        }
      },
    );
  }

  Future<void> _unreadCountHandler(int count) async {
    if (count > 0) {
      await channel.markRead();
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
