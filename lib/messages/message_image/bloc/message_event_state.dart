// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/messages/message_image/bloc/message_image_bloc.dart';
import 'package:blip_chat_app/messages/message_image/bloc/message_image_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class MessageImageBloc extends Bloc<MessageImageEvent, MessageImageState> {
  Channel channel;
  List<XFile> selectedImages;
  List<File> imagesList;
  int selectedDataIndex = 0;

  MessageImageBloc({
    required this.channel,
    required this.selectedImages,
    required this.imagesList,
  }) : super(InitialMessagesImageState()) {
    on<ChangeSelectedImageEvent>((event, emit) {
      selectedDataIndex = event.currentIndex;
      emit(LoadedMessagesImageState());
    });
    on<CropSelectedImageEvent>(
      (event, emit) async {
        try {
          final CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: event.imageFile.path,
            compressFormat: ImageCompressFormat.jpg,
            compressQuality: 100,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: ('Crop'),
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: ('Crop'),
              ),
              WebUiSettings(
                context: event.context,
                presentStyle: CropperPresentStyle.dialog,
                boundary: const CroppieBoundary(
                  width: 520,
                  height: 520,
                ),
                viewPort: const CroppieViewPort(
                  width: 480,
                  height: 480,
                  type: 'circle',
                ),
                enableExif: true,
                enableZoom: true,
                showZoomer: true,
              ),
            ],
          );
          if (croppedFile != null) {
            int indexOfImageFile = imagesList.indexWhere(
                (imageData) => imageData.path == event.imageFile.path);

            if (indexOfImageFile != -1) {
              imagesList[indexOfImageFile] = File(croppedFile.path);
            }

            int indexOfAttachment = selectedImages.indexWhere(
                (attachmentData) =>
                    attachmentData.path == event.imageFile.path);

            if (indexOfAttachment != -1) {
              selectedImages[indexOfAttachment] = XFile(croppedFile.path);
            }

            emit(LoadedCropImageState());
          }
        } on Exception catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: 'Crop Selected Image Event',
            stackTrace: s,
          );
        }
      },
    );
    on<SendMessageImageAttachmentEvent>(
      (event, emit) async {
        try {
          emit(SendingMessageImageState());

          List<Attachment> attachments = [];

          for (var imagesData in imagesList) {
            attachments.add(
              Attachment(
                type: ('image'),
                file: AttachmentFile(
                  size: imagesData.lengthSync(),
                  path: imagesData.path,
                ),
              ),
            );
          }

          Message message =
              Message(text: event.captionText, attachments: attachments);

          await channel.sendMessage(message);

          Navigator.of(event.context).maybePop();

          emit(LoadedMessagesImageState());
        } on Exception catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: 'Send Message Image Attachment Event',
            stackTrace: s,
          );
        }
      },
    );
  }
}
