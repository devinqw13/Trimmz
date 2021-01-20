import 'package:flutter/material.dart';
import 'package:trimmz/RippleButton.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/dialogs.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/Model/Service.dart';
import 'package:trimmz/Model/WidgetStatus.dart';
import 'dart:ui' as ui;
import 'package:line_icons/line_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ServicesController extends StatefulWidget {
  final List<Service> services;
  final screenHeight;
  ServicesController({Key key, this.services, this.screenHeight}) : super (key: key);

  @override
  ServicesControllerState createState() => new ServicesControllerState();
}

class ServicesControllerState extends State<ServicesController> with TickerProviderStateMixin {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List<Service> services = [];
  WidgetStatus _addWidgetStatus = WidgetStatus.HIDDEN;
  AnimationController addAnimationController, opacityAnimationController;
  Animation addPositionAnimation, addOpacityAnimation;
  final duration = new Duration(milliseconds: 200);
  bool addActive = true;
  final TextEditingController nameTFController = new TextEditingController();
  final TextEditingController durationTFController = new TextEditingController();
  final TextEditingController priceTFController = new TextEditingController();
  bool isEditing = false;
  Service editingService;

  @override
  void initState() {
    services = widget.services;

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    addAnimationController = new AnimationController(duration: duration, vsync: this);
    opacityAnimationController = new AnimationController(duration: duration, vsync: this);
    addPositionAnimation = new Tween(begin: 0.0, end: widget.screenHeight).animate(
      new CurvedAnimation(parent: addAnimationController, curve: Curves.easeInOut)
    );
    addOpacityAnimation = new Tween(begin: 0.0, end: 1.0).animate(
      new CurvedAnimation(parent: opacityAnimationController, curve: Curves.easeInOut)
    );
    addPositionAnimation.addListener(() {
      setState(() {});
    });
    addOpacityAnimation.addListener(() {
      setState(() {});
    });
    addAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (addActive) {
          _addWidgetStatus = WidgetStatus.VISIBLE;
        } else {
          _addWidgetStatus = WidgetStatus.HIDDEN;
        }
      }
    });

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

  doEditService(Service service) {
    setState(() {
      editingService = service;
      isEditing = true;
    });
    onTapDownAdd();
  }

  deleteServiceAction(int id) async {
    progressHUD();
    var result = await deleteService(context, globals.user.token, id);
    if(result['results'] == "true") {
      setState(() {
        services.removeWhere((element) => element.id == result['serviceId']);
      });
      progressHUD();
      return;
    }
    progressHUD();
    showErrorDialog(context, "An error has occurred", "Service was not able to be removed. Please try again!");
  }

  Widget _buildScreen() {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.only(left: 10),
      child: services.length > 0 ? ListView.builder(
        shrinkWrap: true,
        itemCount: services.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => doEditService(services[index]),
            child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(left: 10, right: 10),
                margin: EdgeInsets.only(top: 15, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          services[index].name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        Text(
                          "${services[index].duration} minutes",
                          style: TextStyle(
                            color: textGrey
                          ),
                        )
                      ]
                    ),
                    Text(
                      "\$${services[index].price}"
                    )
                  ]
                )
              ),
              secondaryActions: [
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () => deleteServiceAction(services[index].id),
                ),
              ]
            )
          );
        },
      ):
      Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: "No Services",
                style: TextStyle(
                  color: globals.darkModeEnabled ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0
                )
              ),
              TextSpan(
                text: "\nPress + to add a service",
                style: TextStyle(
                  color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                  fontWeight: FontWeight.normal,
                  fontSize: 15.0
                )
              )
            ]
          ),
        )
      ),
    );
  }

  void onTapDownAdd() {
    nameTFController.clear();
    durationTFController.clear();
    priceTFController.clear();
    if (_addWidgetStatus == WidgetStatus.HIDDEN) {
      addAnimationController.forward(from: 0.0);
      opacityAnimationController.forward(from: 0.0);
      _addWidgetStatus = WidgetStatus.VISIBLE;
    }
    else if (_addWidgetStatus == WidgetStatus.VISIBLE) {
      addAnimationController.reverse(from: 400.0);
      opacityAnimationController.reverse(from: 1.0);
      _addWidgetStatus = WidgetStatus.HIDDEN;
    }
  }

  Widget _buildNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Service Name',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(110, 0, 0, 0),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: nameTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                LineIcons.pencil_square_o,
                color: Colors.white,
              ),
              hintText: isEditing ? '${editingService.name}' : 'Enter your service name',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              )
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Service Duration ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
              ),
              TextSpan(
                text: "(Minutes)",
                style: TextStyle(
                  color: textGrey,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'OpenSans',
                )
              )
            ]
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(110, 0, 0, 0),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: durationTFController,
            keyboardType: TextInputType.number,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                LineIcons.clock_o,
                color: Colors.white,
              ),
              hintText: isEditing ? '${editingService.duration}' : 'Enter your service duration',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              )
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Service Price',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(110, 0, 0, 0),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: priceTFController,
            keyboardType: TextInputType.number,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                LineIcons.dollar,
                color: Colors.white,
              ),
              hintText: isEditing ? '${editingService.price}' : 'Enter your service price',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              )
            ),
          ),
        ),
      ],
    );
  }

  buildAddBody() {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildNameTF(),
                  Padding(padding: EdgeInsets.all(2)),
                  _buildDurationTF(),
                  Padding(padding: EdgeInsets.all(2)),
                  _buildPriceTF()
                ]
              )
            ),
          ),
        ]
      )
    );
  }

  handleServiceSubmit(String name, int duration, int price) async {
    progressHUD();
    var result = await addService(context, globals.user.token, name, price, duration);
    setState(() {
      services.add(result);
    });
    onTapDownAdd();
    progressHUD();
  }

  handleSubmitError() {
    List<String> errorMessages = [];
    if(nameTFController.text == "") {
      errorMessages.add("Enter a service name");
    }
    if(durationTFController.text == "") {
      errorMessages.add("Enter a service duration");
    }
    if(priceTFController.text == "") {
      errorMessages.add("Enter a service price");
    }
    showMultipleErrorDialog(context, "Missing Information", errorMessages, other: "There is missing information that is needed:");
  }

  addHandler() {
    if(nameTFController.text != "" && durationTFController.text != "" && priceTFController.text != "") {
      handleServiceSubmit(nameTFController.text, int.parse(durationTFController.text), int.parse(priceTFController.text));
    }else {
      handleSubmitError();
    }
  }

  editHandler() async {
    String name;
    int price;
    int duration;
    if(nameTFController.text != "") name = nameTFController.text;
    if(priceTFController.text != "") price = int.parse(priceTFController.text);
    if(durationTFController.text != "") duration = int.parse(durationTFController.text);

    progressHUD();
    var results = await editService(context, globals.user.token, editingService.id, name: name, price: price, duration: duration);
    progressHUD();

    if(results['results'].length > 0) {
      for(var item in results['results']) {
        if(item['type'] == 'name') setState(() {editingService.name =  item['name'];});
        if(item['type'] == 'price') setState(() {editingService.price =  int.parse(item['price']);});
        if(item['type'] == 'duration') setState(() {editingService.duration =  int.parse(item['duration']);});
      }
    }
    if(results['errors'].length > 0) {
      List<String> errorMessages = [];
      for(var item in results['errors']) {
        if(item['type'] == 'name') errorMessages.add("The service name was not updated");
        if(item['type'] == 'price') errorMessages.add("The service price was not updated");
        if(item['type'] == 'duration') errorMessages.add("The service duration was not updated");
      }
      showMultipleErrorDialog(context, "Missing Information", errorMessages, other: "Some information was not able to update:");
    }

    nameTFController.clear();
    priceTFController.clear();
    durationTFController.clear();

    setState(() {
      isEditing = false;
      editingService = null;
    });
    onTapDownAdd();
  }

  Widget getAddOverlay() {
    var searchHeight = 0.0;
    var searchOpacity = 0.0;
    switch(_addWidgetStatus) {
      case WidgetStatus.HIDDEN:
        searchHeight = addPositionAnimation.value;
        searchOpacity = addOpacityAnimation.value;
        addActive = false;
        break;
      case WidgetStatus.VISIBLE:
        searchHeight = addPositionAnimation.value;
        searchOpacity = addOpacityAnimation.value;
        addActive = true;
        break;
    }
    return new BackdropFilter(
      filter: new ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
      child: Container(
        padding: EdgeInsets.only(bottom: 25, left: 10, right: 10),
        width: MediaQuery.of(context).size.width,
        height: searchHeight,
        child: new Opacity(
          opacity: searchOpacity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: buildAddBody()
              ),
              Row(
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
                          FocusScope.of(context).unfocus();
                          if(isEditing) {
                            editHandler();
                          }else {
                            addHandler();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                          child: Center(
                            child: Text(
                              isEditing ? "Save Service" : "Add Service",
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
              )
            ],
          )
        ),
        color: const Color.fromARGB(120, 0, 0, 0),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: new Scaffold(
        backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Services",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          actions: [
            _addWidgetStatus != WidgetStatus.VISIBLE ? IconButton(
              icon: Icon(Icons.add),
              onPressed: () => onTapDownAdd(),
            ):
            FlatButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if(isEditing) {
                  setState(() {
                    isEditing = false;
                    editingService = null;
                  });
                }
                onTapDownAdd();
              },
              child: Text("Cancel")
            )
          ],
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
                  getAddOverlay(),
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