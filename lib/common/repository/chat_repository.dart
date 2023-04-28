import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/auth0_profile.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ChatRepository {
  final client = StreamChatClient(
    Constants.STREAM_API_KEY,
    logLevel: (kDebugMode) ? Level.INFO : Level.OFF,
  );

  Future<OwnUser> connectUserToClient({required Auth0Profile user}) async {
    LogPrint.info(infoMsg: user.userId);
    var token = client.devToken(user.userId).rawValue;
    LogPrint.warning(warningMsg: token);

    OwnUser connectedUser = await client.connectUser(
        User(id: user.userId, extraData: {
          'name': user.name,
          'email': user.email,
          'image': user.picture,
        }),
        client.devToken(user.userId).rawValue);

    return connectedUser;
  }
}
