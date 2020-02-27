import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:trimmz/Calls/GeneralCalls.dart';
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
import 'package:simple_image_crop/simple_image_crop.dart';
import '../Model/Packages.dart';
import '../Model/availability.dart';
import '../Model/AppointmentRequests.dart';
import '../Model/BarberPolicies.dart';

class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List selectedEvents;
  final List<Packages> packages;
  final Map<DateTime, List> events;
  final List<Availability> availability;
  final List<AppointmentRequest> appointmentReq;
  final BarberPolicies policies;
  final int uploadType;
  CameraApp({Key key, @required this.uploadType, this.cameras, this.appointmentReq, this.availability, this.events, this.packages, this.policies, this.selectedEvents}) : super (key: key);
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  final imgCropKey = GlobalKey<ImgCropState>();
  List<AssetPathEntity> galleryList = [];
  AssetPathEntity defaultGallery;
  List<AssetEntity> defaultGalleryImageList = [];
  AssetEntity gallerySelectedImage;
  CameraController controller;
  int _currentIndex = 0;
  int selectedCameraId = 0;
  double controllerAspect = 0.0;
  String takenPhoto = '';
  String selectedAsset = '';

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
        selectedAsset = list[0].name;
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
      future: gallerySelectedImage.thumbDataWithSize(600, 600, format: format),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return ImgCrop(
            key: imgCropKey,
            maximumScale: 1.0,
            chipRadius: 200,
            chipShape: 'rect',
            image: MemoryImage(snapshot.data)
          );
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

  createCropImage(BuildContext context) async {
    //progressHUD();
    final format = ThumbFormat.jpeg;
    var req = await gallerySelectedImage.thumbDataWithSize(600, 600, format: format);
    var tempDir = await getTemporaryDirectory();
    var tempPath = tempDir.path;
    var imageId = gallerySelectedImage.id;
    var nameList = imageId.split('-');
    var name = nameList[0];

    File file = new File('$tempPath/$name.png');
    await file.writeAsBytes(req);

    final crop = imgCropKey.currentState;
    final croppedFile = await crop.cropCompleted(file, pictureQuality: 900);
    //progressHUD();

    if(widget.uploadType == 2) {
      final shareImageScreen = new ShareImage(image: croppedFile.path, selectedEvents: widget.selectedEvents, packages: widget.packages, events: widget.events, availability: widget.availability, appointmentReq: widget.appointmentReq, policies: widget.policies);
      Navigator.push(context, new MaterialPageRoute(builder: (context) => shareImageScreen));
    }else {
      var res = await uploadImage(context, croppedFile.path, widget.uploadType);
      Navigator.pop(context, res);
    }
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
          title: _currentIndex == 0 ? Text('Photo') :
          galleryList.length > 0 ? 
          Container(
            child: DropdownButton(
              underline: Container(),
              icon: Icon(Icons.keyboard_arrow_down),
              isExpanded: true,
              value: selectedAsset,
              onChanged: (value) async {
                int index = galleryList.indexWhere((d) => d.name == value);
                var imageList = await galleryList[index].assetList;
                setState(() {
                  selectedAsset = value;
                  defaultGalleryImageList = imageList;
                  gallerySelectedImage = defaultGalleryImageList[0];
                });
              },
              items: galleryList.map((AssetPathEntity asset) {
                return DropdownMenuItem<String>(
                  value: asset.name,
                  child: RichText(
                    text: new TextSpan(
                      children: <TextSpan> [
                        new TextSpan(text: asset.name+' ', style: TextStyle(fontWeight: FontWeight.bold)),
                        new TextSpan(text: '(${asset.assetCount})', style: TextStyle(color: Colors.grey)),
                      ]
                    )
                  )
                );
              }).toList()
            )
          ): Text('gallery'),
          actions: <Widget>[
            widget.uploadType == 2 ?
            takenPhoto != '' || (_currentIndex == 1 && gallerySelectedImage != null) ? new FlatButton(
              child: new Text('Next', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: () async {
                if(_currentIndex == 1 && gallerySelectedImage != null) {
                  createCropImage(context);
                }else {
                  final shareImageScreen = new ShareImage(image: takenPhoto, selectedEvents: widget.selectedEvents, packages: widget.packages, events: widget.events, availability: widget.availability, appointmentReq: widget.appointmentReq, policies: widget.policies);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => shareImageScreen));
                }
              }
            ) : Container()
            : 
            new FlatButton(
              child: new Text('Use', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: () async {
                if(_currentIndex == 1 && gallerySelectedImage != null) {
                  createCropImage(context);
                }else {
                  var res = await uploadImage(context, takenPhoto, widget.uploadType);
                  Navigator.pop(context, res);
                }
              },
            )
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