import 'package:blip_chat_app/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Channel channel;
  final StreamMessageInputController _streamMessageInputController =
      StreamMessageInputController();
  bool isRead = false;

  @override
  void didChangeDependencies() {
    var routeData = ModalRoute.of(context)!.settings.arguments;

    if (routeData != null && routeData is Map) {
      if (routeData.containsKey('channel_data')) {
        channel = routeData['channel_data'];
      }
    }

    if (!isRead) {
      if (channel.state!.unreadCount > 0) {
        channel.markRead();
        isRead = true;
      }
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          StreamChannel(
            channel: channel,
            showLoading: true,
            child: Expanded(
              child: MessageListCore(
                emptyBuilder: (context) {
                  return const Center(
                    child: Text('Nothing here...'),
                  );
                },
                loadingBuilder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                messageListBuilder: (context, messagesList) {
                  return _buildMessageList(messagesList: messagesList);
                },
                errorBuilder: (context, err) {
                  return const Center(
                    child: Text('Oh no, something went wrong.'),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              children: [
                Container(
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
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller:
                        _streamMessageInputController.textFieldController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type Message',
                      hintStyle: const TextStyle(
                        color: ColorConstants.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      // suffixIcon: SizedBox(
                      //   width: 50,
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //           height: 45,
                      //           width: 45,
                      //           decoration: const BoxDecoration(
                      //             shape: BoxShape.circle,
                      //             color: ColorConstants.yellow,
                      //           ),
                      //           child: const Icon(
                      //             Icons.mic,
                      //             color: Colors.black,
                      //             size: 25,
                      //           ))
                      //     ],
                      //   ),
                      // ),
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
                        if (_streamMessageInputController
                                .message.text?.isNotEmpty ==
                            true) {
                          await channel.sendMessage(
                            _streamMessageInputController.message,
                          );

                          _streamMessageInputController.clear();
                          if (mounted) {
                            setState(() {});
                          }
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
    );
  }

//TODO: REVERSE THE LIST
  Widget _buildMessageList({required List<Message> messagesList}) {
    return ListView.builder(
        reverse: true,
        itemCount: messagesList.length,
        itemBuilder: (context, index) {
          var messageData = messagesList[index];
          bool isThisCurrentUser = (messageData.user!.id ==
              StreamChatCore.of(context).currentUser!.id);

          return Row(
            mainAxisAlignment: isThisCurrentUser
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              Container(
                width: 200,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            ],
          );
        });
  }
}
