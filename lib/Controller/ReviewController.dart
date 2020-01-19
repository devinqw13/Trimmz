import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../Model/Reviews.dart';
import 'package:line_icons/line_icons.dart';

class ReviewController extends StatefulWidget {
  final int userId;
  final String username;
  ReviewController({Key key, this.userId, this.username}) : super (key: key);

  @override
  ReviewControllerState createState() => new ReviewControllerState();
}

class ReviewControllerState extends State<ReviewController> {
  bool canReview = false;
  List<BarberReviews> reviews = [];


  void initState() {
    super.initState();

    initCalls();
  }

  initCalls() {
    if(widget.userId == globals.token){
      //TODO: call to check if user had an appointment w/ barber then set canReview
    }else {
      //TODO: call to get all reviews
    }
  }

  createReview() {
    if(canReview){
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment(0.0, -2.0),
            colors: [Colors.black, Color.fromRGBO(45, 45, 45, 1)]
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
          
          ]
        )
      );
    }else {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment(0.0, -2.0),
            colors: [Colors.black, Color.fromRGBO(45, 45, 45, 1)]
          )
        ),
        child: Center(
          child: Text(
            'Must complete an appointment to review barber',
            style: TextStyle(
              fontStyle: FontStyle.italic
            )
          )
        )
      );
    }
  }

  buildReviews() {
    if(reviews.length > 0) {
      return ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, i) {
          return Container(
            child: Text(reviews[i].id.toString())
          );
        },
      );
    }else {
      return Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
              Text(
                'This barber doesn\'t have any reviews.',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * .018,
                  color: Colors.grey[600]
                )
              ),
            ]
          )
        )
      );
    }
  }

  userReviews() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: [Colors.black, Color.fromRGBO(45, 45, 45, 1)]
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            text: new TextSpan(
              children: <TextSpan>[
                new TextSpan(text: 'Reviews ', style: new TextStyle(fontWeight: FontWeight.bold)),
                new TextSpan(text: '(0)'),
              ],
            ),
          ),
          buildReviews()
        ]
      )
    );
  }

  buildBody() {
    return new Container(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  widget.userId != globals.token ? createReview() : Container(),
                  userReviews()
                ],
              ),
            )
          ),
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
        backgroundColor: Colors.black,
        appBar: new AppBar(
          title: new Text('@${widget.username}\'s Reviews')
        ),
        body: new Stack(
          children: <Widget> [
            buildBody()
          ]
        )
      )
    );
  }
}