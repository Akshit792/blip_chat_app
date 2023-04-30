import 'package:blip_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_event.dart';
import 'package:blip_chat_app/channels/bloc/channels_state.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/logger.dart';
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
    return BlocBuilder<ChannelsBloc, ChannelsState>(
      builder: (context, state) {
        var channelsBloc = BlocProvider.of<ChannelsBloc>(context);
        StreamChannelListController? streamChannelListController;

        if (state is InitialChannelState) {
          channelsBloc
              .add(InitilizeChannelListControllerEvent(context: context));
        }
        if (state is LoadedChannelState) {
          streamChannelListController =
              channelsBloc.streamChannelListController!;
          print(streamChannelListController.filter);
        }

        return Expanded(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              color: Colors.white,
            ),
            child: (state is LoadedChannelState)
                ? PagedValueListenableBuilder<int, Channel>(
                    valueListenable: streamChannelListController!,
                    builder: (context, value, child) {
                      return value.when(
                        (channels, nextPageKey, error) {
                          if (channels.isEmpty) {
                            return const Center(
                              child: Text('There are no channels.'),
                            );
                          }
                          return LazyLoadScrollView(
                            onEndOfPage: () async {
                              if (nextPageKey != null) {
                                streamChannelListController!
                                    .loadMore(nextPageKey);
                              }
                            },
                            child: ListView.builder(
                              itemCount: (nextPageKey != null || error != null)
                                  ? channels.length + 1
                                  : channels.length,
                              itemBuilder: (BuildContext context, int index) {
                                // when there is error or the list is at the end
                                if (index == channels.length) {
                                  if (error != null) {
                                    return TextButton(
                                      onPressed: () {
                                        streamChannelListController!.retry();
                                      },
                                      child: Text(error.message),
                                    );
                                  }
                                  return CircularProgressIndicator();
                                }

                                final Channel channelData = channels[index];
                                final List<Member> members =
                                    channelData.state!.members;
                                final Member otherUser = members.firstWhere(
                                    (memberData) =>
                                        memberData.userId !=
                                        channelData.createdBy!.id);

                                final isThisCurrentUser = (channelData
                                        .createdBy!.id ==
                                    StreamChatCore.of(context).currentUser!.id);

                                LogPrint.info(infoMsg: otherUser.toString());

                                return ListTile(
                                  onTap: () {},
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                isThisCurrentUser
                                                    ? otherUser.user!.image ??
                                                        ""
                                                    : channelData
                                                            .createdBy!.image ??
                                                        ""))),
                                  ),
                                  title: Text(isThisCurrentUser
                                      ? otherUser.user!.name
                                      : channelData.createdBy!.name),
                                  subtitle: StreamBuilder<Message?>(
                                    stream:
                                        channelData.state!.lastMessageStream,
                                    initialData: channelData.state!.lastMessage,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(snapshot.data!.text!);
                                      }

                                      return const SizedBox();
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const Center(
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e) => Center(
                          child: Text(
                            'Oh no, something went wrong. '
                            'Please check your config. $e',
                          ),
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
