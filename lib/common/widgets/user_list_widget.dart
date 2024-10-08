// ignore_for_file: use_build_context_synchronously

import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/chat_repository.dart';
import 'package:blip_chat_app/home/bloc/home_screen_bloc.dart';
import 'package:blip_chat_app/home/bloc/home_screen_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class UsersListWidget extends StatefulWidget {
  const UsersListWidget({super.key});

  @override
  State<UsersListWidget> createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  bool isLoading = true;
  bool isError = false;
  late StreamUserListController _userListController;

  @override
  void didChangeDependencies() async {
    await _initializeStreamUserListController();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _userListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading && !isError)
        ? _circularLoadingInidicator()
        : (isError)
            ? _showMessageWidget(
                message: ('Oh no, something went wrong.'),
              )
            : Expanded(
                child: PagedValueListenableBuilder<int, User>(
                  valueListenable: _userListController,
                  builder: (context, value, child) {
                    return value.when(
                      (users, nextPageKey, error) {
                        if (users.isEmpty) {
                          return _showMessageWidget(
                            message: ('There are no users'),
                          );
                        }
                        return LazyLoadScrollView(
                          onEndOfPage: () async {
                            _loadMoreUsers(
                              nextPageKey: nextPageKey,
                            );
                          },
                          child: ListView.builder(
                            itemCount: (nextPageKey != null || error != null)
                                ? users.length + 1
                                : users.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == users.length) {
                                if (error != null) {
                                  return TextButton(
                                    onPressed: () {
                                      _userListController.retry();
                                    },
                                    child: Text(error.message),
                                  );
                                }
                                return const CircularProgressIndicator.adaptive(
                                  strokeWidth: 2.5,
                                );
                              }

                              final userData = users[index];

                              return _buildUserDetailsTile(
                                userData: userData,
                              );
                            },
                          ),
                        );
                      },
                      loading: () => _circularLoadingInidicator(),
                      error: (e) => _showMessageWidget(
                        message: ('Oh no, something went wrong.'),
                      ),
                    );
                  },
                ),
              );
  }

  Widget _buildUserDetailsTile({required User userData}) {
    return Column(
      children: [
        ListTile(
          onTap: () async {
            _createChannel(userId: userData.id);
            Navigator.of(context).pop();
          },
          leading: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(userData.image ?? ""),
              ),
            ),
          ),
          title: Text(
            userData.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _circularLoadingInidicator() {
    return const Expanded(
      child: Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }

  Widget _showMessageWidget({required String message}) {
    return Center(
      child: Text(message),
    );
  }

  Future<void> _initializeStreamUserListController() async {
    try {
      var chatRepo = RepositoryProvider.of<ChatRepository>(context);

      if (isLoading) {
        _userListController =
            chatRepo.getStreamUserListController(context: context);

        await _userListController.doInitialLoad();

        isLoading = false;
      }
    } on Exception catch (e, s) {
      isError = true;
      LogPrint.error(
        error: e,
        errorMsg: ('Initliaze Stream User List Controller'),
        stackTrace: s,
      );
    }
    setState(() {});
  }

  Future<void> _loadMoreUsers({required int? nextPageKey}) async {
    if (nextPageKey != null) {
      _userListController.loadMore(nextPageKey);
    }
  }

  Future<void> _createChannel({required String userId}) async {
    try {
      var chatRepo = RepositoryProvider.of<ChatRepository>(context);

      await chatRepo.createOneOnOneChatChannel(
          userId: userId, context: context);

      BlocProvider.of<HomeScreenBloc>(context).add(
        ChangeScreenBottomNavigationBarEvent(
          context: context,
          index: 0,
        ),
      );
    } on Exception catch (e, s) {
      LogPrint.error(
        error: e,
        errorMsg: ('Create Channel User List Page'),
        stackTrace: s,
      );
    }
  }
}
