// ignore_for_file: constant_identifier_names

class Constants {
  static const personImagePlaceHolder =
      "assets/images/auth_screen_ui_element.png";
  static const securityCheckPlaceHolder = "assets/images/security_check.png";

  static const AUTH0_DOMAIN = String.fromEnvironment('AUTH0_DOMAIN');
  static const AUTH0_CLIENT_ID = String.fromEnvironment('AUTH0_CLIENT_ID');
  static const AUTH0_ISSUER = "https://$AUTH0_DOMAIN";
  static const Redirect_Url =
      "'hasknosiit://hasknosiit.us.auth0.com/android/com.example.blipchatapp/callback";

  static const idTokenKey = "id_token";
  static const accessTokenKey = "access_token";
}
