import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/Model/Availability.dart';
import 'package:trimmz/Model/GalleryItem.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/helpers.dart';
import 'package:trimmz/palette.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trimmz/calls.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:trimmz/Model/User.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trimmz/RippleButton.dart';
import 'package:trimmz/Model/Service.dart';
import 'package:trimmz/Controller/ConversationController.dart';

class UserProfileController extends StatefulWidget {
  final int token;
  UserProfileController({Key key, this.token}) : super (key: key);

  @override
  UserProfileControllerState createState() => new UserProfileControllerState();
}

class UserProfileControllerState extends State<UserProfileController> with TickerProviderStateMixin {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  final ValueNotifier<double> headerNegativeOffset = ValueNotifier<double>(0);

  @override
  void initState() {

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

  bodyLoading() {
    return Container();
  }

  buildLayer1(User user) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          buildUserProfilePicture(context, user.profilePicture, user.name),
          Padding(padding: EdgeInsets.all(3.0)),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600
                  )
                ),
                Text(
                 "@${user.username}",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80),
                    fontWeight: FontWeight.normal
                  )
                )
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: globals.user.token == widget.token ?  Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RippleButton(
                  splashColor: CustomColors1.mystic.withAlpha(100),
                  onPressed: () {
                    
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Text("Edit Profile"),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      border: Border.all(
                        color: globals.darkModeEnabled ? Colors.white60.withAlpha(180) : Colors.black87.withAlpha(180),
                        width: 1
                      )
                    ),
                  )
                )
              ]
            ) : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RippleButton(
                  splashColor: CustomColors1.mystic.withAlpha(100),
                  onPressed: () async {
                    var result = await handleFollowing(context, globals.user.token, user.id, !user.isFollowing);
                    setState(() {
                      user.isFollowing = result;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: user.isFollowing ? Text("Following") : Text("Follow"),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      border: Border.all(
                        color: globals.darkModeEnabled ? Colors.white60.withAlpha(180) : Colors.black87.withAlpha(180),
                        width: 1
                      )
                    ),
                  )
                ),
                RippleButton(
                  splashColor: CustomColors1.mystic.withAlpha(100),
                  onPressed: () {
                    final conversationController = new ConversationController(user: user);

                    Navigator.push(context, new MaterialPageRoute(builder: (context) => conversationController));
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Icon(Icons.mail_outline, size: 17),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      border: Border.all(
                        color: globals.darkModeEnabled ? Colors.white60.withAlpha(180) : Colors.black87.withAlpha(180),
                        width: 1
                      )
                    ),
                  )
                ),
              ]
            ),
          )
        ]
      ),
    );
  }

  buildLayerBio(User user) {
    if(user.bio != null) {
      return Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${user.bio}",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      )
                    ),
                  ]
                ),
              ),
            )
          ]
        ),
      );
    }else {
      return Container();
    }
  }

  buildLayerAdditionalInfo(User user) {
    String address = "";
    if(user.shopAddress != null) {
      address = "${user.shopAddress}, ${user.city}, ${user.state} ${user.zipcode}";
    }else {
      address = "${user.city}, ${user.state} ${user.zipcode}";
    }
    return Container(
      margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          user.shopName != null ? Row(
            children: [
              Icon(Icons.business_outlined, color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80), size: 18),
              Padding(padding: EdgeInsets.all(2)),
              Text(
                user.shopName,
                style: TextStyle(
                  color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80)
                )
              )
            ]
          ): Container(),
          Padding(padding: EdgeInsets.all(2)),
          Row(
            children: [
              Icon(Icons.pin_drop_outlined, color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80), size: 18),
              Padding(padding: EdgeInsets.all(2)),
              Text(
                address,
                style: TextStyle(
                  color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80)
                )
              )
            ]
          ),
          Padding(padding: EdgeInsets.all(2)),
          Row(
            children: [
              Icon(Icons.star, color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80), size: 18),
              Padding(padding: EdgeInsets.all(2)),
              Text(
                user.rating != "0" ? double.parse(user.rating).toStringAsFixed(1) : "N/A",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80)
                )
              ),
              Padding(padding: EdgeInsets.all(3)),
              RatingBarIndicator(
                rating: double.parse(user.rating),
                itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Color(0xFFD2AC47),
                ),
                itemCount: 5,
                itemSize: 13.0,
                direction: Axis.horizontal,
                unratedColor: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80),
              ),
              Padding(padding: EdgeInsets.all(1)),
              Text(
                "(${user.numOfReviews})",
                style: TextStyle(
                  color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80)
                )
              )
            ]
          ),
        ],
      )
    );
  }

  buildLayerStats(User user) {
    return Container(
      margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "N/A ",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: globals.darkModeEnabled ? Colors.white : Colors.black
                  )
                ),
                TextSpan(
                  text: "Clients",
                  style: TextStyle(
                    color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80),
                    fontWeight: FontWeight.normal,
                  )
                )
              ]
            ),
          ),
          Padding(padding: EdgeInsets.all(5)),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "N/A ",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: globals.darkModeEnabled ? Colors.white : Colors.black
                  )
                ),
                TextSpan(
                  text: "Appointments",
                  style: TextStyle(
                    color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80),
                    fontWeight: FontWeight.normal,
                  )
                )
              ]
            ),
          ),
        ]
      ),
    );
  }

  buildTodayHours(List<Availability> availability) {
    final DateFormat df = new DateFormat('yyyy-MM-dd');
    var currentDay = availability.where((element) => df.format(element.date) == df.format(DateTime.now()));
    String text = "";

    if(currentDay.length != 0) {
      if(currentDay.first.closed) {
        text = "Closed";
      }else {
        text = "${formatTime(currentDay.first.start, false)} - ${formatTime(currentDay.first.end, false)}";
      }
    }else {
      text = "Closed";
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Today: ",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: globals.darkModeEnabled ? Colors.white : Colors.black
            )
          ),
          TextSpan(
            text: "$text",
            style: TextStyle(
              color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80),
              fontWeight: FontWeight.normal,
            )
          )
        ]
      ),
    );
  }

  buildWeekHours(List<Availability> availability) {
    List<Widget> children = [];
    List<Availability> currentWeekAvailability = [];
    List<DateTime> weekList = [];
    for(int i=1 ; i<7;i++){
      weekList.add(DateTime.parse(DateFormat('yyyy-MM-dd 12:00:00').format(DateTime.now().add(new Duration(days: i)))));
    }
    for(var item in weekList) {
      var currentDate = availability.where((element) => element.date == item);
      if(currentDate.length > 0) {
        currentWeekAvailability.add(currentDate.first);
      }else {
        var avail = new Availability({}, otherDate: item);
        currentWeekAvailability.add(avail);
      }
    }
    
    currentWeekAvailability.forEach((element) {
      Widget widget = new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "${DateFormat.EEEE().format(element.date)}",
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              )
            ),
          ),
          Expanded(
            flex: 9,
            child: Text(
              element.id == null || element.closed ? "Closed" : "${formatTime(element.start, false)} - ${formatTime(element.end, false)}",
              style: TextStyle(
                color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80),
                fontWeight: FontWeight.normal,
              )
            ),
          )
        ]
      );
      children.add(widget);
    });

    return children;
  }

  buildServicesList(List<Service> services) {
    List<Widget> children = [];
    for(Service item in services) {
      Widget widget = new Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  Text(
                    "${item.duration} minutes",
                    style: TextStyle(
                      color: textGrey
                    ),
                  )
                ]
              )
            ),
            Text(
              "\$${item.price}"
            )
          ],
        )
      );
      children.add(widget);
    }

    return children;
  }

  buildExpansionTiles(User user) {
    user.services.sort((a,b) => a.price.compareTo(b.price));
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: Column(
        children: [
          ExpansionTile(
            tilePadding: EdgeInsets.all(0),
            title: Text(
              "Hours",
              style: TextStyle(
                color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80),
                fontSize: 13.0
              ),
            ),
            subtitle: buildTodayHours(user.availability),
            children: buildWeekHours(user.availability),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.all(0),
            title: Text(
              "Services",
            ),
            children: buildServicesList(user.services),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.all(0),
            title: Text(
              "Policies",
            ),
          )
        ]
      )
    );
  }

  _buildGridTile(GalleryItem item) {
    return new GestureDetector(
      onTap: () {
        // showImageDialog(context, item.imageName);
      },
      child: Container(
        child: new Column(
          children: <Widget>[
            new Expanded(
              flex: 5,
              child: new Container(
                child: Image.network(item.imageName, fit: BoxFit.fill,),
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(2.0))
                ),
              ),
            ),
          ],
        ),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        )
      )
    );
  }

  buildGallery(User user) {
    if(user.gallery.length > 0) {
      return new GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: user.gallery.length,
        padding: EdgeInsets.all(0),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: user.gallery.length > 9 ? 3 : 2,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
          childAspectRatio: 1.0
        ),
        itemBuilder: (context, index) {
          return new Card(
            child: _buildGridTile(user.gallery[index]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0))
            ),
          );
        },
      );
    }else {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${user.username} has no photos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * .018,
                color: Colors.grey[600]
              )
            ),
          ],
        ),
      );
    }
  }

  _buildBody() {
    return FutureBuilder(
      future: getUserById(context, widget.token, globals.user.token),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  buildLayer1(snapshot.data),
                  buildLayerBio(snapshot.data),
                  buildLayerAdditionalInfo(snapshot.data),
                  buildLayerStats(snapshot.data),
                  buildExpansionTiles(snapshot.data),
                  buildGallery(snapshot.data)
                ]
              )
            )
          );
        }else {
          return bodyLoading();
        }
      }
    );
  }

  SliverAppBar _appBar(bool isScrolled) {
    return SliverAppBar(
      forceElevated: false,
      expandedHeight: 125,
      stretch: true,
      stretchTriggerOffset: 150,
      onStretchTrigger: () {
        return;
      },
      pinned: true,
      floating: true,
      snap: true,
      actionsIconTheme: IconThemeData(opacity: 0.0),
      flexibleSpace: CustomFlexibleSpace(token: widget.token),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
        accentColor: globals.darkModeEnabled ? Colors.white : Colors.black,
        dividerColor: Colors.transparent
      ),
      child: new Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: new Container(
              color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
              child: new NestedScrollView(
                physics: BouncingScrollPhysics(),
                headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
                  return [
                    _appBar(boxIsScrolled)
                  ];
                },
                body: _buildBody()
              ),
            )
          )
        )
      )
    );
  }
}

