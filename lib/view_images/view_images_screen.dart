import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_bloc.dart';
import 'package:blip_chat_app/view_images/bloc/view_images_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewImageScreen extends StatelessWidget {
  const ViewImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: ColorConstants.yellow,
      ),
      body:
          BlocBuilder<ViewImageBloc, ViewImageState>(builder: (context, state) {
        List<String> imagesUrl =
            BlocProvider.of<ViewImageBloc>(context).imagesUrl;
        return ListView.builder(
            itemCount: imagesUrl.length,
            itemBuilder: (context, index) {
              return _buildImageWigdet(
                context: context,
                imageUrl: imagesUrl[index],
              );
            });
      }),
    );
  }

  _buildImageWigdet({required BuildContext context, required String imageUrl}) {
    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: () {},
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(
            color: ColorConstants.grey,
          )),
          margin: const EdgeInsets.only(bottom: 5),
          child: Image(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
