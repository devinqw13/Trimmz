import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

showImageDialog(BuildContext context, String imageUrl) async {
  showDialog(
    context: context,
    builder: (_) {
      return new Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          buildPhoto(context, imageUrl)
        ]
      );
    }
  );
}

buildPhoto(BuildContext context, String imageUrl) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.width,
      child: PhotoView(
        backgroundDecoration: BoxDecoration(
          color: Colors.transparent
        ),
        minScale: PhotoViewComputedScale.contained * 1,
        imageProvider: NetworkImage(imageUrl),
      )
    )
  );
}

