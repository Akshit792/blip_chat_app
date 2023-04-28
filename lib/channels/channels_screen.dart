import 'package:blip_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_state.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelsBloc, ChannelsState>(
      builder: (context, state) {
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
      },
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
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          color: Colors.white,
        ),
      ),
    );
  }
}
