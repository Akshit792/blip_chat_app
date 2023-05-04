import 'package:blip_chat_app/common/repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:timezone/standalone.dart' as tz;

class Helpers {
  static getToken({required tokenType}) async {
    var secureStorage = const FlutterSecureStorage();
    String? refreshToken = await secureStorage.read(key: tokenType);

    return refreshToken;
  }

  static getTimeStringFromDateTime({required DateTime dateTime}) {
    final localTimeZone = tz.getLocation('Asia/Kolkata');

    var formattedDateTime = tz.TZDateTime.from(dateTime, localTimeZone);

    String formattedTime = DateFormat('h:mm a').format(formattedDateTime);

    return formattedTime;
  }

  static getCurrentUser({required BuildContext context}) {
    User? currentUser = RepositoryProvider.of<ChatRepository>(context)
        .getCurrentUser(context: context);
    return currentUser;
  }
}
