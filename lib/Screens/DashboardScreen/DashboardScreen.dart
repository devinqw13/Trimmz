import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:trimmz/SizeConfig.dart';
import 'package:trimmz/Constants.dart';
import 'package:trimmz/Calls.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trimmz/Screens/DashboardScreen/Components/AccountBody.dart';
import 'package:trimmz/Screens/DashboardScreen/Components/HomeBody.dart';
import 'package:trimmz/Screens/DashboardScreen/Components/AppointmentsBody.dart';
import 'package:trimmz/Screens/DashboardScreen/Components/MessagesBody.dart';
import 'package:trimmz/Screens/DashboardScreen/Components/GalleryBody.dart';
import 'package:trimmz/Model/User.dart';
import 'package:trimmz/Model/Notification.dart' as nt;

class DashboardScreen extends StatefulWidget {
  DashboardScreen();

  @override
  _DashboardScreen createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _loadingInProgress = false;
  TabController _tabController;
  

  @override
  void initState() {
    super.initState();

    _initializeAsyncDependencies();

    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  _initializeAsyncDependencies() async {
    await getNotifications(context, User().userKey);
    await getUserInfo(User().userKey, context);
  }

  void dismissProgressHUD() {
    setState(() {
      _loadingInProgress = !_loadingInProgress;
    });
  }

  Widget buildHomePage() {
    return Stack(
      children: [
        HomeBody(
          dismissProgressHUD: dismissProgressHUD,
        ),
        // _loadingInProgress ? 
        // SpinKitWave(
        //   type: SpinKitWaveType.center,
        //   size: 40,
        //   color: primaryOrange
        // ) : Container()
      ],
    );
  }

  Widget buildAppointmentsPage() {
    return Stack(
      children: [
        AppointmentsBody(
          dismissProgressHUD: dismissProgressHUD,
        ),
        // _loadingInProgress ? 
        // SpinKitWave(
        //   type: SpinKitWaveType.center,
        //   size: 40,
        //   color: primaryOrange
        // ) : Container()
      ],
    );
  }

  Widget buildGalleryPage() {
    return Stack(
      children: [
        GalleryBody(
          dismissProgressHUD: dismissProgressHUD,
        ),
        // _loadingInProgress ? 
        // SpinKitWave(
        //   type: SpinKitWaveType.center,
        //   size: 40,
        //   color: primaryOrange
        // ) : Container()
      ],
    );
  }

  Widget buildMessagesPage() {
    return Stack(
      children: [
        MessagesBody(
          dismissProgressHUD: dismissProgressHUD,
        ),
        // _loadingInProgress ? 
        // SpinKitWave(
        //   type: SpinKitWaveType.center,
        //   size: 40,
        //   color: primaryOrange
        // ) : Container()
      ],
    );
  }

  Widget buildAccountPage() {
    return Stack(
      children: [
        AccountBody(
          dismissProgressHUD: dismissProgressHUD,
        ),
        // _loadingInProgress ? 
        // SpinKitWave(
        //   type: SpinKitWaveType.center,
        //   size: 40,
        //   color: primaryOrange
        // ) : Container()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: new WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: SafeArea(
              child: AbsorbPointer(
                absorbing: _loadingInProgress,
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    buildHomePage(),
                    buildAppointmentsPage(),
                    buildGalleryPage(),
                    buildMessagesPage(),
                    buildAccountPage()
                  ],
                ),
              )
            )
          )
        )
      ),
      bottomNavigationBar: Container(
        color: lightBackgroundBlue,
        child: SafeArea(
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(15)
            ),
            controller: _tabController,
            tabs: [
              Container(
                width: 100.0,
                  child: Tab(
                  icon: SvgPicture.asset(
                    "assets/icons/Home.svg",
                    height: getProportionateScreenWidth(18),
                    width: getProportionateScreenWidth(18),
                    color: _currentIndex == 0 ? Colors.white : Colors.black
                  ),
                )
              ),
              Container(
                width: 100.0,
                  child: Tab(
                  icon: SvgPicture.asset(
                    "assets/icons/Calendar.svg",
                    height: getProportionateScreenWidth(18),
                    width: getProportionateScreenWidth(18),
                    color: _currentIndex == 1 ? Colors.white : Colors.black
                  ),
                )
              ),
              Container(
                width: 100.0,
                  child: Tab(
                  icon: SvgPicture.asset(
                    "assets/icons/Gallery.svg",
                    height: getProportionateScreenWidth(21),
                    width: getProportionateScreenWidth(21),
                    color: _currentIndex == 2 ? Colors.white : Colors.black
                  ),
                )
              ),
              Container(
                width: 100.0,
                  child: Tab(
                  icon: SvgPicture.asset(
                    "assets/icons/Message.svg",
                    height: getProportionateScreenWidth(18),
                    width: getProportionateScreenWidth(18),
                    color: _currentIndex == 3 ? Colors.white : Colors.black
                  ),
                )
              ),
              Container(
                width: 100.0,
                  child: Tab(
                  icon: SvgPicture.asset(
                    "assets/icons/User.svg",
                    height: getProportionateScreenWidth(18),
                    width: getProportionateScreenWidth(18),
                    color: _currentIndex == 4 ? Colors.white : Colors.black
                  ),
                )
              ),
            ],
          ),
        )
      )
    );
  }
}