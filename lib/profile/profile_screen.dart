// ignore_for_file: use_build_context_synchronously

import 'package:blip_chat_app/authentication/authentication_screen.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/auth_repository.dart';
import 'package:blip_chat_app/common/repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
          onPressed: () async {
            try {
              await RepositoryProvider.of<AuthRepository>(context)
                  .authEndSession();
              await RepositoryProvider.of<ChatRepository>(context)
                  .disconnectUserFromClient();

              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return AuthenticationScreen();
              }));

              // dispose the controller
            } on Exception catch (e, s) {
              LogPrint.error(
                errorMsg: 'Log Out',
                error: e,
                stackTrace: s,
              );
            }
          },
          child: const Text('Log out')),
    );
  }
}
