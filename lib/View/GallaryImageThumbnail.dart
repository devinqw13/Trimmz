import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../lru_map.dart';

class ImageItemWidget extends StatefulWidget {
  final AssetEntity entity;

  const ImageItemWidget({
    Key key,
    this.entity,
  }) : super(key: key);
  @override
  _ImageItemWidgetState createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  @override
  Widget build(BuildContext context) {
    final item = widget.entity;
    final size = 130;
    final u8List = ImageLruCache.getData(item, size);

    Widget image;

    if (u8List != null) {
      return Image.memory(
        u8List,
        width: size.toDouble(),
        height: size.toDouble(),
        fit: BoxFit.cover,
      );
    } else {
      image = FutureBuilder<Uint8List>(
        future: item.thumbDataWithSize(size, size),
        builder: (context, snapshot) {
          Widget w;
          if (snapshot.hasError) {
            w = Center(
              child: Text("load error, error: ${snapshot.error}"),
            );
          }
          if (snapshot.hasData) {
            ImageLruCache.setData(item, size, snapshot.data);
            w = FittedBox(
              fit: BoxFit.cover,
              child: Image.memory(
                snapshot.data,
              ),
            );
          } else {
            w = Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              )
            );
          }
          return w;
        },
      );
    }

    return image;
  }

  @override
  void didUpdateWidget(ImageItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entity.id != oldWidget.entity.id) {
      setState(() {});
    }
  }
}
