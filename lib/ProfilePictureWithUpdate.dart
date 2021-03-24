import 'package:flutter/material.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:camera/camera.dart';
import 'package:trimmz/Controller/CameraApp.dart';

class ProfilePicture extends StatefulWidget {
  ProfilePicture({Key key});

  @override
  _ProfilePicture createState() => _ProfilePicture();
}

class _ProfilePicture extends State<ProfilePicture> {

  updateProfilePicture() async {
    var cameras = await availableCameras();
    final cameraApp = new CameraApp(uploadType: 1, cameras: cameras);
    var res = await Navigator.push(context, new MaterialPageRoute(builder: (context) => cameraApp));
    if(res != null) {
      setState(() {
        globals.user.profilePic = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(globals.user.profilePic != null) {
      return Container(
        height: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(
              "${globals.baseImageUrl}${globals.user.profilePic}",
            ),
            fit: BoxFit.contain,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            updateProfilePicture();
          },
          child: Container(
            alignment: Alignment.center,
            child: Icon(Icons.add, size: 27),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              shape: BoxShape.circle
            ),
          )
        )
      );
    }else {
      return new Container(
        child: CircleAvatar(
          child: Center(child:Text(globals.user.username.substring(0,1).toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 25))),
          radius: 30,
          backgroundColor: Colors.transparent,
        ),
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: globals.darkModeEnabled ? Colors.black : Colors.white,
          gradient: new LinearGradient(
            colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
          )
        ),
      );
    }
  }
}