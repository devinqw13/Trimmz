import 'package:flutter/material.dart';
import 'package:trimmz/Model/SuggestedBarbers.dart';
import '../Model/ClientBarbers.dart';
import '../globals.dart' as globals;
import 'BookingController.dart';
import 'package:line_icons/line_icons.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import '../calls.dart';

class SelectBarberScreen extends StatefulWidget {
  final List<ClientBarbers> clientBarbers;
  SelectBarberScreen({Key key, this.clientBarbers}) : super (key: key);

  @override
  SelectBarberScreenState createState() => new SelectBarberScreenState();
}

class SelectBarberScreenState extends State<SelectBarberScreen> {
  TextEditingController _search = new TextEditingController();
  StreamController<String> searchStreamController = StreamController();
  List<ClientBarbers> clientBarbers = [];
  List<SuggestedBarbers> searchBarbers = [];

  @override
  void initState() {
    super.initState();
    clientBarbers = widget.clientBarbers;

    searchStreamController.stream
    .debounce(Duration(milliseconds: 100))
    .listen((s) => _searchValue(s));
  }

  _searchValue(String string) async {
    if(_search.text.length > 2) {
      var res = await getSearchBarbers(context, _search.text);
      setState(() {
        searchBarbers = res;
      });
    }
    if(_search.text.length <= 2) {
      setState(() {
        searchBarbers = [];
      });
    }
  }

  Widget _buildGridTile(var barber, int index, double scale) {
    return new GestureDetector(
      onTap: () {},
      child: Container(
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
                      Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: new LinearGradient(
                            colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
                          )
                        ),
                        child: Center(child:Text(barber.name.substring(0,1), style: TextStyle(fontSize: 30))),
                      ),
                      Text(
                        barber.name,
                        style: TextStyle(
                          fontSize: 20
                        ),
                      )
                    ],
                  ),
                ),
                decoration: new BoxDecoration(
                  color: Color.fromARGB(255, 21, 21, 21),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(2.0), topRight: Radius.circular(2.0))
                ),
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Container(
                padding: const EdgeInsets.all(0.0),
                child: new Center(
                  child: new FlatButton(
                    onPressed: () async {
                      bool res = await addBarber(context, globals.token, int.parse(barber.id));
                      if(res) {
                        if(barber is SuggestedBarbers) {
                          ClientBarbers newBarber = new ClientBarbers();
                          newBarber.id = barber.id;
                          newBarber.name = barber.name;
                          newBarber.phone = barber.phone;
                          newBarber.rating = barber.rating;
                          newBarber.shopAddress = barber.shopAddress;
                          newBarber.shopName = barber.shopName;
                          newBarber.state = barber.state;
                          newBarber.username = barber.username;
                          newBarber.zipcode = barber.zipcode;
                          newBarber.email = barber.email;
                          newBarber.city = barber.city;

                          final bookingScreen = new BookingController(barberInfo: newBarber); 
                          Navigator.push(context, new MaterialPageRoute(builder: (context) => bookingScreen));
                        }else {
                          final bookingScreen = new BookingController(barberInfo: barber); 
                          Navigator.push(context, new MaterialPageRoute(builder: (context) => bookingScreen));
                        }
                      }
                    },
                    child: Text('Book Appointment', 
                      style: TextStyle(
                        color: Colors.black
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
      )
    );
  }

  buildBarberList(List<ClientBarbers> barbers) {
    if(clientBarbers.length > 0) {
      return new GridView.builder(
        itemCount: barbers.length,
        padding: EdgeInsets.all(2),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15.0,
          crossAxisSpacing: 15.0,
          childAspectRatio: 0.9
        ),
        itemBuilder: (context, index) {
          return new Card(
            child: _buildGridTile(barbers[index], index, 1.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0))
            ),
          );
        },
      );
    }else {
      if(searchBarbers.length > 0) {
        return new GridView.builder(
          itemCount: searchBarbers.length,
          padding: EdgeInsets.all(2),
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0,
            childAspectRatio: 0.9
          ),
          itemBuilder: (context, index) {
            if(searchBarbers[index].id != globals.token.toString()) {
              return new Card(
                child: _buildGridTile(searchBarbers[index], index, 1.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0))
                ),
              );
            }else {
              return Container();
            }
          },
        );
      }else {
        return new Container(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [
                      Icon(LineIcons.search, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
                      Text(
                        'Search a barber to book an apppointment.',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * .018,
                          color: Colors.grey[600]
                        )
                      ),
                    ]
                  )
                )
              ),
            ]
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: globals.userColor,
        brightness: globals.userBrightness,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Select Barber"),
          bottom: clientBarbers.length > 0 ? PreferredSize(preferredSize: const Size.fromHeight(0.0), child: Container()) : PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * .045),
            child: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.white),
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                height: MediaQuery.of(context).size.height * .045,
                alignment: Alignment.center,
                child: TextField(
                  autofocus: false,
                  controller: _search,
                  onChanged: (val) {
                    searchStreamController.add(val);
                  },
                  autocorrect: false,
                  textInputAction: TextInputAction.done, 
                  decoration: new InputDecoration(
                    prefixIcon: Icon(LineIcons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.all(8.0),
                    hintText: 'Search',
                    fillColor: globals.darkModeEnabled ? Colors.grey[900] : Colors.grey[100],
                    filled: true,
                    hintStyle: TextStyle(
                      color: Colors.grey
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: new Stack(
          children: <Widget>[
            buildBarberList(clientBarbers)
          ]
        )
      )
    );
  }
}