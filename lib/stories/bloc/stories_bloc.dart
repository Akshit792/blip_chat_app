import 'package:blip_chat_app/stories/bloc/stories_event.dart';
import 'package:blip_chat_app/stories/bloc/stories_state.dart';
import 'package:bloc/bloc.dart';

class StoriesBloc extends Bloc<StoriesEvent, StoriesState> {
  StoriesBloc() : super(InitialStoriesState()) {
    on((event, emit) {});
  }
}
