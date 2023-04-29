import 'package:blip_chat_app/calls/calls_screen.dart';
import 'package:blip_chat_app/channels/channels_screen.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/chat_repository.dart';
import 'package:blip_chat_app/home/bloc/home_screen_event.dart';
import 'package:blip_chat_app/home/bloc/home_screen_state.dart';
import 'package:blip_chat_app/profile/profile_screen.dart';
import 'package:blip_chat_app/search/search_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  int selectedIndex = 0;
  StreamUserListController? userListController;

  final List<Widget> _screens = const <Widget>[
    ChannelsScreen(),
    CallsScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  HomeScreenBloc() : super(InitialHomeState()) {
    on<ChangeScreenBottomNavigationBarEvent>((event, emit) {
      try {
        selectedIndex = event.index;
        emit(UpdatePageState());
      } on Exception catch (e, s) {
        LogPrint.error(
          errorMsg: 'Change Screen Bottom Navigation Bar Event',
          error: e,
          stackTrace: s,
        );
      }
    });
    on<InitlizeUserListControllerEvent>((event, emit) async {
      try {
        var chatRepo = RepositoryProvider.of<ChatRepository>(event.context);

        userListController =
            chatRepo.getStreamUserListController(context: event.context);
        await userListController!.doInitialLoad();
      } on Exception catch (e, s) {
        LogPrint.error(
          error: e,
          errorMsg: 'Initlize User List Controller Event',
          stackTrace: s,
        );
      }
    });
  }

  Widget getSelectedScreen() {
    return _screens[selectedIndex];
  }

  Color getNavigationBarItemColor({required int itemIndex}) {
    bool isItemSelected = (selectedIndex == itemIndex);

    return isItemSelected ? ColorConstants.black : ColorConstants.grey;
  }

  disposeUserListController() {
    if (userListController != null) {
      userListController!.dispose();
    }
  }
}
