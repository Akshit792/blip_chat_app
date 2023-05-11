import 'package:blip_chat_app/view_images/bloc/view_images_event.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_state.dart';
import 'package:bloc/bloc.dart';

class ViewImageBloc extends Bloc<ViewImageEvent, ViewImageState> {
  final List<String> imagesUrl;

  ViewImageBloc({required this.imagesUrl}) : super(InitialViewImageState()) {
    on((event, emit) {});
  }
}
