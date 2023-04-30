import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/auth0_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ChatRepository {
  final client = StreamChatClient(
    Constants.STREAM_API_KEY,
    logLevel: (kDebugMode) ? Level.INFO : Level.OFF,
  );

  Future<OwnUser> connectUserToClient({required Auth0Profile user}) async {
    var devToken = client.devToken(user.userId).rawValue;

    OwnUser connectedUser = await client.connectUser(
        User(id: user.userId, extraData: {
          'name': user.nickName,
          'email': user.email,
          'image': user.picture,
        }),
        devToken);

    return connectedUser;
  }

  StreamChannelListController getStreamChannelListController(
      BuildContext context) {
    Filter filters = Filter.and(
      [
        Filter.equal('type', 'messages'),
        Filter.in_(
          'members',
          [StreamChatCore.of(context).currentUser!.id],
        )
      ],
    );

    List<SortOption<ChannelState>>? channelSort = const [
      SortOption('last_message_at')
    ];

    var streamChannelListController = StreamChannelListController(
      client: client,
      filter: filters,
      channelStateSort: channelSort,
      limit: 20,
    );
    return streamChannelListController;
  }

  StreamUserListController getStreamUserListController(
      {required BuildContext context}) {
    var client = StreamChatCore.of(context).client;
    Filter filter =
        Filter.notEqual('id', StreamChatCore.of(context).currentUser!.id);

    late final userListController = StreamUserListController(
      filter: filter,
      client: client,
      limit: 10,
    );

    return userListController;
  }

  Future<void> disconnectUserFromClient() async {
    await client.disconnectUser(flushChatPersistence: true);
  }
}
