// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:trimmz/Model/Availability.dart';
// import 'package:trimmz/globals.dart' as globals;
// import 'package:trimmz/helpers.dart';
// import 'package:trimmz/palette.dart';
// import 'package:progress_hud/progress_hud.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:trimmz/calls.dart';
// import 'dart:ui' as ui;
// import 'dart:math' as math;
// import 'package:trimmz/Model/User.dart';
// import 'package:intl/intl.dart';

// class UserProfileControllerV2 extends StatefulWidget {
//   final int token;
//   UserProfileControllerV2({Key key, this.token}) : super (key: key);

//   @override
//   UserProfileControllerV2State createState() => new UserProfileControllerV2State();
// }

// class UserProfileControllerV2State extends State<UserProfileControllerV2> with TickerProviderStateMixin {
//   ProgressHUD _progressHUD;
//   bool _loadingInProgress = false;
//   final ValueNotifier<double> headerNegativeOffset = ValueNotifier<double>(0);

//   @override
//   void initState() {

//     _progressHUD = new ProgressHUD(
//       color: Colors.white,
//       borderRadius: 8.0,
//       loading: false,
//       text: 'Loading...'
//     );

//     super.initState();
//   }

//   void progressHUD() {
//     setState(() {
//       if (_loadingInProgress) {
//         _progressHUD.state.dismiss();
//       } else {
//         _progressHUD.state.show();
//       }
//       _loadingInProgress = !_loadingInProgress;
//     });
//   }

//   bodyLoading() {
//     return Container();
//   }

