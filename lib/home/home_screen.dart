import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/home/bloc/home_screen_bloc.dart';
import 'package:blip_chat_app/home/bloc/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: const <Widget>[Text('body')],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavigationBarItem(
              iconImage: Constants.messageIconPlaceholder, label: 'Messages'),
          _buildBottomNavigationBarItem(
              iconImage: Constants.phoneIconPlaceholder, label: 'Calls'),
          _buildBottomNavigationBarItem(
              iconImage: Constants.searchIconPlaceholder, label: 'Search'),
          _buildBottomNavigationBarItem(
              iconImage: Constants.personIconPlaceholder, label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBarItem(
      {required String iconImage, required String label}) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(
            AssetImage(iconImage),
            color: ColorConstants.grey,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: ColorConstants.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
