import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/helpers.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class AvatarImageWidget extends StatelessWidget {
  final User? userDetails;
  const AvatarImageWidget({required this.userDetails, super.key});

  @override
  Widget build(BuildContext context) {
    bool isImageValid = (userDetails == null)
        ? false
        : Helpers.isStringValid(text: userDetails!.image)
            ? true
            : false;

    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isImageValid) ? null : ColorConstants.lightOrange,
        image: (isImageValid)
            ? DecorationImage(
                image: NetworkImage(userDetails!.image!),
              )
            : null,
      ),
    );
  }
}
