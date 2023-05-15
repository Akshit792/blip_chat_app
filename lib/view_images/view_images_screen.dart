import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_bloc.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewImageScreen extends StatelessWidget {
  ViewImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewImageBloc, ViewImageState>(
      builder: (context, state) {
        List<String> imagesUrl =
            BlocProvider.of<ViewImageBloc>(context).imagesUrl;
        if (BlocProvider.of<ViewImageBloc>(context).currentImagePath.trim() ==
            "") {
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
                      _saveImageToGallery(
                          imagePath: BlocProvider.of<ViewImageBloc>(context)
                              .currentImagePath);
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
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  // _buildImageWigdet({required BuildContext context, required String imageUrl}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 15.0),
  //     child: Stack(
  //       children: [
  //         Container(
  //           width: double.infinity,
  //           alignment: Alignment.center,
  //           decoration: BoxDecoration(
  //               border: Border.all(color: ColorConstants.grey, width: 2)),
  //           child: Image(
  //             image: NetworkImage(imageUrl),
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         Positioned.fill(
  //           child: Material(
  //             color: Colors.transparent,
  //             child: InkWell(
  //               onTap: () {},
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _saveImageToGallery({required String imagePath}) async {
    bool? isImageSaved =
        await GallerySaver.saveImage(imagePath, albumName: Constants.albumName);
    if (isImageSaved != null && isImageSaved) {
      // show Fluttertoast : "Image is saved"
      print('Image is Saved');
    }
  }
}
