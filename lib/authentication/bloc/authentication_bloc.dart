// ignore_for_file: use_build_context_synchronously

import 'package:blip_chat_app/common/models/auth0_profile.dart';
import 'package:blip_chat_app/common/repository/chat_repository.dart';
import 'package:blip_chat_app/home/bloc/home_screen_bloc.dart';
import 'package:blip_chat_app/home/home_screen.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/helpers.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blip_chat_app/authentication/bloc/authentication_event.dart';
import 'package:blip_chat_app/authentication/bloc/authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(InitialAuthenticationState()) {
    on<AuthenticationLoginEvent>(
      (event, emit) async {
        try {
          emit(LoadingAuthenticationState());

          var chatRepo = RepositoryProvider.of<ChatRepository>(event.context);
          var authRepo = RepositoryProvider.of<AuthRepository>(event.context);
          var homeScreenBloc = BlocProvider.of<HomeScreenBloc>(event.context);

          AuthResultType authResultType = await authRepo.loginAction();

          if (authResultType == AuthResultType.success) {
            var refreshToken = Helpers.getToken(
              tokenType: Constants.refreshTokenKey,
            );

            if (refreshToken != null) {
              Auth0Profile user = authRepo.auth0Profile!;

              await authRepo.addUserToFirebaseFirestore(
                currentUserData: user,
              );

              await chatRepo.connectUserToClient(
                user: user,
              );

              homeScreenBloc.selectedIndex = 0;

              Navigator.of(event.context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return const HomeScreen();
                  },
                ),
              );
            } else {
              CustomFlutterToast.error(message: 'Login Failed');
            }
          }
          emit(LoadedAuthenticationState());
        } on Exception catch (e, s) {
          CustomFlutterToast.error(message: 'Login Failed');
          LogPrint.error(
            errorMsg: "Authentication Login Event",
            error: e,
            stackTrace: s,
          );
        }
      },
    );
  }
}
