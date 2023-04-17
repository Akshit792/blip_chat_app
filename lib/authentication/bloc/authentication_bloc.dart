import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/auth_repository.dart';
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
        await authRepo.loginAction();

        emit(LoadingAuthenticationState());
      } catch (e, s) {
        LogPrint.error(errorMsg: "$e  $s");
      }
    });
  }
}
