import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trimmz/dialogs.dart';
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 415,
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
                new Center(
                  child: GestureDetector(
                    onTap: () async {
                      bool res = await removePackage(context, globals.token, int.parse(package.id));
                      if(res) {
                        var res = await getBarberPkgs(context, globals.token);
                        Navigator.pop(context);
                        widget.updatePackages(res);
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
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FlatButton(
                      color: Colors.blue,
                      onPressed: () async {
                        if(nameController.text != '' || priceController.text != '' || durationController.text != ''){
                          var res = await updatePackage(context, globals.token, int.parse(package.id), nameController.text != '' ? nameController.text : null, priceController.text != '' ? int.parse(priceController.text) : null, durationController.text != '' ? int.parse(durationController.text) : null);
                          if(res) {
                            var res = await getBarberPkgs(context, globals.token);
                            Navigator.pop(context);
                            widget.updatePackages(res);
                            //results = res;
                          }else {
                            return;
                          }
                        }else {
                          showErrorDialog(context, 'Missing Fields', 'Enter all fields to add a new package (FIX)');
                        }
                      },
                      child: Text('Update Package')
                    )
                  )
                )
              ]
            ),
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