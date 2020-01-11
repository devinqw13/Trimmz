import 'package:flutter/material.dart';
import '../Model/ClientBarbers.dart';
import '../globals.dart' as globals;
import 'Booking.dart';

class SelectBarberScreen extends StatefulWidget {
  final List<ClientBarbers> clientBarbers;
  SelectBarberScreen({Key key, this.clientBarbers}) : super (key: key);

  @override
  SelectBarberScreenState createState() => new SelectBarberScreenState();
}

class SelectBarberScreenState extends State<SelectBarberScreen> {
  List<ClientBarbers> clientBarbers = [];

  @override
  void initState() {
    super.initState();

    clientBarbers = widget.clientBarbers;
  }

  Widget _buildGridTile(ClientBarbers barber, int index, double scale) {
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
                  color: Colors.grey[900],
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
                    onPressed: () {
                      final bookingScreen = new BookingScreen(barberInfo: barber); 
                      Navigator.push(context, new MaterialPageRoute(builder: (context) => bookingScreen));
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
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: Text("Select Barber"),
        ),
        body: new Container(
          width: MediaQuery.of(context).size.width,
          child: buildBarberList(clientBarbers)
        ),
      )
    );
  }
}