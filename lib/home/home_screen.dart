import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/home/bloc/home_screen_bloc.dart';
import 'package:blip_chat_app/home/bloc/home_screen_event.dart';
import 'package:blip_chat_app/home/bloc/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
}
