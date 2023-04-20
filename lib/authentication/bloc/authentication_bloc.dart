// ignore_for_file: use_build_context_synchronously

import 'package:blip_chat_app/all_chats/all_chats_screen.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blip_chat_app/authentication/bloc/authentication_event.dart';
import 'package:blip_chat_app/authentication/bloc/authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(InitialAuthenticationState()) {
    on<AuthenticationLoginEvent>((event, emit) async {
      try {
        emit(LoadingAuthenticationState());

        var authRepo = RepositoryProvider.of<AuthRepository>(event.context);
        AuthResultType authResultType = await authRepo.loginAction();

        if (authResultType == AuthResultType.success) {
          var refreshToken =
              Constants.getToken(tokenType: Constants.refreshTokenKey);

          if (refreshToken != null) {
            LogPrint.info(infoMsg: "refresh token : $refreshToken");

            Navigator.of(event.context)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return const AllChatsScreen();
            }));
          } else {
            // show an error dialog
          }
        }
        emit(LoadedAuthenticationState());
      } catch (e, s) {
        LogPrint.error(errorMsg: "$e Authentication Login Event $s");
      }
    });
  }
}
