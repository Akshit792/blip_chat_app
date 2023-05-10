// ignore_for_file: use_build_context_synchronously

import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/helpers.dart';
import 'package:blip_chat_app/common/models/context_holder.dart';
import 'package:blip_chat_app/common/widgets/avatar_image_widget.dart';
import 'package:blip_chat_app/messages/bloc/messages_bloc.dart';
import 'package:blip_chat_app/messages/bloc/messages_event.dart';
import 'package:blip_chat_app/messages/bloc/messages_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageInputController = StreamMessageInputController();
  late Channel channel;
  Member? otherUser;
  User? otherUserDetails;
  bool isDataInitilised = false;
  bool isUserOnline = false;

  @override
  void didChangeDependencies() {
    _initiliseData();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    BlocProvider.of<MessagesBloc>(ContextHolder.currentContext)
        .cancelUnreadCountStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc, MessagesState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: ColorConstants.black,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AvatarImageWidget(userDetails: otherUserDetails),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (otherUserDetails != null)
                              ? otherUserDetails!.name
                              : "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (channel.state != null)
                          _buildMemberStatus(channelState: channel.state!),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: StreamChannel(
                    channel: channel,
                    showLoading: true,
                    child: MessageListCore(
                      emptyBuilder: (context) {
                        return const Center(
                          child: Text(
                            'Nothing here...',
                            style: TextStyle(
                              color: ColorConstants.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      messageListBuilder: (context, messagesList) {
                        return _buildMessageList(
                            messagesList: messagesList,
                            otherUser: otherUserDetails);
                      },
                      errorBuilder: (context, err) {
                        return const Center(
                          child: Text(
                            'Oh no, something went wrong.',
                            style: TextStyle(
                              color: ColorConstants.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Container(
                height: 120,
                color: Colors.white,
                alignment: Alignment.center,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _buildAddAttachmentsDialogBox();
                      },
                      child: Container(
                        height: 45,
                        width: 45,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 20),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConstants.yellow,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: ColorConstants.black,
                          size: 30,
                        ),
                      ),
                    ),
                    Flexible(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        controller: _messageInputController.textFieldController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Type Message',
                          hintStyle: const TextStyle(
                            color: ColorConstants.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 20),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: ColorConstants.grey,
                                width: 1.4,
                              )),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: ColorConstants.grey,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Material(
                        type: MaterialType.circle,
                        color: ColorConstants.yellow,
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () async {
                            if (_messageInputController
                                    .message.text?.isNotEmpty ==
                                true) {
                              BlocProvider.of<MessagesBloc>(context)
                                  .add(SendMessageEvent(
                                context: context,
                                message: _messageInputController.message,
                              ));

                              _messageInputController.clear();
                            }
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMessageList({
    required List<Message> messagesList,
    required User? otherUser,
  }) {
    return ListView.builder(
        reverse: true,
        itemCount: messagesList.length,
        itemBuilder: (context, index) {
          var messageData = messagesList[index];

          User? currentUser = Helpers.getCurrentUser(context: context);

          bool isThisCurrentUser = (messageData.user!.id == currentUser!.id);

          return SizedBox(
            width: MediaQuery.of(context).size.height * 0.4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: isThisCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: isThisCurrentUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: isThisCurrentUser
                              ? ColorConstants.lightYellow
                              : ColorConstants.lightOrange,
                        ),
                        child: Text(
                          messageData.text!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Icon(
                        messageData.status == MessageSendingStatus.sent
                            ? Icons.done_all
                            : messageData.status == MessageSendingStatus.sending
                                ? Icons.done
                                : Icons.error,
                        color:
                            (messageData.status == MessageSendingStatus.sent ||
                                    messageData.status ==
                                        MessageSendingStatus.sending)
                                ? ColorConstants.grey
                                : Colors.red,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: isThisCurrentUser ? 0 : 4,
                        right: isThisCurrentUser ? 4 : 0),
                    child: Text(
                      Helpers.getTimeStringFromDateTime(
                          dateTime: messageData.createdAt),
                      style: const TextStyle(
                        color: ColorConstants.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  _buildMemberStatus({required ChannelClientState channelState}) {
    return StreamBuilder(
        stream: channelState.membersStream,
        initialData: channelState.members,
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            List<Member>? membersList = snapShot.data!;

            Member otherMember = Helpers.getChannelOtherUser(
                channelMembersList: membersList, context: context);

            bool isOnline = false;

            if (otherMember.user != null) {
              isOnline = otherMember.user!.online;
              isUserOnline = isOnline;
            }

            if (isOnline) {
              return const Text(
                'online',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              );
            } else {
              return const Text(
                'offline',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              );
            }
          }
          return const SizedBox.shrink();
        });
  }

  _buildAddAttachmentsDialogBox() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSelectAttachmentTypeWidget(
                  icon: Icons.image,
                  labelText: 'Select Image',
                  onTap: () {
                    BlocProvider.of<MessagesBloc>(context)
                        .add(TakeImageMessageEvent(
                      context: context,
                      isSourceGallery: true,
                    ));
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildSelectAttachmentTypeWidget(
                  icon: Icons.camera_alt,
                  labelText: 'Take Image',
                  onTap: () {
                    BlocProvider.of<MessagesBloc>(context)
                        .add(TakeImageMessageEvent(
                      context: context,
                      isSourceGallery: false,
                    ));
                  },
                ),
              ],
            ),
          );
        });
  }

  _buildSelectAttachmentTypeWidget({
    required IconData icon,
    required String labelText,
    required void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ColorConstants.yellow,
            ),
            child: Icon(
              icon,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Text(
            labelText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  void _initiliseData() {
    if (!isDataInitilised) {
      var routeData = ModalRoute.of(context)!.settings.arguments;

      if (routeData != null && routeData is Map) {
        if (routeData.containsKey('channel_data')) {
          channel = routeData['channel_data'];
        }
      }

      BlocProvider.of<MessagesBloc>(context)
          .add(SetUnReadMessagesAsRead(context: context, channel: channel));

      if (channel.state != null) {
        otherUser = Helpers.getChannelOtherUser(
          channelMembersList: channel.state!.members,
          context: context,
        );
        otherUserDetails = otherUser!.user;
      }

      isDataInitilised = true;
    }
  }
}
