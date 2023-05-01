import 'package:blip_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_event.dart';
import 'package:blip_chat_app/channels/bloc/channels_state.dart';
import 'package:blip_chat_app/common/constants.dart';
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
          _buildChannelsList()
        ],
      ),
    );
  }

  Widget _buildWelcomeUserWidget({required BuildContext context}) {
    var currentUser = BlocProvider.of<AuthenticationBloc>(context)
        .getCurrentUser(context: context);

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 45, bottom: 140),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                const TextSpan(
                    text: 'Welcome Back, ',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w300,
                    )),
                TextSpan(
                    text: currentUser != null ? currentUser.nickName : "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ))
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Image(
            image: AssetImage(Constants.rockEmojiIconPlaceHolder),
            height: 25,
            fit: BoxFit.contain,
          )
        ],
      ),
    );
  }

  Widget _buildChannelsList() {
    bool isChannelListControllerInitilized = false;

    return BlocBuilder<ChannelsBloc, ChannelsState>(
      builder: (context, state) {
        var channelsBloc = BlocProvider.of<ChannelsBloc>(context);

        if (state is InitialChannelState ||
            (!isChannelListControllerInitilized)) {
          channelsBloc
              .add(InitilizeChannelListControllerEvent(context: context));
          isChannelListControllerInitilized = true;
        }
        if (state is LoadedChannelState) {}

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
                  Container(
                    height: 7,
                    width: 110,
                    margin: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[300],
                    ),
                  ),
                  if (state is LoadedChannelState)
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
      {required StreamChannelListController? streamChannelListController}) {
    return Expanded(
      child: PagedValueListenableBuilder<int, Channel>(
        valueListenable: streamChannelListController!,
        builder: (context, value, child) {
          return value.when((channels, nextPageKey, error) {
            if (channels.isEmpty) {
              return _showMessageWidget(message: 'There are no channels.');
            }

            return LazyLoadScrollView(
              onEndOfPage: () async {
                if (nextPageKey != null) {
                  // todo.
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
                          // TODO: SAPRATE THE LOGIC
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
                  final List<Member> members = channelData.state!.members;
                  final Member otherUser = members.firstWhere((memberData) =>
                      memberData.userId != channelData.createdBy!.id);

                  final isThisCurrentUser = (channelData.createdBy!.id ==
                      StreamChatCore.of(context).currentUser!.id);

                  return _buildChannelItemListTile(
                    context: context,
                    isThisCurrentUser: isThisCurrentUser,
                    channelData: channelData,
                    otherUser: otherUser,
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
    required bool isThisCurrentUser,
    required Channel channelData,
    required Member otherUser,
  }) {
    return Column(
      children: [
        Material(
          child: Ink(
            color: Colors.grey[100],
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return const MessagesScreen();
                    },
                    settings: RouteSettings(arguments: {
                      'channel_data': channelData,
                    })));
              },
              leading: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(isThisCurrentUser
                            ? otherUser.user!.image ?? ""
                            : channelData.createdBy!.image ?? ""))),
              ),
              title: Text(
                isThisCurrentUser
                    ? otherUser.user!.name
                    : channelData.createdBy!.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: StreamBuilder<Message?>(
                  stream: channelData.state!.lastMessageStream,
                  initialData: channelData.state!.lastMessage,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data!.text!);
                    }

                    return const Text(
                      'No messages yet...',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    );
                  },
                ),
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
