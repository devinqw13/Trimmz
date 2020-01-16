import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../calls.dart';
import '../dialogs.dart';
import '../Model/Packages.dart';
import '../Model/AppointmentRequests.dart';
import 'package:intl/intl.dart';
import '../View/BarberAppointmentOptions.dart';

addBarberPackage(BuildContext context, String name, double price, int duration) async {
  if(name == "" || price.toString() == "" || duration.toString() == "") {
    showErrorDialog(context, "Field Left Empty", "A field was left empty. Please enter all fields required.");
    return false;
  }else {
    var res = await addPackage(context, globals.token, name, duration, price);
    return res;
  }
}

Future<List<Packages>> showAddPackageModalSheet(BuildContext context) async {
  final TextEditingController _pkgName = new TextEditingController();
  final TextEditingController _pkgPrice = new TextEditingController();
  final TextEditingController _pkgDuration = new TextEditingController();
  List<Packages> results; 
  await showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 335,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 21, 21, 21),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2, color: Colors.grey[400], spreadRadius: 0)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'New Package',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.blue
                    )
                  )
                ),
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 18.0
                  )
                ),
                TextField(
                  controller: _pkgName,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  style: new TextStyle(
                    fontSize: 18.0,
                    color: Colors.white
                  ),
                  decoration: new InputDecoration(
                    hintText: 'Enter package name',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                        color: Colors.white
                      )
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)
                    )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                ),
                Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 18.0
                  )
                ),
                TextField(
                  controller: _pkgPrice,
                  keyboardType: TextInputType.number,
                  autocorrect: false,
                  style: new TextStyle(
                    fontSize: 18.0,
                    color: Colors.white
                  ),
                  decoration: new InputDecoration(
                    hintText: 'Enter price',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                        color: Colors.white
                      )
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)
                    )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                ),
                Text(
                  'Duration (Mins)',
                  style: TextStyle(
                    fontSize: 18.0
                  )
                ),
                TextField(
                  controller: _pkgDuration,
                  keyboardType: TextInputType.number,
                  autocorrect: false,
                  style: new TextStyle(
                    fontSize: 18.0,
                    color: Colors.white
                  ),
                  decoration: new InputDecoration(
                    hintText: 'Enter Duration',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                        color: Colors.white
                      )
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)
                    )
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RaisedButton(
                      onPressed: () async {
                        var res = await addBarberPackage(context, _pkgName.text, double.parse(_pkgPrice.text), int.parse(_pkgDuration.text));
                        if(res) {
                          var res = await getBarberPkgs(context, globals.token);
                          Navigator.pop(context);
                          results = res;
                        }else {
                          return;
                        }
                      },
                      child: Text('Add Package')
                    ),
                  ),
                ),
              ],
            ),
          ]
        ),
      )
    );
  });
  return results;
}

Future<List<Packages>> showPackageOptionsModalSheet(BuildContext context, String name, String price, String duration, String packageid) async {
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController priceController = new TextEditingController();
  final TextEditingController durationController = new TextEditingController();
  List<Packages> results;
  await showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 355,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 21, 21, 21),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2, color: Colors.grey[400], spreadRadius: 0)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('Name'),
                new TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: name,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)
                    )
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
                new Text('Price'),
                new TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    hintText: price,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)
                    )
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
                new Text('Duration (mins)'),
                new TextField(
                  controller: durationController,
                  decoration: InputDecoration(
                    hintText: duration,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)
                    )
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
                new Center (
                  child: GestureDetector(
                    onTap: () async {
                      bool res = await removePackage(context, globals.token, int.parse(packageid));
                      if(res) {
                        var res = await getBarberPkgs(context, globals.token);
                        Navigator.pop(context);
                        results = res;
                      }else {
                        return;
                      }
                    },
                    child: Text('Remove Package', style: TextStyle(color: Colors.red))
                  )
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
              ],
            ),
            Center(
              child: FlatButton(
                color: Colors.blue,
                onPressed: () async {
                  if(nameController.text != '' || priceController.text != '' || durationController.text != ''){
                    var res = await updatePackage(context, globals.token, int.parse(packageid), nameController.text != '' ? nameController.text : null, priceController.text != '' ? int.parse(priceController.text) : null, durationController.text != '' ? int.parse(durationController.text) : null);
                    if(res) {
                      var res = await getBarberPkgs(context, globals.token);
                      Navigator.pop(context);
                      results = res;
                    }else {
                      return;
                    }
                  }else {
                    Navigator.pop(context);
                  }
                },
                child: Text('Update Package')
              )
            )
          ]
        ),
      )
    );
  });
  return results;
}

