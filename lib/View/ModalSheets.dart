import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../calls.dart';
import '../dialogs.dart';
import '../Model/Packages.dart';
import '../Model/AppointmentRequests.dart';
import 'package:intl/intl.dart';

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
            color: Colors.grey[900],
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2, color: Colors.grey[300], spreadRadius: 0)
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
            color: Colors.grey[900],
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2, color: Colors.grey[300], spreadRadius: 0)
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
                    hintText: name
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
                new Text('Price'),
                new TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    hintText: price
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
                new Text('Duration (mins)'),
                new TextField(
                  controller: durationController,
                  decoration: InputDecoration(
                    hintText: duration
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
                  // var res = await addBarberPackage(context, _pkgName.text, double.parse(_pkgPrice.text), int.parse(_pkgDuration.text));
                  // if(res) {
                  //   var res = await getBarberPkgs(context, globals.token);
                  //   Navigator.pop(context);
                  //   results = res;
                  // }else {
                  //   return;
                  // }
                },
                child: Text('Add Package')
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
          color: Colors.grey[900],
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.grey[300],
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

showAptOptionModalSheet(BuildContext context, var appointment) async {
  showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 355,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.grey[300],
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
                            onPressed: () {

                            },
                            child: Text('Complete Appointment'),
                          )
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showAptCancelOptionModalSheet(context, appointment);
                            },
                            child: Text('Cancel Appointment'),
                          )
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            onPressed: () {

                            },
                            child: Text('Mark as no-show appointment'),
                          )
                        )
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

showAptCancelOptionModalSheet(BuildContext context, var appointment) async {
  showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 355,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.grey[300],
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
                            onPressed: () {

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
                              showAptOptionModalSheet(context, appointment);
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

showFullPkgsListModalSheet(BuildContext context, List<Packages> packages) async {
  showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 600,
        // constraints: BoxConstraints(
        //   maxHeight: MediaQuery.of(context).size.height - 50
        // ),
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.grey[300],
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
                        SingleChildScrollView(
                          child: ListView.builder(
                            //reverse: true,
                            //physics: AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: packages.length * 2,
                            padding: const EdgeInsets.all(5.0),
                            itemBuilder: (context, index) {
                              if (index.isOdd) {
                                return new Divider();
                              }
                              else {
                                final i = index ~/ 2;
                                return new ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget> [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget> [
                                          Text(packages[i].name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500
                                            )
                                          ),
                                          Text(packages[i].duration + (int.parse(packages[i].duration) > 1 ? ' Mins' : ' Min'),
                                            style: TextStyle(
                                              color: Colors.grey
                                            )
                                          )
                                        ]
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            child: Text('\$' + packages[i].price, style: TextStyle(fontSize: 17.0)),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[900],
                                              shape: BoxShape.circle
                                            ),
                                          )
                                          // Padding(padding: EdgeInsets.all(5),),
                                          // GestureDetector(
                                          //   onTap: () async {
                                          //     var res = await showPackageOptionsModalSheet(context, packages[i].name, packages[i].price, packages[i].duration, packages[i].id);
                                          //     if(res != null) {
                                          //       setState(() {
                                          //         packages = res;
                                          //       });
                                          //     }else {
                                          //       return;
                                          //     }
                                          //   },
                                          //   child: Icon(Icons.more_vert)
                                          // )
                                        ],
                                      )
                                    ]
                                  )
                                );
                              }
                            }
                          )
                        )
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