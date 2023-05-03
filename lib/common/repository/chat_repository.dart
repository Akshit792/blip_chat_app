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
    var currentUserId = StreamChatCore.of(context).currentUser!.id;

    Filter filters = Filter.and(
      [
        Filter.equal('type', 'messaging'),
        Filter.in_(
          'members',
          [currentUserId],
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
    Filter filter =
        Filter.notEqual('id', StreamChatCore.of(context).currentUser!.id);

    late final userListController = StreamUserListController(
      filter: filter,
      client: client,
      limit: 10,
    );

    return userListController;
  }

  Future<void> createOneOnOneChatChannel(
      {required String userId, required BuildContext context}) async {
    final core = StreamChatCore.of(context);
    final channel = core.client.channel('messaging', extraData: {
      'members': [
        core.currentUser!.id,
        userId,
      ]
    });
    await channel.watch();
  }

  Future<void> disconnectUserFromClient() async {
    await client.disconnectUser(flushChatPersistence: true);
  }

  User? getCurrentUser({required BuildContext context}) {
    User? currentUser = StreamChatCore.of(context).currentUser;
    return currentUser;
  }
}
