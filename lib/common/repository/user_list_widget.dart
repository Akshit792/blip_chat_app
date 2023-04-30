import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/chat_repository.dart';
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
            ? _showMessageWidget(message: ('Oh no, something went wrong.'))
            : Expanded(
                child: PagedValueListenableBuilder<int, User>(
                  valueListenable: _userListController,
                  builder: (context, value, child) {
                    return value.when(
                      (users, nextPageKey, error) {
                        if (users.isEmpty) {
                          return _showMessageWidget(
                              message: ('There are no users'));
                        }
                        return LazyLoadScrollView(
                          onEndOfPage: () async {
                            if (nextPageKey != null) {
                              _userListController.loadMore(nextPageKey);
                            }
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

                              return _buildUserDetailsTile(userData: userData);
                            },
                          ),
                        );
                      },
                      loading: () => _circularLoadingInidicator(),
                      error: (e) => _showMessageWidget(
                          message: ('Oh no, something went wrong.')),
                    );
                  },
                ),
              );
  }

//TODO: USE CACHE NETWORK IMAGE
  Widget _buildUserDetailsTile({required User userData}) {
    return ListTile(
      onTap: () async {
        Navigator.of(context).pop();
      },
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: NetworkImage(userData.image ?? ""))),
      ),
      title: Text(
        userData.name,
        style: const TextStyle(
          color: ColorConstants.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
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
      )),
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
}
