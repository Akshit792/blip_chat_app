import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_bloc.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_event.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewImageScreen extends StatelessWidget {
  const ViewImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewImageBloc, ViewImageState>(
      builder: (context, state) {
        var viewImageBloc = BlocProvider.of<ViewImageBloc>(context);
        List<String> imagesUrl = viewImageBloc.imagesUrl;
        if (viewImageBloc.currentImagePath.trim() == "") {
          BlocProvider.of<ViewImageBloc>(context).currentImagePath =
              imagesUrl.first;
        }
        return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.close,
                  color: ColorConstants.black,
                ),
              ),
              actions: [
                if (BlocProvider.of<ViewImageBloc>(context)
                        .currentImagePath
                        .trim() !=
                    "")
                  IconButton(
                    onPressed: () {
                      viewImageBloc.add(
                        SaveImageToGalleryViewImageEvent(
                          context: context,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.download,
                      color: Colors.black,
                    ),
                  )
              ],
              backgroundColor: ColorConstants.yellow,
            ),
            body:
                _buildPhotoViewGallery(context: context, imagesUrl: imagesUrl));
      },
    );
  }

  _buildPhotoViewGallery({
    required BuildContext context,
    required List<String> imagesUrl,
  }) {
    return PhotoViewGallery.builder(
      itemCount: imagesUrl.length,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(
            imagesUrl[index],
          ),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      onPageChanged: (indx) {
        BlocProvider.of<ViewImageBloc>(context).currentImagePath =
            imagesUrl[indx];
      },
      scrollPhysics: const BouncingScrollPhysics(),
      backgroundDecoration: const BoxDecoration(
        color: ColorConstants.black,
      ),
      loadingBuilder: (context, event) => const Center(
        child: SizedBox(
          width: 30.0,
          height: 30.0,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 2.5,
            backgroundColor: Colors.yellow,
          ),
        ),
      ),
    );
  }
}
