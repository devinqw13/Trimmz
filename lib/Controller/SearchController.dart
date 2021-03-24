import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:trimmz/calls.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:async/async.dart';
import 'package:trimmz/Controller/UserProfileController.dart';
import 'package:trimmz/Model/User.dart';
import 'package:trimmz/helpers.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SearchController extends StatefulWidget {
  SearchController({Key key}) : super (key: key);

  @override
  SearchControllerState createState() => SearchControllerState();
}

class SearchControllerState extends State<SearchController> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  AsyncMemoizer _memoizer;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _memoizer = AsyncMemoizer();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    super.initState();
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

  _fetchUserByLocationData() async {
    int zipcode = await getCurrentLocationZipcode();
    return this._memoizer.runOnce(() async {
      var res = await getUsersByLocation(context, zipcode);
      return res;
    });
  }

  goToUserProfile(int token) {
    final userProfileController = new UserProfileController(token: token);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => userProfileController));
  }

  Widget _buildUserSearchCard(User user) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildUserProfilePicture(context, user.profilePicture, user.name),
            Padding(padding: EdgeInsets.all(4)),
            Expanded(
              flex: 9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${user.name} ",
                          style: TextStyle(
                            color: globals.darkModeEnabled ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0
                          )
                        ),
                        TextSpan(
                          text: "@${user.username}",
                          style: TextStyle(
                            color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0
                          )
                        )
                      ]
                    ),
                  ),
                  user.shopName != null && user.shopName != "" ?
                  Text(
                    user.shopName,
                    style: TextStyle(
                      color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0
                    )
                  ) : Container(),
                  user.shopAddress != null ?
                  Text(
                    "${user.shopAddress}, ${user.city}, ${user.state} ${user.zipcode}",
                    style: TextStyle(
                      color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                      fontWeight: FontWeight.normal,
                      fontSize: 13.0
                    )
                  ) : Text(
                    "${user.city}, ${user.state} ${user.zipcode}",
                    style: TextStyle(
                      color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                      fontWeight: FontWeight.normal,
                      fontSize: 13.0
                    )
                  )
                ]
              )
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "${user.numOfReviews} Ratings",
                  ),
                  Text(
                    user.rating != "0" ? double.parse(user.rating).toStringAsFixed(1) : "N/A",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  ),
                  RatingBarIndicator(
                    rating: double.parse(user.rating),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Color(0xFFD2AC47),
                    ),
                    itemCount: 5,
                    itemSize: 13.0,
                    direction: Axis.horizontal,
                    unratedColor: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                  ),
                ],
              ),
            ),
          ]
        )
      )
    );
  }

  Widget buildSearchResults(List<User> users) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        child: ListView.builder(
          itemCount: users.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => goToUserProfile(users[index].id),
              child: Card(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: users[index].headerImage != null ? NetworkImage(
                        "${globals.baseImageUrl}${users[index].headerImage}",
                      ) : AssetImage("images/trimmz_icon_t.png"),
                      fit: BoxFit.cover
                    )
                  ),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        alignment: Alignment.center,
                        color: globals.darkModeEnabled ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6),
                        child: _buildUserSearchCard(users[index])
                      ),
                    ),
                  ),
                )
              )
            );
          },
        ),
      )
    );
  }

  _buildSearchList() {
    return FutureBuilder(
      future: _fetchUserByLocationData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildSearchResults(snapshot.data);
        } else {
          return CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation(Colors.blue)
          );
        }
      }
    );
  }

  Widget _buildSearchTF() {
    return Container(
      decoration: BoxDecoration(
        color: globals.darkModeEnabled ? darkBackgroundGrey : Color.fromARGB(255, 232, 232, 232),
        borderRadius: BorderRadius.circular(50.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        autocorrect: false,
        style: TextStyle(
          color: globals.darkModeEnabled ? Colors.white : Colors.black,
          fontFamily: 'OpenSans',
        ),
        decoration: InputDecoration(
          border: UnderlineInputBorder(borderSide: BorderSide.none),
          isDense: true,
          contentPadding: EdgeInsets.only(left: 15, right: 8, top: 8, bottom: 8),
          hintText: 'Search Trimmz',
          hintStyle: TextStyle(
            color: globals.darkModeEnabled ? Colors.white54 : Colors.black54,
            fontFamily: 'OpenSans',
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        brightness: globals.userBrightness,
        automaticallyImplyLeading: false,
        backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
        centerTitle: true,
        title: _buildSearchTF(),
        elevation: 0.0,
      ),
      body: Container(
        color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
        child: new WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: _buildSearchList()
              ),
            ],
          )
        )
      )
    );
  }
}