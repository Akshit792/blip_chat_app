import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/repository/chat_repository.dart';
import 'package:blip_chat_app/home/bloc/home_screen_bloc.dart';
import 'package:blip_chat_app/home/bloc/home_screen_event.dart';
import 'package:blip_chat_app/home/bloc/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var homeScreenBloc = BlocProvider.of<HomeScreenBloc>(context);

    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: homeScreenBloc.getSelectedScreen(),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context: context),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar({required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavigationBarItem(
              context: context,
              iconImage: Constants.messageIconPlaceholder,
              label: 'Messages',
              itemIndex: 0),
          _buildBottomNavigationBarItem(
              context: context,
              iconImage: Constants.phoneIconPlaceholder,
              label: 'Calls',
              itemIndex: 1),
          _showMembersButton(context: context),
          _buildBottomNavigationBarItem(
              context: context,
              iconImage: Constants.searchIconPlaceholder,
              label: 'Search',
              itemIndex: 2),
          _buildBottomNavigationBarItem(
              context: context,
              iconImage: Constants.personIconPlaceholder,
              label: 'Profile',
              itemIndex: 3),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBarItem({
    required BuildContext context,
    required String iconImage,
    required String label,
    required int itemIndex,
  }) {
    Color color = BlocProvider.of<HomeScreenBloc>(context)
        .getNavigationBarItemColor(itemIndex: itemIndex);

    return InkWell(
      onTap: () {
        BlocProvider.of<HomeScreenBloc>(context).add(
            ChangeScreenBottomNavigationBarEvent(
                context: context, index: itemIndex));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(AssetImage(iconImage), color: color),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showMembersButton({required BuildContext context}) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      splashColor: Colors.white.withOpacity(0.6),
      onTap: () {
        _showSelectMembersDialog(context: context);
      },
      child: Ink(
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: ColorConstants.yellow,
        ),
        child: Container(
          height: 50,
          width: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            color: ColorConstants.black,
            size: 35,
          ),
        ),
      ),
    );
  }

  void _showSelectMembersDialog({required BuildContext context}) {
    bool isLoading = true;
    showDialog(
        context: context,
        builder: (context) {
          var dialogHeight = MediaQuery.of(context).size.height * 0.4;
          var dialogWidth = MediaQuery.of(context).size.width * 0.7;

          return StatefulBuilder(builder: (context, changeState) {
            StreamUserListController userListController;
            var chatRepo = RepositoryProvider.of<ChatRepository>(context);

            userListController =
                chatRepo.getStreamUserListController(context: context);

            if (isLoading) {
              userListController.doInitialLoad().then((value) {
                changeState(() {
                  isLoading = false;
                  print('hey there');
                });
              });
            }

            return AlertDialog(
              insetPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              content: SizedBox(
                height: dialogHeight,
                width: dialogWidth,
                child: isLoading
                    ? CircularProgressIndicator()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            'Select Member',
                            style: TextStyle(
                              color: ColorConstants.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          )
                        ],
                      ),
              ),
            );
          });
        });
  }
}