//   buildLayer1(User user) {
//     return Container(
//       margin: EdgeInsets.only(top: 5, bottom: 5),
//       child: Row(
//         children: [
//           buildUserProfilePicture(context, user.profilePicture, user.name),
//           Padding(padding: EdgeInsets.all(10.0)),
//           Expanded(
//             flex: 9,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user.name,
//                   style: TextStyle(
//                     fontSize: 17.0,
//                     fontWeight: FontWeight.w600
//                   )
//                 ),
//                 Text(
//                   "@${user.username}",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontWeight: FontWeight.normal
//                   )
//                 )
//               ],
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: RaisedButton(
//                     onPressed: () => print("EDIT PROFILE / FOLLOW-UNFOLLOW"),
//                     child: Text("Edit Profile"),
//                   ),
//                 )
//               ]
//             ),
//           )
//         ]
//       ),
//     );
//   }

//   buildLayerBio(User user) {
//     if(user.bio != null) {
//       return Container(
//         margin: EdgeInsets.only(top: 5, bottom: 5),
//         child: Row(
//           children: [
//             Expanded(
//               child: RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: "${user.bio}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.normal,
//                       )
//                     ),
//                   ]
//                 ),
//               ),
//             )
//           ]
//         ),
//       );
//     }else {
//       return Container();
//     }
//   }

//   buildLayerAdditionalInfo(User user) {
//     return Container(
//       margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.pin_drop_outlined, color: Colors.grey, size: 18),
//               Padding(padding: EdgeInsets.all(2)),
//               Text(
//                 "7027 Winword Way, Cincinnati, OH 45241",
//                 style: TextStyle(
//                   color: Colors.grey
//                 )
//               )
//             ]
//           ),
//         ],
//       )
//     );
//   }

//   buildLayerStats(User user) {
//     return Container(
//       margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
//       child: Row(
//         children: [
//           RichText(
//             text: TextSpan(
//               children: [
//                 TextSpan(
//                   text: "4,790 ",
//                   style: TextStyle(
//                     fontSize: 14.0,
//                     fontWeight: FontWeight.w600,
//                   )
//                 ),
//                 TextSpan(
//                   text: "Clients",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontWeight: FontWeight.normal,
//                   )
//                 )
//               ]
//             ),
//           ),
//           Padding(padding: EdgeInsets.all(5)),
//           RichText(
//             text: TextSpan(
//               children: [
//                 TextSpan(
//                   text: "10,394 ",
//                   style: TextStyle(
//                     fontSize: 14.0,
//                     fontWeight: FontWeight.w600,
//                   )
//                 ),
//                 TextSpan(
//                   text: "Appointments",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontWeight: FontWeight.normal,
//                   )
//                 )
//               ]
//             ),
//           ),
//         ]
//       ),
//     );
//   }

//   buildTodayHours(List<Availability> availability) {
//     final DateFormat df = new DateFormat('yyyy-MM-dd');
//     Availability currentDay = availability.where((element) => df.format(element.date) == df.format(DateTime.now())).first;
//     String text = "";

//     if(currentDay != null) {
//       if(currentDay.closed) {
//         text = "Closed";
//       }else {
//         text = "${formatTime(currentDay.start, false)} - ${formatTime(currentDay.end, false)}";
//       }
//     }else {
//       text = "Closed";
//     }

//     return RichText(
//       text: TextSpan(
//         children: [
//           TextSpan(
//             text: "Today: ",
//             style: TextStyle(
//               fontSize: 14.0,
//               fontWeight: FontWeight.w600,
//             )
//           ),
//           TextSpan(
//             text: "$text",
//             style: TextStyle(
//               color: Colors.grey,
//               fontWeight: FontWeight.normal,
//             )
//           )
//         ]
//       ),
//     );
//   }

//   buildWeekHours(List<Availability> availability) {
//     List<Widget> children = [];
//     List<Availability> currentWeekAvailability = [];
//     List<DateTime> weekList = [];
//     for(int i=1 ; i<7;i++){
//       weekList.add(DateTime.parse(DateFormat('yyyy-MM-dd 12:00:00').format(DateTime.now().add(new Duration(days: i)))));
//     }
//     for(var item in weekList) {
//       var currentDate = availability.where((element) => element.date == item).first;
//       currentWeekAvailability.add(currentDate);
//     }
    
//     currentWeekAvailability.forEach((element) {
//       Widget widget = new Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               "${DateFormat.EEEE().format(element.date)}",
//               style: TextStyle(
//                 fontSize: 14.0,
//                 fontWeight: FontWeight.w600,
//               )
//             ),
//           ),
//           Expanded(
//             flex: 9,
//             child: Text(
//               "${formatTime(element.start, false)} - ${formatTime(element.end, false)}",
//               style: TextStyle(
//                 fontSize: 14.0,
//                 fontWeight: FontWeight.w600,
//               )
//             ),
//           )
//         ]
//       );
//       children.add(widget);
//     });

//     return children;
//   }

//   buildExpansionTiles(User user) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 5.0),
//       child: Column(
//         children: [
//           ExpansionTile(
//             tilePadding: EdgeInsets.all(0),
//             title: Text(
//               "Hours",
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 13.0
//               ),
//             ),
//             subtitle: buildTodayHours(user.availability),
//             children: buildWeekHours(user.availability),
//           ),
//           ExpansionTile(
//             tilePadding: EdgeInsets.all(0),
//             title: Text(
//               "Services",
//             ),
//           )
//         ]
//       )
//     );
//   }

//   _buildBody() {
//     return FutureBuilder(
//       future: getUserById(context, widget.token),
//       builder: (context, snapshot) {
//         if(snapshot.hasData) {
//           return Container(
//             padding: EdgeInsets.all(15.0),
//             child: Column(
//               children: [
//                 buildLayer1(snapshot.data),
//                 buildLayerBio(snapshot.data),
//                 buildLayerAdditionalInfo(snapshot.data),
//                 buildLayerStats(snapshot.data),
//                 buildExpansionTiles(snapshot.data)
//               ]
//             )
//           );
//         }else {
//           return bodyLoading();
//         }
//       }
//     );
//   }

//   SliverAppBar _appBar(bool isScrolled) {
//     return SliverAppBar(
//       forceElevated: false,
//       expandedHeight: 125,
//       stretch: true,
//       stretchTriggerOffset: 150,
//       onStretchTrigger: () {
//         return;
//       },
//       pinned: true,
//       floating: true,
//       snap: true,
//       actionsIconTheme: IconThemeData(opacity: 0.0),
//       flexibleSpace: CustomFlexibleSpace(token: widget.token),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new Theme(
//       data: new ThemeData(
//         primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
//         brightness: globals.userBrightness,
//         accentColor: globals.darkModeEnabled ? Colors.white : Colors.black,
//         dividerColor: Colors.transparent
//       ),
//       child: new Scaffold(
//         body: AnnotatedRegion<SystemUiOverlayStyle>(
//           value: SystemUiOverlayStyle.light,
//           child: GestureDetector(
//             onTap: () => FocusScope.of(context).unfocus(),
//             child: new Container(
//               color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
//               child: new NestedScrollView(
//                 physics: BouncingScrollPhysics(),
//                 headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
//                   return [
//                     _appBar(boxIsScrolled)
//                   ];
//                 },
//                 body: _buildBody()
//               ),
//             )
//           )
//         )
//       )
//     );
//   }
// }

// class CustomFlexibleSpace extends StatelessWidget {
//   final int token;
//   const CustomFlexibleSpace({Key key, this.token}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, c) {
//         final settings = context
//             .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
//         final deltaExtent = settings.maxExtent - settings.minExtent;
//         final t =
//             (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
//                 .clamp(0.0, 1.0) as double;
//         final fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
//         const fadeEnd = 1.0;
//         final opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
//         final double blurAmount = (c.maxHeight - settings.maxExtent) / 10;

//         return ClipRect(
//           child: Stack(
//             children: [
//               Center(
//                 child: Opacity(
//                     opacity: 1 - opacity,
//                     child: Stack(
//                       alignment: Alignment.bottomCenter,
//                       children: [
//                         _buildHeader(context, token, true),
//                       ],
//                     ),
//                 )
//               ),
//               Opacity(
//                 opacity: opacity,
//                 child: Stack(
//                   alignment: Alignment.bottomCenter,
//                   children: [
//                     _buildHeader(context, token, false)
//                   ],
//                 ),
//               ),
//               c.maxHeight > settings.maxExtent ? Positioned.fill(
//                 child: BackdropFilter(
//                   child: Container(
//                     color: Colors.transparent,
//                   ),
//                   filter: ui.ImageFilter.blur(
//                     sigmaX: blurAmount,
//                     sigmaY: blurAmount
//                   )
//                 )
//               ) : Container()
//             ],
//           )
//         );
//       },
//     );
//   }

//   _buildHeader(BuildContext context, int token, bool blur) {
//     return FutureBuilder(
//       future: getUserById(context, token),
//       builder: (context, snapshot) {
//         if(snapshot.hasData) {
//           return Container(
//             decoration: snapshot.data.headerImage != null ? BoxDecoration(
//               image: DecorationImage(
//                 image: NetworkImage(
//                   "${globals.baseImageUrl}${snapshot.data.headerImage}",
//                 ),
//                 fit: BoxFit.cover
//               )
//             ): BoxDecoration(),
//             child: blur ? ClipRRect(
//               child: BackdropFilter(
//                 filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                 child: Container(
//                   alignment: Alignment.center,
//                   color: globals.darkModeEnabled ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 45),
//                     child: Text(
//                       "${snapshot.data.username}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 18.0
//                       ),
//                     ),
//                   )
//                 ),
//               ),
//             ) : Container(),
//           );
//         }else {
//           return Container(
//             child: Shimmer.fromColors(
//               baseColor: richBlack,
//               highlightColor: Color.fromARGB(255, 12, 13, 14),
//               child: Container(
//                 color: Colors.black
//               ),
//               period: Duration(seconds: 3),
//             ),
//           );
//         }
//       }
//     );
//   }
// }