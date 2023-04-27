import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/home/bloc/home_screen_event.dart';
import 'package:blip_chat_app/home/bloc/home_screen_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  int selectedIndex = 0;
  final List<Widget> _screens = [
    Container(
      height: double.infinity,
      width: double.infinity,
      child: Text('messages'),
    ),
    Container(
      height: double.infinity,
      width: double.infinity,
      child: Text('calls'),
    ),
  ];

  getSelectedScreen(int index) {
    return _screens[index];
  }

  HomeScreenBloc() : super(InitialHomeState()) {
    on<ChangeScreenBottomNavigationBarEvent>((event, emit) {
      try {
        selectedIndex = event.index;
        emit(UpdatePageState());
      } on Exception catch (e, s) {
        LogPrint.error(
            errorMsg: '$e Change Screen Bottom Navigation Bar Event $s');
      }
    });
  }
}
