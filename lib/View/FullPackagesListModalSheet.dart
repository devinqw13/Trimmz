import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Model/Packages.dart';

class FullPackagesBottomSheet extends StatefulWidget {
  FullPackagesBottomSheet({@required this.packages, this.showPackageOptions});
  final List<Packages> packages;
  final ValueChanged showPackageOptions;

  @override
  _FullPackagesBottomSheet createState() => _FullPackagesBottomSheet();
}

class _FullPackagesBottomSheet extends State<FullPackagesBottomSheet> {
  List<Packages> packages;

  @override
  void initState() {
    setState(() {
      packages = widget.packages;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: packages.length > 0 ? 600 : 200,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2, color: Colors.grey[400], spreadRadius: 0
            )
          ]
        ),
        child: new Stack(
          children: <Widget> [
            packages.length > 0 ? new Container(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
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
                                      ),
                                      Padding(padding: EdgeInsets.all(5),),
                                      GestureDetector(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          widget.showPackageOptions(packages[i]);
                                        },
                                        child: Icon(Icons.more_vert)
                                      )
                                    ],
                                  ),
                                ]
                              )
                            );
                          }
                        }
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
            ) : 
            new Container(
              child: Center(
                child: Text(
                  'You don\'t have any packages.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold
                  )
                )
              )
            ),
          ]
        )
      )
    );
  }
}