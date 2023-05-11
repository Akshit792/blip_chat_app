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

  static getChannelOtherUser(
      {required List<Member>? channelMembersList,
      required BuildContext context}) {
    Member? otherUser;
    User? currentUser = getCurrentUser(context: context);

    if (channelMembersList!.isNotEmpty && channelMembersList.length == 2) {
      for (var memberData in channelMembersList) {
        if (memberData.userId != currentUser!.id) {
          otherUser = memberData;
          return otherUser;
        }
      }
    }
  }

  static isStringValid({required String? text}) {
    if (text != null && text != "") {
      return true;
    }
    return false;
  }
}
