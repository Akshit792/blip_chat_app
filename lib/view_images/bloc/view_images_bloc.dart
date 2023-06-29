import 'package:blip_chat_app/common/helpers.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_event.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_state.dart';
import 'package:bloc/bloc.dart';

class ViewImageBloc extends Bloc<ViewImageEvent, ViewImageState> {
  final List<String> imagesUrl;
  String currentImagePath = "";
  bool isImageTypeNetwork;

  ViewImageBloc({
    required this.imagesUrl,
    this.isImageTypeNetwork = true,
  }) : super(InitialViewImageState()) {
    on<SaveImageToGalleryViewImageEvent>(
      (event, emit) async {
        try {
          // var imageId = await ImageDownloader.downloadImage(currentImagePath);

          // if (imageId == null) {
          //   CustomFlutterToast.error(message: 'Image is not saved');
          // } else {
          //   var path = await ImageDownloader.findPath(imageId);

          //   GallerySaver.saveImage(path ?? "");

          //   CustomFlutterToast.success(message: 'Image is saved to gallery');

          //   emit(ImageSavedToGalleryState());
          // }
        } on Exception catch (e, s) {
          LogPrint.error(
            error: e,
            errorMsg: 'Save Image To Gallery View Image Event',
            stackTrace: s,
          );
          CustomFlutterToast.error(message: 'Image is not saved');
        }
      },
    );
  }
}
