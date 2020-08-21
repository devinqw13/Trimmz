import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:progress_hud/progress_hud.dart';
import '../Calls/GeneralCalls.dart';
import '../View/Widgets.dart';

class AdminPortal extends StatefulWidget {
  AdminPortal({Key key}) : super (key: key);

  @override
  AdminPortalState createState() => new AdminPortalState();
}

class AdminPortalState extends State<AdminPortal> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List allUsers = [];

  void initState() {
    super.initState();

    initSetup();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );
  }

  initSetup() async {
    var res = await getAllUsers(context);
    setState(() {
      allUsers = res;
    });
    print(allUsers);
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

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: globals.darkModeEnabled ? Color.fromARGB(255, 21, 21, 21) : Color.fromARGB(255, 225, 225, 225),
      nextFocus: true,
      actions: [
        // KeyboardAction(
        //   onTapAction: () {
        //     if(_tipController.text != ''){
        //       setState(() {
        //         finalTip = int.parse(_tipController.text);
        //       });
        //     }
        //   },
        //   focusNode: _numberFocus,
        //   closeWidget: Padding(
        //     padding: EdgeInsets.all(8.0),
        //     child: Text('Done', style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black)),
        //   ),
        // ),
      ],
    );
  }

  buildUserScrollBlock(var user) {
    return new GestureDetector(
      onTap: () {

      },
      child: Stack(
        children: <Widget> [
          Container(
            height: 100.0,
            child: new Column(
              children: <Widget>[
                new Expanded(
                  flex: 5,
                  child: new Container(
                    child: new Center(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          buildProfilePictures(context, user['profile_picture'], user['name'], 30),
                          Text(
                            user['name'],
                          )
                        ],
                      ),
                    ),
                    decoration: new BoxDecoration(
                      color: globals.darkModeEnabled ? Color.fromARGB(255, 21, 21, 21) : Color.fromARGB(255, 225, 225, 225),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(2.0), topRight: Radius.circular(2.0))
                    ),
                  ),
                ),
              ],
            ),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            )
          ),
          Container(
            height: 10,
            width: 10,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: DateTime.parse(user['last_login']).isAfter(DateTime.now().subtract(Duration(days: 1))) ? Colors.green : Colors.red,
              shape: BoxShape.circle
            ),
          )
        ]
      )
    );
  }

  buildUserList() {
    if(allUsers.length > 0) {
      return new Container(
        height: 100,
        child: GridView.builder(
          itemCount: allUsers.length,
          padding: EdgeInsets.all(2),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 5.0,
            childAspectRatio: 0.9
          ),
          itemBuilder: (context, i) {
            return new Card(
              child: buildUserScrollBlock(allUsers[i]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2.0))
              ),
            );
          },
        )
      );
    }else {
      return Center(
        child: Container(
          margin: EdgeInsets.all(5),
          child: CircularProgressIndicator()
        )
      );
    }
  }

  buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(0.0, -8.0),
                        colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[850]] : [Colors.grey[500], Colors.grey[50]]
                      )
                    ),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(5.0),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Users', style: TextStyle(fontWeight: FontWeight.w400)),
                            Icon(Icons.menu, color: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400])
                          ]
                        ),
                        buildUserList()
                      ]
                    )
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: globals.userColor,
        brightness: globals.userBrightness,
      ),
      child: Scaffold(
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          centerTitle: true,
          title: new Text('Admin Portal')
        ),
        body: KeyboardActions(
          autoScroll: false,
          config: _buildConfig(context),
          child: Stack(
            children: <Widget> [
              buildBody(),
              _progressHUD
            ]
          )
        )
      )
    );
  }
}