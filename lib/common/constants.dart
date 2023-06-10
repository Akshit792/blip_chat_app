// ignore_for_file: constant_identifier_names

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];

enum AuthResultType { success, error }

class Constants {
  static const personImagePlaceHolder =
      "assets/images/auth_screen_ui_element.png";
  static const securityCheckPlaceHolder = "assets/images/security_check.png";
  static const messageIconPlaceholder = "assets/images/message_icon.png";
  static const personIconPlaceholder = "assets/images/person_icon.png";
  static const phoneIconPlaceholder = "assets/images/phone_icon.png";
  static const searchIconPlaceholder = "assets/images/search_icon.png";
  static const rockEmojiIconPlaceHolder = "assets/images/rock_emoji_icon.png";
  static const micIconPlaceholder = "assets/images/mic_icon.png";

  static const STREAM_API_KEY = String.fromEnvironment('STREAM_API_KEY');
  static const AUTH0_DOMAIN = String.fromEnvironment('AUTH0_DOMAIN');
  static const AUTH0_CLIENT_ID = String.fromEnvironment('AUTH0_CLIENT_ID');
  static const AUTH0_ISSUER = "https://$AUTH0_DOMAIN";
  static const Auth0_BUNDLE_ID = "com.example.blipchatapp";
  static const Auth0_REDIRECT_URL = "$Auth0_BUNDLE_ID://login-callback";
  static const Auth0_LOGOUT_URL = "$Auth0_BUNDLE_ID://logout-callback";

  static const idTokenKey = "id_token";
  static const accessTokenKey = "access_token";
  static const refreshTokenKey = "refresh_token";

  static const String albumName = 'Media';
}

class ColorConstants {
  static const grey = Color(0xFF8A91A8);
  static const black = Color(0xFF000000);
  static const yellow = Color(0xFFFFCB45);
  static const lightYellow = Color.fromRGBO(255, 199, 0, 0.25);
  static const lightOrange = Color.fromRGBO(255, 137, 51, 0.25);
}
