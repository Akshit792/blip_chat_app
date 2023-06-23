import 'package:flutter/material.dart';

abstract class HomeScreenEvent {}

class ChangeScreenBottomNavigationBarEvent extends HomeScreenEvent {
  final BuildContext context;
  final int index;

  ChangeScreenBottomNavigationBarEvent({
    required this.context,
    required this.index,
  });
}

class InitlizeUserListControllerEvent extends HomeScreenEvent {
  final BuildContext context;

  InitlizeUserListControllerEvent({
    required this.context,
  });
}
