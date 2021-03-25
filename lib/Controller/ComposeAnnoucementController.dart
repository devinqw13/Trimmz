import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/RippleButton.dart';
import 'package:trimmz/calls.dart';

class ComposeAnnoucementController extends StatefulWidget {
  final List<int> recipients;
  ComposeAnnoucementController({Key key, this.recipients}) : super (key: key);

  @override
  ComposeAnnoucementControllerState createState() => new ComposeAnnoucementControllerState();
}

class ComposeAnnoucementControllerState extends State<ComposeAnnoucementController> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  TextEditingController textController = new TextEditingController();
  bool canSendAnnouncement = false;

  void initState() {
    super.initState();

    textController.addListener(() {
      if(textController.text.length != 0) {
        setState(() {
          canSendAnnouncement = true;
        });
      }else {
        setState(() {
          canSendAnnouncement = false;
        });
      }
    });

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );
  }

  void progressHUD() {
    setState(() {
      if (_loadingInProgress) {
        _progressHUD.state.dismiss();
      } else {
        _progressHUD.state.show();
      }
      _loadingInProgress = !_loadingInProgress;
    });
  }

  sendAnnouncement() async {
    progressHUD();
    String message = "[${globals.user.username}]: ${textController.text}";
    for(int item in widget.recipients) {
      print(item);
      var _ = await postAnnoucement(context, globals.user.token, item, message);
    }
    progressHUD();
    Navigator.pop(context, true);
  }

  Widget _buildScreen() {
    return Container(
      padding: EdgeInsets.only(bottom: 25, left: 10, right: 10, top: 10),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Annoucement',
                hintStyle: TextStyle(fontStyle: FontStyle.italic),
                border: InputBorder.none,
              ),
            )
          ),
          canSendAnnouncement ? Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(110, 0, 0, 0),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    border: Border.all(
                      color: CustomColors1.mystic.withAlpha(100)
                    )
                  ),
                  child: RippleButton(
                    splashColor: CustomColors1.mystic.withAlpha(100),
                    onPressed: () {
                      sendAnnouncement();
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                      child: Center(
                        child: Text(
                          "Send Announcement",
                          style: TextStyle(
                            color: Colors.white
                          )
                        ),
                      )
                    )
                  )
                ),
              )
            ]
          ): Container()
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Create Annoucement",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          elevation: 0.0,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: new Container(
              color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
              child: new Stack(
                children: [
                  _buildScreen(),
                  _progressHUD,
                ]
              )
            )
          )
        )
      )
    );
  }
}