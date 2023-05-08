import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class AvatarImageWidget extends StatelessWidget {
  final User? userDetails;
  const AvatarImageWidget({required this.userDetails, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: NetworkImage(
                    userDetails == null ? "" : userDetails!.image ?? ""))));
  }
}
