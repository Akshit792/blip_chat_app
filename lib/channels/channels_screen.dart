import 'package:blip_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_event.dart';
import 'package:blip_chat_app/channels/bloc/channels_state.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
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
                        (channels, nextPageKey, error) => LazyLoadScrollView(
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

                              final _item = channels[index];
                              return ListTile(
                                title: Text(_item.name ?? ''),
                                subtitle: StreamBuilder<Message?>(
                                  stream: _item.state!.lastMessageStream,
                                  initialData: _item.state!.lastMessage,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(snapshot.data!.text!);
                                    }

                                    return const SizedBox();
                                  },
                                ),
                                onTap: () {},
                              );
                            },
                          ),
                        ),
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
