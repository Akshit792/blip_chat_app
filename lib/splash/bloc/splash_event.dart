import 'package:flutter/material.dart';

abstract class SplashEvent {}

class CheckAuthStatusSplashEvent extends SplashEvent {
  final BuildContext context;

  CheckAuthStatusSplashEvent({
    required this.context,
  });
}
