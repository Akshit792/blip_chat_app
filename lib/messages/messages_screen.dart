import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Channel channel;

  @override
  void didChangeDependencies() {
    var routeData = ModalRoute.of(context)!.settings.arguments;

    if (routeData != null && routeData is Map) {
      if (routeData.containsKey('channel_data')) {
        channel = routeData['channel_data'];
      }
    }

    super.didChangeDependencies();
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
        ],
      ),
    );
  }

  Widget _buildMessageList({required List<Message> messagesList}) {
    return ListView.builder(
        itemCount: messagesList.length,
        itemBuilder: (context, index) {
          return Text(messagesList[index].text ?? "");
        });
  }
}
