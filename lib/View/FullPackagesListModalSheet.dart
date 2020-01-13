import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Model/Packages.dart';
import '../View/ModalSheets.dart';

class FullPackagesBottomSheet extends StatefulWidget {
  FullPackagesBottomSheet({@required this.packages, @required this.valueChanged});
  final List<Packages> packages;
  final ValueChanged valueChanged;

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
                                          var res = await showPackageOptionsModalSheet(context, packages[i].name, packages[i].price, packages[i].duration, packages[i].id);
                                          if(res != null) {
                                            setState(() {
                                              if(res.length >= 1){
                                                packages = res;
                                              }else {
                                                Navigator.pop(context);
                                              }
                                              widget.valueChanged(res);
                                            });
                                          }else {
                                            return;
                                          }
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