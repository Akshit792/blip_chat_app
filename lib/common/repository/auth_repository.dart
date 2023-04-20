import 'dart:convert';

import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/auth0_id_token.dart';
import 'package:blip_chat_app/common/models/auth0_profile.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Auth0IdToken? idToken;
  Auth0Profile? auth0Profile;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<AuthResultType> loginAction() async {
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

      AuthorizationTokenResponse? authorizationTokenResponse =
          await _appAuth.authorizeAndExchangeCode(tokenRequest);

      AuthResultType resultType = await _setLocalVariables(
          authorizationTokenResponse: authorizationTokenResponse);

      return resultType;
    } catch (e, s) {
      LogPrint.error(errorMsg: "$e ${e.runtimeType} Auth0 Login Action $s");
      return AuthResultType.error;
    }
  }

  Future<AuthResultType> revalidateUser() async {
    try {
      var secureRefreshToken =
          await _secureStorage.read(key: Constants.refreshTokenKey);

      if (secureRefreshToken == null) {
        LogPrint.info(infoMsg: "Token Revalidation Failed");
        return AuthResultType.error;
      }

      TokenRequest tokenRequest = TokenRequest(
        Constants.AUTH0_CLIENT_ID,
        Constants.Auth0_REDIRECT_URL,
        issuer: Constants.AUTH0_ISSUER,
        refreshToken: secureRefreshToken,
      );

      TokenResponse? tokenResponse = await _appAuth.token(tokenRequest);

      final result =
          await _setLocalVariables(authorizationTokenResponse: tokenResponse);

      return result;
    } catch (e, s) {
      LogPrint.info(infoMsg: "Token Revalidation Failed");
      LogPrint.error(errorMsg: "$e ${e.runtimeType} Revalidate User $s");
      return AuthResultType.error;
    }
  }

  Future<AuthResultType> _setLocalVariables(
      {required TokenResponse? authorizationTokenResponse}) async {
    if (isAuthResponseValid(authorizationTokenResponse)) {
      _secureStorage.write(
          key: Constants.accessTokenKey,
          value: authorizationTokenResponse!.accessToken);

      _secureStorage.write(
          key: Constants.refreshTokenKey,
          value: authorizationTokenResponse.refreshToken);

      idToken = _parseIdToken(idToken: authorizationTokenResponse.idToken!);

      bool resultType = await _getUserDetails(
          accessToken: authorizationTokenResponse.accessToken!);

      return resultType ? AuthResultType.success : AuthResultType.error;
    }

    return AuthResultType.error;
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

  Future<bool> _getUserDetails({required String accessToken}) async {
    try {
      final url = Uri.https(Constants.AUTH0_DOMAIN, "/userinfo");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $accessToken",
      });

      if (response.statusCode == 200) {
        auth0Profile = Auth0Profile.fromJson(jsonDecode(response.body));
      }

      return true;
    } catch (e, s) {
      LogPrint.error(errorMsg: '$e ${e.runtimeType} Get User Details $s');
      return false;
    }
  }

  bool isAuthResponseValid(TokenResponse? authorizationTokenResponse) {
    return (authorizationTokenResponse != null &&
        authorizationTokenResponse.idToken != null &&
        authorizationTokenResponse.accessToken != null &&
        authorizationTokenResponse.refreshToken != null);
  }
}

class HttpNetworkException implements Exception {
  String errorMessage;

  HttpNetworkException({required this.errorMessage});
}
