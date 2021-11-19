import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trimmz/Globals.dart' as globals;
import 'package:trimmz/Constants.dart';
import 'package:trimmz/SizeConfig.dart';
import 'package:trimmz/Components/FloatingContainer.dart';
import 'package:trimmz/Views/CustomBottomSheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:trimmz/Model/User.dart';
import 'package:trimmz/Model/Notification.dart' as nt;
import 'package:trimmz/Extensions.dart';

class HomeBody extends StatefulWidget {
  final Function dismissProgressHUD;

  HomeBody({
    @required this.dismissProgressHUD,
  });

  @override
  _HomeBody createState() => _HomeBody();
}

class _HomeBody extends State<HomeBody> {
  List<nt.Notification> notifications = [];

  @override
  void initState() {
    super.initState();

  }

  Widget buildHeader() {
    return FloatingContainer(
      padding: EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
        bottom: 10.0
      ),
      borderRadius: BorderRadius.circular(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  showCupertinoModalBottomSheet(
                    barrierColor: Colors.black45,
                    expand: false,
                    context: context,
                    builder: (context) => NotificationModal(),
                  );
                },
                child: SvgPicture.asset(
                  "assets/icons/Bell.svg",
                  height: getProportionateScreenWidth(19),
                  width: getProportionateScreenWidth(19),
                  color: Colors.black,
                )
              ),
              GreetingsMessage(),
              GestureDetector(
                onTap: () {
                  showAvatarModalBottomSheet(
                    expand: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ModalInsideModal(),
                  );
                },
                child: SvgPicture.asset(
                  "assets/icons/Search.svg",
                  height: getProportionateScreenWidth(18),
                  width: getProportionateScreenWidth(10),
                  color: Colors.black,
                )
              )
            ]
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.01),
          User().photoUrl == '' ? Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/icons/User.svg",
                height: getProportionateScreenWidth(55),
                width: getProportionateScreenWidth(55),
                color: Colors.white,
              ) 
            )
          ) : ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: new Image.network('${globals.baseImageUrl}${User().photoUrl}',
              height: 100.0,
              fit: BoxFit.fill,
            )
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        children: [
          buildHeader(),
          SizedBox(height: SizeConfig.screenHeight * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    "Overview",
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 21.0
                    ),
                  ),
                  SizedBox(width: 10.0),
                  GestureDetector(
                    child: SvgPicture.asset(
                      "assets/icons/Plus.svg",
                      height: getProportionateScreenWidth(14),
                      width: getProportionateScreenWidth(14),
                      color: Colors.black,
                    )
                  )
                ],
              ),
              Text(
                DateFormat('MMM d, yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.w600
                )
              )
            ],
          )
        ]
      ),
    );
  }
}

class GreetingsMessage extends StatelessWidget {

  const GreetingsMessage({Key key}) : super(key: key);

  bool compareDateTime(x, y) { // x & y is in Hms format
    return DateTime.now().isAfterTime(DateTime.parse(DateFormat('Hms', 'en_US').parse(x).toString())) && DateTime.now().isBeforeTime(DateTime.parse(DateFormat('Hms', 'en_US').parse(y).toString()));

  }

  @override
  Widget build(BuildContext context) {
    // compareDateTime();
    String message = "";
    if(compareDateTime('06:00:00', '12:00:00')) {
      message = "Good Morning";
    }else if(compareDateTime('11:59:00', '18:00:00')) {
      message = "Good Afternoon";
    }else if(compareDateTime('17:59:00', '06:00:00')) {
      message = "Good Evening";
    }
    return Text(
      "$message, ${User().name}",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 17
      )
    );
  }
}

class NotificationModal extends StatefulWidget  {
  NotificationModal({Key key}) : super(key: key);

   @override
  _NotificationModal createState() => _NotificationModal();
}

class _NotificationModal extends State<NotificationModal> {
  // List<nt.Notification> notifications = [];

  @override
  void initState() {
    super.initState();
    // notifications = nt.Notifications().notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: SizeConfig.screenHeight * 0.8,
          child: nt.Notifications().notifications.length > 0 ? ListView(
            shrinkWrap: true,
            children: [
              for(var item in nt.Notifications().notifications)
                Slidable(
                  actionPane: SlidableStrechActionPane(),
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        item.photoURL != null ?
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: new Image.network('${globals.baseImageUrl}${item.photoURL}',
                              height: 35.0,
                              fit: BoxFit.fill,
                            )
                          )
                        :
                          Container(
                            child: CircleAvatar(
                              child: Center(
                                child:SvgPicture.asset(
                                  "assets/icons/User.svg",
                                  height: getProportionateScreenWidth(12),
                                  width: getProportionateScreenWidth(12),
                                  color: Colors.white,
                                )
                              ),
                              radius: 17.5,
                              backgroundColor: Colors.transparent,
                            ),
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              gradient: new LinearGradient(
                                colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
                              )
                            ),
                          ),

                        Padding(padding: EdgeInsets.all(5)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              Text(item.message)
                            ]
                          )
                        )
                      ]
                    )
                  ),
                  secondaryActions: [
                    IconSlideAction(
                      caption: 'Remove',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        // var _ = removeNotification(context, globals.user.token, notifications[index].id);
                        setState(() {
                          nt.Notifications().notifications.removeAt(nt.Notifications().notifications.indexOf(item));
                        });
                      },
                    ),
                  ]
                )
            ],
          ) : 
          Center(
            child: Text("No Notifications"),
          )
        ),
      )
    );
  }
}

class ModalInsideModal extends StatelessWidget {
  final bool reverse;

  const ModalInsideModal({Key key, this.reverse = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        bottom: false,
        child: new NotificationListener(
          onNotification: (t) {
            if (t is ScrollStartNotification) {
              FocusScope.of(context).unfocus();
            }
            return null;
          },
          child: ListView(
            reverse: reverse,
            shrinkWrap: true,
            controller: ModalScrollController.of(context),
            physics: ClampingScrollPhysics(),
            children: ListTile.divideTiles(
                context: context,
                tiles: List.generate(
                  100,
                  (index) => ListTile(
                    title: Text('Item $index'),
                  ),
                )).toList(),
          )
        ),
      )
    );
  }
}