import 'package:flutter/material.dart';

class HomeScreenEvent {}

class ChangeScreenBottomNavigationBarEvent extends HomeScreenEvent {
  final BuildContext context;
  final int index;

  ChangeScreenBottomNavigationBarEvent({
    required this.context,
    required this.index,
  });
}