Future<int> showAptRequestsModalSheet(BuildContext context, List<AppointmentRequest> requests) async {
  int results;
  await showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 355,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.grey[400],
              spreadRadius: 0
            )
          ]
        ),
        child: Stack(
          children: <Widget> [
            Container(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      //physics: NeverScrollableScrollPhysics(),
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          final df = new DateFormat('EEE, MMM d hh:mm a');
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget> [
                                Row(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          requests[i].clientName,
                                          style: TextStyle(
                                            fontSize: 20.0
                                          ),
                                        ),
                                        Text(df.format(DateTime.parse(requests[i].dateTime.toString()))),
                                        Text(requests[i].packageName),
                                      ]
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5)
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                        child: Text(
                                          '\$' + requests[i].price.toString(),
                                          textAlign: TextAlign.center,
                                        )
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        shape: BoxShape.circle
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () async {
                                        var result = await aptRequestDecision(context, globals.token, requests[i].requestId, 0);
                                        Navigator.pop(context);
                                        results = result;
                                      },
                                      child: Text('Decline', style: TextStyle(color: Colors.red)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        var result = await aptRequestDecision(context, globals.token, requests[i].requestId, 1);
                                        Navigator.pop(context);
                                        results = result;
                                      },
                                      child: Text('Accept', style: TextStyle(color: Colors.blue)),
                                    ),
                                  ]
                                )
                              ]
                            ),
                          );
                        },
                      )
                    )
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RaisedButton(
                            onPressed: () {

                            },
                            child: Text('Close')
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ]
        )
      )
    );
  });
  return results;
}

showAptCancelOptionModalSheet(BuildContext context, var appointment) async {
  var appointments;
  await showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 355,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.grey[400],
              spreadRadius: 0
            )
          ]
        ),
        child: Stack(
          children: <Widget> [
            Container(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            onPressed: () async {
                              var res1 = await updateAppointmentStatus(context, int.parse(appointment['id']), 2);
                              if(res1) {
                                var res2 = await getBarberAppointments(context, globals.token);
                                appointments = res2;
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Cancel with payment'),
                          )
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            onPressed: () {

                            },
                            child: Text('Cancel without payment'),
                          )
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
                                return AppointmentOptionsBottomSheet(
                                  appointment: appointment,
                                  getAppointments: (value) {

                                  },
                                  showCancel: (val) async {
                                    if(val){
                                      var res = await showAptCancelOptionModalSheet(context, appointment);
                                      if(res != null) {
                                        appointments = res;
                                      }
                                    }
                                  },
                                );
                              });
                            },
                            child: Text('Close')
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ]
        )
      )
    );
  });
  return appointments;
}

showPayoutInfoModalSheet(BuildContext context) async {
  showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 255,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.grey[400],
              spreadRadius: 0
            )
          ]
        ),
        child: Stack(
          children: <Widget> [
            Container(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: RichText(
                            softWrap: true,
                            text: new TextSpan(
                              children: <TextSpan>[
                                new TextSpan(text: 'Standard Transfer: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: 'The standard transfer fee is 2.5% of the appointment amount. Standard transfer usually takes about 1-3 business days to deposit.'),
                              ],
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10),),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: RichText(
                            softWrap: true,
                            text: new TextSpan(
                              children: <TextSpan>[
                                new TextSpan(text: 'Instant Transfer: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: 'The instant transfer fee is 3% of the appointment amount.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close')
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ]
        )
      )
    );
  });
}