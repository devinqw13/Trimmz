import 'package:flutter/material.dart';
import 'package:trimmz/View/Widgets.dart';
import '../globals.dart' as globals;
import '../Model/Reviews.dart';
import 'package:line_icons/line_icons.dart';
import '../Calls/GeneralCalls.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';

class ReviewController extends StatefulWidget {
  final int userId;
  final String username;
  ReviewController({Key key, this.userId, this.username}) : super (key: key);

  @override
  ReviewControllerState createState() => new ReviewControllerState();
}

class ReviewControllerState extends State<ReviewController> {
  final TextEditingController _commentController = new TextEditingController();
  StreamController<String> commentStreamController = StreamController();
  bool canReview = false;
  List<BarberReviews> reviews = [];
  double rating = 1;
  bool showSubmit = false;


  void initState() {
    super.initState();

    commentStreamController.stream
    .debounce(Duration(milliseconds: 0))
    .listen((s) => _setChanges());

    initCalls();
  }

  _setChanges() async {
    if(_commentController.text.length > 0) {
      setState(() {
        showSubmit = true;
      });
    }else if(_commentController.text.length == 0) {
      setState(() {
        showSubmit = false;
      });
    }
  }

  initCalls() async {
    if(widget.userId != globals.token) {
      var res1 = await getNumUserReviews(context, globals.token, widget.userId);
      if(res1 > 0) {
        setState(() {
          canReview = true;
        });
      }
    }
    var res = await getUserReviews(context, widget.userId);
    setState(() {
      reviews = res;
    });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Select Rating', style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(5)),
            RatingBar(
              initialRating: rating,
              itemSize: 24,
              itemCount: 5,
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Color(0xFFD2AC47),
              ),
              onRatingUpdate: (rate) {
                setState(() {
                  rating = rate;
                });
              },
            ),
            Padding(padding: EdgeInsets.all(5)),
            Text('Comment', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    onChanged: (val) {
                      commentStreamController.add(val);
                    },
                    autocorrect: false,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Comment'
                    ),
                  )
                )
              ]
            ),
            showSubmit ? Row(
              children: <Widget>[
                Expanded(
                  child: new GestureDetector(
                    onTap: () async {
                      var res = await submitReview(context, _commentController.text, widget.userId, globals.token, rating);
                      if(res) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        var res = await getUserReviews(context, widget.userId);
                        setState(() {
                          _commentController.text = '';
                          showSubmit = false;
                          rating = 1;
                          reviews = res;
                        });
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 35.0, minWidth: 200.0, minHeight: 35.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        gradient: new LinearGradient(
                          colors: globals.darkModeEnabled ? [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent] : [Color.fromARGB(255, 54, 121, 255), Colors.lightBlueAccent],
                        )
                      ),
                      child: Center(
                        child: Text(
                          'Submit',
                          style: new TextStyle(
                            fontSize: 19.0,
                            fontWeight: FontWeight.w300
                          )
                        )
                      )
                    )
                  )
                )
              ]
            ) : Container(),
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
        padding: EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        itemCount: reviews.length,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return Container(
            padding: EdgeInsets.only(left: 0, top:10, bottom: 10, right: 0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        buildProfilePictures(context, reviews[i].clientProfilePicture, reviews[i].clientName, 25),
                        Padding(padding: EdgeInsets.all(5)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(reviews[i].clientName, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              DateFormat('EEEE, MMMM d, y').format(DateTime.parse(reviews[i].created.toString())),
                              style: TextStyle(
                                color: Colors.grey
                              )
                            ),
                            Container(width: MediaQuery.of(context).size.width * .55, child: AutoSizeText.rich(TextSpan(text: reviews[i].comment), maxFontSize:16, minFontSize: 13, maxLines: null))
                          ]
                        )
                      ]
                    ),
                    RatingBarIndicator(
                      rating: reviews[i].rating,
                      itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Color(0xFFD2AC47),
                      ),
                      itemCount: 5,
                      itemSize: 17.0,
                      direction: Axis.horizontal,
                      unratedColor: Colors.white70,
                    ),
                  ]
                )
              ]
            )
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
          begin: Alignment(0.0, -5.0),
          colors: globals.darkModeEnabled ? [Colors.black, Color.fromRGBO(45, 45, 45, 1)] : [Colors.grey[500], Colors.grey[50]]
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            text: new TextSpan(
              style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
              children: <TextSpan>[
                new TextSpan(text: 'Reviews ', style: new TextStyle(fontWeight: FontWeight.bold)),
                new TextSpan(text: '(${reviews.length.toString()})'),
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
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          centerTitle: true,
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