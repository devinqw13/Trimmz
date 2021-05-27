import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/Controller/BookAppointmentController.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import 'package:trimmz/Model/User.dart';

class SelectUserBookAppointmentController extends StatefulWidget {
  final int token;
  SelectUserBookAppointmentController({Key key, this.token}) : super (key: key);

  @override
  SelectUserBookAppointmentControllerState createState() => new SelectUserBookAppointmentControllerState();
}

class SelectUserBookAppointmentControllerState extends State<SelectUserBookAppointmentController> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  StreamController<String> searchStreamController = StreamController();
  List<User> searchedUsers = [];
  final TextEditingController searchTFController = new TextEditingController();
  int charLength = 0;

  @override
  void initState() {
    super.initState();

    _progressHUD = new ProgressHUD(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      color: globals.darkModeEnabled ? lightBackgroundGrey : darkGrey,
      containerColor: globals.darkModeEnabled ? darkGrey : lightBackgroundGrey,
      borderRadius: 8.0,
      text: "Loading...",
      loading: false,
    );

    searchStreamController.stream
    .debounce(Duration(milliseconds: 300))
    .listen((s) => _searchUsers(s));
  }

  _searchUsers(String s) async {
    if(s.length > 0) {
      var results = await getSearchUsers(context, s);
      print(results);
      setState(() {
        charLength = s.length;
        searchedUsers = results;
      });
    }else if(s.length == 0) {
      setState(() {
        charLength = s.length;
        searchedUsers = [];
      });
    }
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

  buildGridTile(var user) {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Container(
              child: new Center(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildUserProfilePicture(context, user.profilePicture, user.username),
                    Column(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 19
                          ),
                        ),
                        Text(
                          "@${user.username}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey
                          ),
                        )
                      ],
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
          new Expanded(
            flex: 1,
            child: new Container(
              child: new Center(
                child: new FlatButton(
                  onPressed: () async {
                    final bookAppointmentController = new BookAppointmentController(user: user);
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => bookAppointmentController));
                  },
                  child: Text('Book Appointment', 
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal
                    ),
                  )
                )
              ),
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(2.0), bottomRight: Radius.circular(2.0)),
              )
            )
          )
        ],
      ),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      )
    );
  }

  buildUsersList(var users) {
    return new GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: users.length,
      padding: EdgeInsets.all(2),
      shrinkWrap: true,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15.0,
        crossAxisSpacing: 15.0,
        childAspectRatio: 0.9
      ),
      itemBuilder: (context, index) {
        return new Card(
          child: buildGridTile(users[index]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0))
          ),
        );
      },
    );
  }

  Widget _buildScreen() {
    return Container(
      padding: EdgeInsets.all(10),
      height: double.infinity,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                color: globals.darkModeEnabled ? darkBackgroundGrey : Color.fromARGB(255, 232, 232, 232),
                borderRadius: BorderRadius.circular(50.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchTFController,
                keyboardType: TextInputType.text,
                autocorrect: false,
                onChanged: (val) {
                  searchStreamController.add(val);
                },
                style: TextStyle(
                  color: globals.darkModeEnabled ? Colors.white : Colors.black,
                  fontFamily: 'OpenSans',
                ),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: 15, right: 8, top: 8, bottom: 8),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: globals.darkModeEnabled ? Colors.white54 : Colors.black54,
                    fontFamily: 'OpenSans',
                  ),
                ),
              )
            ),
            searchedUsers.length == 0 && charLength == 0 ? FutureBuilder(
              future: getFollowedUsers(context, globals.user.token),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return buildUsersList(snapshot.data);
                } else {
                  return CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation(Colors.blue)
                  );
                }
              }
            ) : searchedUsers.length == 0 && charLength > 0 ? Center(child: Text("No Results Found")) : buildUsersList(searchedUsers)
          ]
        )
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
            "Book with",
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