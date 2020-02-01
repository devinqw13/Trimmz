import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Model/Packages.dart';
import '../globals.dart' as globals;
import '../calls.dart';

class PackageOptionsBottomSheet extends StatefulWidget {
  PackageOptionsBottomSheet({@required this.package, this.updatePackages, this.showPackagesList});
  final Packages package;
  final ValueChanged updatePackages;
  final ValueChanged showPackagesList;

  @override
  _PackageOptionsBottomSheet createState() => _PackageOptionsBottomSheet();
}

class _PackageOptionsBottomSheet extends State<PackageOptionsBottomSheet> {
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController priceController = new TextEditingController();
  final TextEditingController durationController = new TextEditingController();
  Packages package;
  String _name = '';
  String _price = '';
  String _duration = '';

  @override
  void initState() {
    setState(() {
      package = widget.package;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 50),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: MediaQuery.of(context).size.height * .55,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Edit Package',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.blue
                    )
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 18.0
                    )
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: nameController,
                    autocorrect: false,
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: package.name,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)
                      )
                    ),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 18.0
                    )
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: priceController,
                    autocorrect: false,
                    onChanged: (value) {
                      setState(() {
                        _price = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: package.price,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)
                      )
                    ),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Duration (Mins)',
                    style: TextStyle(
                      fontSize: 18.0
                    )
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: durationController,
                    autocorrect: false,
                    onChanged: (value) {
                      setState(() {
                        _duration = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: package.duration,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)
                      )
                    ),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FlatButton(
                          color: Colors.red,
                          onPressed: () async {
                            bool res = await removePackage(context, globals.token, int.parse(package.id));
                            if(res) {
                              var res = await getBarberPkgs(context, globals.token);
                              Navigator.pop(context);
                              widget.updatePackages(res);
                            }else {
                              return;
                            }
                          },
                          child: Text('Remove Package')
                        )
                      )
                    )
                  ]
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                ),
              ],
            ),
            (_name != '' || _price != '' || _duration != '') ?
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FlatButton(
                      color: Colors.blue,
                      onPressed: () async {
                        var res = await updatePackage(context, globals.token, int.parse(package.id), nameController.text != '' ? nameController.text : null, priceController.text != '' ? int.parse(priceController.text) : null, durationController.text != '' ? int.parse(durationController.text) : null);
                        if(res) {
                          var res = await getBarberPkgs(context, globals.token);
                          Navigator.pop(context);
                          widget.updatePackages(res);
                          //results = res;
                        }else {
                          return;
                        }
                      },
                      child: Text('Update Package')
                    )
                  )
                )
              ]
            ) : Container(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FlatButton(
                      color: Colors.blue,
                      onPressed: () async {
                        Navigator.pop(context);
                        widget.showPackagesList(true);
                      },
                      child: Text('Cancel')
                    )
                  )
                )
              ]
            )
          ]
        ),
      )
    );
  }
}