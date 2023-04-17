import 'dart:convert';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/auth0_id_token.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  Auth0IdToken? idToken;
  UserProfile? userProfile;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> loginAction() async {
    try {
      AuthorizationTokenRequest authorizationTokenRequest =
          AuthorizationTokenRequest(
              Constants.AUTH0_CLIENT_ID, Constants.Redirect_Url,
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

      AuthorizationTokenResponse? authorizationTokenResponse =
          await _appAuth.authorizeAndExchangeCode(authorizationTokenRequest);
    } catch (e) {
      rethrow;
    }
  }

  _setLocalVariables(
      {required AuthorizationTokenResponse? authorizationTokenResponse}) {
    _secureStorage.write(
        key: Constants.idTokenKey, value: authorizationTokenResponse?.idToken);
    _secureStorage.write(
        key: Constants.accessTokenKey,
        value: authorizationTokenResponse?.accessToken);

    idToken = _parseIdToken(idToken: authorizationTokenResponse?.idToken ?? "");
  }

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
