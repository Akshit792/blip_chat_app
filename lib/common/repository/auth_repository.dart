import 'dart:convert';

import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/auth0_id_token.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class AuthRepository {
  Auth0IdToken? idToken;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  Future<void> loginAction() async {
    try {
      AuthorizationTokenRequest tokenRequest = AuthorizationTokenRequest(
          Constants.AUTH0_CLIENT_ID, Constants.Auth0_REDIRECT_URL,
          issuer: Constants.AUTH0_ISSUER,
          scopes: [
            'openid',
            'profile',
            'email',
            'offline_access',
          ],
          promptValues: [
            'login'
          ]);

      var response = await _appAuth.authorizeAndExchangeCode(tokenRequest);
    } catch (e) {
      rethrow;
    }
  }

  // _setLocalVariables(
  //     {required AuthorizationTokenResponse? authorizationTokenResponse}) {
  //   _secureStorage.write(
  //       key: Constants.idTokenKey, value: authorizationTokenResponse?.idToken);
  //   _secureStorage.write(
  //       key: Constants.accessTokenKey,
  //       value: authorizationTokenResponse?.accessToken);

  //   idToken = _parseIdToken(idToken: authorizationTokenResponse?.idToken ?? "");
  // }

  Auth0IdToken _parseIdToken({required String idToken}) {
    final parts = idToken.split(r'.');

    Map<String, dynamic> json = jsonDecode(
      utf8.decode(
        base64Url.decode(
          base64Url.normalize(parts[1]),
        ),
      ),
    );
    return Auth0IdToken.fromJson(json);
  }
}

class HttpNetworkException implements Exception {
  String errorMessage;

  HttpNetworkException({required this.errorMessage});
}
