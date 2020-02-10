import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../globals.dart' as globals;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../View/CustomCameraButton.dart';

class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  CameraApp({Key key, this.cameras}) : super (key: key);
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  int _currentIndex = 0;
  int selectedCameraId = 0;
  double controllerAspect = 0.0;

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

  void onNavTapTapped(int index) {
   setState(() {
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
    //_initCameraController(selectedCamera);
  }

  Widget buildGallery() {
    return Container(child:Text('Gallery'));
  }

  buildBody(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    // if (!controller.value.isInitialized) {
    //   return Container(child: Text('TESTING'));
    // }
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
            Container()
          ]
        ),
        body: _currentIndex == 0 ? Column(
          children: <Widget> [
            controller.value.isInitialized ? Container(
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
                      Container(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: _onSwitchCamera,
                          icon: Icon(Icons.rotate_right, size: MediaQuery.of(context).size.height * .04)
                        )
                      ),
                      CustomCameraButton(
                        strokeWidth: 5,
                        radius: 50,
                        gradient: LinearGradient(colors: [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent]),
                        child: Container(),
                        onPressed: () {

                        },
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () {

                          },
                          icon: Icon(Icons.flash_off, color: Colors.grey, size: MediaQuery.of(context).size.height * .04)
                        )
                      ),
                    ]
                  )
                )
              )
            )
          ]
        ) : Container(child:Text('Gallery')),
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