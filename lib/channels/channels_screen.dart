import 'package:blip_chat_app/channels/bloc/channels_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_event.dart';
import 'package:blip_chat_app/channels/bloc/channels_state.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/helpers.dart';
import 'package:blip_chat_app/messages/messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black,
      child: Column(
        children: [
          _buildWelcomeUserWidget(context: context),
          _buildChannelsList(context: context),
        ],
      ),
    );
  }

  Widget _buildWelcomeUserWidget({required BuildContext context}) {
    var currentUser = Helpers.getCurrentUser(context: context);

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 45, right: 20, bottom: 140),
      child: Row(
        children: [
          // Intro Text
          Flexible(
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                      text: 'Welcome Back, ',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w300,
                      )),
                  // User Name
                  TextSpan(
                      text: (currentUser != null) ? (currentUser.name) : "",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ))
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          // Rock Emoji Icon
          const Image(
            image: AssetImage(Constants.rockEmojiIconPlaceHolder),
            height: 25,
            fit: BoxFit.contain,
          )
        ],
      ),
    );
  }

  Widget _buildChannelsList({required BuildContext context}) {
    var channelsBloc = BlocProvider.of<ChannelsBloc>(context);

    return BlocBuilder<ChannelsBloc, ChannelsState>(
      builder: (context, state) {
        if ((channelsBloc.isChannelListControllerInitilized == null) ||
            (!channelsBloc.isChannelListControllerInitilized!)) {
          channelsBloc
              .add(InitilizeChannelListControllerEvent(context: context));
        }
        bool isChannelInitilized =
            (channelsBloc.isChannelListControllerInitilized != null &&
                channelsBloc.isChannelListControllerInitilized!);

        return Expanded(
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Colors.grey[100]!,
              ),
              child: Column(
                children: [
                  _buildTopDivider(),
                  // Channel list
                  if (isChannelInitilized)
                    _pageValueListenableBuilder(
                        streamChannelListController:
                            channelsBloc.streamChannelListController!)
                ],
              )),
        );
      },
    );
  }

  Widget _pageValueListenableBuilder(
      {required StreamChannelListController streamChannelListController}) {
    return Expanded(
      child: PagedValueListenableBuilder<int, Channel>(
        valueListenable: streamChannelListController,
        builder: (context, value, child) {
          return value.when((channels, nextPageKey, error) {
            if (channels.isEmpty) {
              return _showMessageWidget(message: 'There are no Chats...');
            }

            return LazyLoadScrollView(
              onEndOfPage: () async {
                // TODO: BLOC
                if (nextPageKey != null) {
                  streamChannelListController.loadMore(nextPageKey);
                }
              },
              child: ListView.builder(
                itemCount: (nextPageKey != null || error != null)
                    ? channels.length + 1
                    : channels.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == channels.length) {
                    if (error != null) {
                      return TextButton(
                        onPressed: () {
                          //TODO: BLOC
                          streamChannelListController.retry();
                        },
                        child: Text(error.message),
                      );
                    }

                    return const CircularProgressIndicator.adaptive(
                      strokeWidth: 2.5,
                    );
                  }

                  final Channel channelData = channels[index];
                  final currentUser = Helpers.getCurrentUser(context: context);

                  List<Member> members = [];
                  Member otherUser = Member();

                  if (channelData.state != null) {
                    members = channelData.state!.members;
                    otherUser = members.firstWhere(
                        (memberData) => memberData.userId != currentUser.id);
                  }

                  return _buildChannelItemListTile(
                    context: context,
                    channelData: channelData,
                    otherUser: otherUser,
                    currentUser: currentUser,
                  );
                },
              ),
            );
          },
              loading: () => _circularLoadingInidicator(),
              error: (e) =>
                  _showMessageWidget(message: 'Oh no, something went wrong.'));
        },
      ),
    );
  }

  Widget _buildChannelItemListTile({
    required BuildContext context,
    required Channel channelData,
    required User currentUser,
    required Member otherUser,
  }) {
    User? otherUserDetails = otherUser.user;

    return Column(
      children: [
        Material(
          child: Ink(
            color: Colors.grey[100],
            child: ListTile(
              onTap: () {
                var arguments = {
                  'channel_data': channelData,
                };

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return const MessagesScreen();
                    },
                    settings: RouteSettings(arguments: arguments)));
              },
              leading: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(otherUserDetails == null
                            ? ""
                            : otherUserDetails.image ?? ""))),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (otherUserDetails == null ? "" : otherUserDetails.name),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildLastMessageAt(channelData: channelData),
                ],
              ),
              subtitle: (channelData.state == null)
                  ? const SizedBox.shrink()
                  : _buildLastMessage(
                      channel: channelData,
                      currentUser: currentUser,
                      otherUser: otherUser,
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  _buildLastMessage({
    required Channel? channel,
    required User currentUser,
    required Member otherUser,
  }) {
    ChannelClientState? channelDataState = channel!.state;

    return StreamBuilder<Object>(
        stream: channelDataState!.unreadCountStream,
        initialData: channelDataState.unreadCount,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: StreamBuilder<Message?>(
              stream: channelDataState.lastMessageStream,
              initialData: channelDataState.lastMessage,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasError) {
                  return const Text(
                    'No messages yet...',
                    style: TextStyle(
                      color: ColorConstants.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  );
                }

                if (snapshot.hasData) {
                  Message lastMessageData = snapshot.data!;

                  bool isThisCurrentUserMessage =
                      (lastMessageData.user!.id == currentUser.id);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessageData.text ?? "",
                          style: TextStyle(
                            color: (channelDataState.unreadCount > 0)
                                ? ColorConstants.black
                                : ColorConstants.grey,
                            fontWeight: (channelDataState.unreadCount > 0)
                                ? FontWeight.w600
                                : null,
                          ),
                        ),
                      ),
                      _buildUnreadCount(channelDataState: channelDataState),
                    ],
                  );
                }

                return const Text(
                  'No messages yet...',
                  style: TextStyle(
                    color: ColorConstants.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                );
              },
            ),
          );
        });
  }

  _buildLastMessageAt({required Channel channelData}) {
    return StreamBuilder<DateTime?>(
        stream: channelData.lastMessageAtStream,
        initialData: channelData.lastMessageAt,
        builder: (context, snapShot) {
          var lastMessageAt = snapShot.data;

          return SizedBox(
            width: 70,
            child: Text(
              (lastMessageAt == null)
                  ? ""
                  : Helpers.getTimeStringFromDateTime(dateTime: snapShot.data!),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: ColorConstants.grey,
                fontSize: 15,
              ),
            ),
          );
        });
  }

  _buildUnreadCount({required ChannelClientState channelDataState}) {
    return StreamBuilder(
        stream: channelDataState.unreadCountStream,
        initialData: channelDataState.unreadCount,
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            var unreadCount = snapShot.data!;

            return Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(left: 10, right: 11),
              decoration: BoxDecoration(
                color: (unreadCount > 0)
                    ? ColorConstants.yellow
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                (unreadCount > 0)
                    ? channelDataState.unreadCount.toString()
                    : '',
                style: const TextStyle(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }

  Widget _buildTopDivider() {
    return Container(
      height: 7,
      width: 110,
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300],
      ),
    );
  }

  Widget _circularLoadingInidicator() {
    return const Expanded(
      child: Center(
          child: SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2.5,
        ),
      )),
    );
  }

  Widget _showMessageWidget({required String message}) {
    return Center(
      child: Text(message),
    );
  }
}


// cache network image 

// message by other user
// not read