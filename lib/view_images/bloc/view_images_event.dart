import 'package:flutter/material.dart';

abstract class ViewImageEvent {}

class SaveImageToGalleryViewImageEvent extends ViewImageEvent {
  final BuildContext context;

  SaveImageToGalleryViewImageEvent({required this.context});
}