class CustomFlexibleSpace extends StatelessWidget {
  final int token;
  const CustomFlexibleSpace({Key key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        final deltaExtent = settings.maxExtent - settings.minExtent;
        final t =
            (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
                .clamp(0.0, 1.0) as double;
        final fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
        const fadeEnd = 1.0;
        final opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
        final double blurAmount = (c.maxHeight - settings.maxExtent) / 10;

        return ClipRect(
          child: Stack(
            children: [
              Center(
                child: Opacity(
                    opacity: 1 - opacity,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        _buildHeader(context, token, true),
                      ],
                    ),
                )
              ),
              Opacity(
                opacity: opacity,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    _buildHeader(context, token, false)
                  ],
                ),
              ),
              c.maxHeight > settings.maxExtent ? Positioned.fill(
                child: BackdropFilter(
                  child: Container(
                    color: Colors.transparent,
                  ),
                  filter: ui.ImageFilter.blur(
                    sigmaX: blurAmount,
                    sigmaY: blurAmount
                  )
                )
              ) : Container()
            ],
          )
        );
      },
    );
  }

  _buildHeader(BuildContext context, int token, bool blur) {
    return FutureBuilder(
      future: getUserById(context, token, globals.user.token),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return Container(
            decoration: snapshot.data.headerImage != null ? BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "${globals.baseImageUrl}${snapshot.data.headerImage}",
                ),
                fit: BoxFit.cover
              )
            ): BoxDecoration(),
            child: blur ? ClipRRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  alignment: Alignment.center,
                  color: globals.darkModeEnabled ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                  child: Padding(
                    padding: EdgeInsets.only(top: 45),
                    child: Text(
                      "${snapshot.data.username}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0
                      ),
                    ),
                  )
                ),
              ),
            ) : Container(),
          );
        }else {
          return Container(
            child: Shimmer.fromColors(
              baseColor: richBlack,
              highlightColor: Color.fromARGB(255, 12, 13, 14),
              child: Container(
                color: Colors.black
              ),
              period: Duration(seconds: 3),
            ),
          );
        }
      }
    );
  }
}