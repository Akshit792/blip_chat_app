import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Helpers {
  static getToken({required tokenType}) async {
    var secureStorage = const FlutterSecureStorage();
    String? refreshToken = await secureStorage.read(key: tokenType);

    return refreshToken;
  }
}
