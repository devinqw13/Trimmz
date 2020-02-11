import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../globals.dart' as globals;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../View/CustomCameraButton.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'dart:io';
import 'ShareImageController.dart';
import 'package:photo_manager/photo_manager.dart';
import '../View/GallaryImageThumbnail.dart';
import 'dart:typed_data';

class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  CameraApp({Key key, this.cameras}) : super (key: key);
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  List<AssetPathEntity> galleryList = [];
  AssetPathEntity defaultGallery;
  List<AssetEntity> defaultGalleryImageList = [];
  AssetEntity gallerySelectedImage;
  CameraController controller;
  int _currentIndex = 0;
  int selectedCameraId = 0;
  double controllerAspect = 0.0;
  String takenPhoto = '';
  String test = '';

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras.first, ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        controllerAspect = controller.value.aspectRatio;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onNavTapTapped(int index) async {
    if(index == 1) {
      var list = await PhotoManager.getAssetPathList();
      var imageList = await list[0].assetList;
      setState(() {
        galleryList = list;
        defaultGallery = list[0];
        defaultGalleryImageList = imageList;
        gallerySelectedImage = defaultGalleryImageList[0];
      });
    }
    setState(() {
      takenPhoto = '';
      _currentIndex = index;
    });
  }

  void _onSwitchCamera() {
    setState(() {
      selectedCameraId = selectedCameraId < widget.cameras.length - 1 ? selectedCameraId + 1 : 0;
      CameraDescription selectedCamera = widget.cameras[selectedCameraId];
      controller = CameraController(selectedCamera, ResolutionPreset.high);
    });
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<String> resizePhoto(String filePath) async {
    ImageProperties properties = await FlutterNativeImage.getImageProperties(filePath);

    int width = properties.width;
    var offset = (properties.height - properties.width) / 2;
    File croppedFile = await FlutterNativeImage.cropImage(filePath, 0, offset.round(), width, width);
    return croppedFile.path;
  }

  Future<String> takePhoto() async {
    var tempDir = await getTemporaryDirectory();
    var tempPath = tempDir.path;
    final path = join(tempPath,'image.png');
    await controller.takePicture(path);
    return path;
  }

  Widget buildGallery() {
    return Container(child:Text('Gallery'));
  }

  buildGallerySelectedImage(BuildContext context) {
    final format = ThumbFormat.jpeg;
    return FutureBuilder<Uint8List>(
      future: gallerySelectedImage.thumbDataWithSize(500, 500, format: format),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data);
        } else {
          return Center(
            child: Container(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue)
              ),
            ),
          );
        }
      },
    );
  }

  buildBody(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    return new Theme(
      data: new ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: globals.userColor,
        brightness: globals.userBrightness,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(
          title: _currentIndex == 0 ? Text('Photo') : Text('Gallery'),
          actions: <Widget>[
            takenPhoto != '' || (_currentIndex == 1 && gallerySelectedImage != null) ? new FlatButton(
              child: new Text('Next', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: (){
                final shareImageScreen = new ShareImage(image: takenPhoto);
                Navigator.push(context, new MaterialPageRoute(builder: (context) => shareImageScreen));
              }
            ) : Container()
          ]
        ),
        body: _currentIndex == 0 ? Column(
          children: <Widget> [
            takenPhoto == '' ? controller.value.isInitialized ? Container(
              width: size,
              height: size,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      width: size,
                      height: size / controller.value.aspectRatio,
                      child: CameraPreview(controller)
                    ),
                  ),
                ),
              ),
            ) : Container(
              height: size,
              width: size
            ) : Container(
              child: Image.file(
                File(takenPhoto)
              )
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(left: 50, right: 50),
                  width: size,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      takenPhoto == '' ? Container(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: _onSwitchCamera,
                          icon: Icon(Icons.rotate_right, size: MediaQuery.of(context).size.height * .04)
                        )
                      ) : Container(),
                      takenPhoto == '' ? CustomCameraButton(
                        strokeWidth: 5,
                        radius: 50,
                        gradient: LinearGradient(colors: [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent]),
                        child: Container(),
                        onPressed: () async {
                          var res = await takePhoto();
                          var res1 = await resizePhoto(res);
                          setState(() {
                            takenPhoto = res1;
                          });
                        },
                      ) : GestureDetector(
                        onTap: () {
                          setState(() {
                            takenPhoto = '';
                          });
                        },
                        child: Text(
                          'Retake',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: MediaQuery.of(context).size.height * .03
                          )
                        )
                      ),
                      takenPhoto == '' ? Container(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () {

                          },
                          icon: Icon(Icons.flash_off, color: Colors.grey, size: MediaQuery.of(context).size.height * .04)
                        )
                      ) : Container(),
                    ]
                  )
                )
              )
            )
          ]
        ) : 
        defaultGalleryImageList != null ?
        Column(
          children: <Widget> [
            Container(
              height: size,
              width: size,
              child: gallerySelectedImage != null ? buildGallerySelectedImage(context) : Container()
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0,
                  childAspectRatio: 0.9
                ),
                itemCount: defaultGalleryImageList.length,
                itemBuilder: (contex, i) {
                  return GestureDetector(
                    onTap: () async {
                      // var req = await defaultGalleryImageList[i].thumbData;
                      // var tempDir = await getTemporaryDirectory();
                      // var tempPath = tempDir.path;

                      // var imageId = defaultGalleryImageList[i].id;
                      // var nameList = imageId.split('-');
                      // var name = nameList[0];

                      // File file = new File('$tempPath/$name.png');

                      // await file.writeAsBytes(req);

                      // var path = await resizePhoto(file.path);

                      setState(() {
                        gallerySelectedImage = defaultGalleryImageList[i];
                      });
                    },
                    child: ImageItemWidget(
                      key: ValueKey(defaultGalleryImageList[i]),
                      entity: defaultGalleryImageList[i],
                    ),
                  );
                },
              ),
            )
          ]
        ) : Container(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: globals.userColor,
          type: BottomNavigationBarType.fixed,
          onTap: onNavTapTapped,
          currentIndex: _currentIndex,
          unselectedItemColor: globals.darkModeEnabled ? Colors.white : Colors.black,
          selectedItemColor: Colors.blue,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              title: Text('Photo'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.photo),
              title: Text('Gallery'),
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildBody(context);
  }
}