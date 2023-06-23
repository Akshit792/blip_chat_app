// ignore_for_file: use_build_context_synchronously

import 'package:blip_chat_app/common/models/auth0_profile.dart';
import 'package:blip_chat_app/common/repository/chat_repository.dart';
import 'package:blip_chat_app/home/home_screen.dart';
import 'package:blip_chat_app/authentication/authentication_screen.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/auth_repository.dart';
import 'package:blip_chat_app/splash/bloc/splash_event.dart';
import 'package:blip_chat_app/splash/bloc/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(InitialSplashState()) {
    on<CheckAuthStatusSplashEvent>((event, emit) async {
      try {
        emit(AuthStatusLoadingSplashState());

        var chatRepo = RepositoryProvider.of<ChatRepository>(event.context);
        var authRepo = RepositoryProvider.of<AuthRepository>(event.context);

        var tokenReValidationStatus = await authRepo.revalidateUser();

        if (tokenReValidationStatus == AuthResultType.success) {
          Auth0Profile user = authRepo.auth0Profile!;
          await chatRepo.connectUserToClient(user: user);
        }

        Navigator.of(event.context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return (tokenReValidationStatus == AuthResultType.success)
                  ? const HomeScreen()
                  : const AuthenticationScreen();
            },
          ),
        );

        emit(AuthStatusLoadedSplashState());
      } catch (e, s) {
        LogPrint.error(
          errorMsg: ("Check Token Splash State"),
          error: e,
          stackTrace: s,
        );
      }
    });
  }
}
