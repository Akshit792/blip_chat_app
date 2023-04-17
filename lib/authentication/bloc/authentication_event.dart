import 'package:flutter/widgets.dart';

abstract class AuthenticationEvent {}

class AuthenticationLoginEvent extends AuthenticationEvent {
  final BuildContext context;

  AuthenticationLoginEvent({required this.context});
}
