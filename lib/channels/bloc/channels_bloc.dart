import 'package:blip_chat_app/channels/bloc/channels_event.dart';
import 'package:blip_chat_app/channels/bloc/channels_state.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/chat_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ChannelsBloc extends Bloc<ChannelsEvent, ChannelsState> {
  StreamChannelListController? streamChannelListController;
  bool? isChannelListControllerInitilized;

  ChannelsBloc() : super(InitialChannelState()) {
    on<InitilizeChannelListControllerEvent>(
      (event, emit) async {
        try {
          var chatRepo = RepositoryProvider.of<ChatRepository>(event.context);

          streamChannelListController =
              chatRepo.getStreamChannelListController(event.context);

          await streamChannelListController!.doInitialLoad();

          isChannelListControllerInitilized = true;

          emit(LoadedChannelState());
        } on Exception catch (e, s) {
          LogPrint.error(
            errorMsg: ('Initilise Channel List Controller'),
            error: e,
            stackTrace: s,
          );

          emit(ErrorChannelState());
        }
      },
    );
  }

  disposeChannelListController({required BuildContext context}) {
    if (streamChannelListController != null) {
      streamChannelListController!.dispose();
      isChannelListControllerInitilized = false;
    }
  }
}
