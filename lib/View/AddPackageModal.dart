import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trimmz/dialogs.dart';
import '../Model/Packages.dart';
import '../globals.dart' as globals;
import '../calls.dart';
import  'package:keyboard_actions/keyboard_actions.dart';

class AddPackageBottomSheet extends StatefulWidget {
  AddPackageBottomSheet({this.updatePackages});
  final ValueChanged updatePackages;

  @override
  _AddPackageBottomSheet createState() => _AddPackageBottomSheet();
}

class _AddPackageBottomSheet extends State<AddPackageBottomSheet> {
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController priceController = new TextEditingController();
  final TextEditingController durationController = new TextEditingController();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _durationFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  Packages package;
  String _name = '';
  String _price = '';
  String _duration = '';
  bool numberKeyboard = false;

  @override
  void initState() {
    _priceFocus.addListener(() {
      if(_priceFocus.hasFocus) {
        setState(() {
          numberKeyboard = true;
        });
      }
    });
    _durationFocus.addListener(() {
      if(_durationFocus.hasFocus) {
        setState(() {
          numberKeyboard = true;
        });
      }
    });
    _nameFocus.addListener(() {
      if(_nameFocus.hasFocus) {
        setState(() {
          numberKeyboard = false;
        });
      }
    });
    super.initState();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Color.fromARGB(255, 21, 21, 21),
      nextFocus: true,
      actions: [
        KeyboardAction(
          onTapAction: () {
            if(priceController.text != ''){
              setState(() {
                _price = priceController.text;
              });
            }
          },
          focusNode: _priceFocus,
          closeWidget: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Done'),
          ),
        ),
        KeyboardAction(
          onTapAction: () {
            if(priceController.text != ''){
              setState(() {
                _duration = durationController.text;
              });
            }
          },
          focusNode: _durationFocus,
          closeWidget: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Done'),
          ),
        ),
      ],
    );
  }

  submitService() async {
    if(!(int.parse(durationController.text) % 15 == 0)) {
      showErrorDialog(context, 'Invalid Duration', 'The duration of the service must be in increments of 15 minutes, e.g: 15, 30.');
      return;
    }

    var res = await addPackage(context, globals.token, nameController.text, int.parse(durationController.text), double.parse(priceController.text));
    if(res) {
      var res = await getBarberPkgs(context, globals.token);
      Navigator.pop(context);
      widget.updatePackages(res);
    }else {
      showErrorDialog(context, 'Error', 'Was unable to add service. Try again.');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      autoScroll: false,
      config: _buildConfig(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: numberKeyboard ? 0 : MediaQuery.of(context).viewInsets.bottom, top: 50),
        child: Container(
          padding: EdgeInsets.all(10.0),
          height: MediaQuery.of(context).size.height * .50,
          margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 21, 21, 21),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2, color: Colors.grey[400], spreadRadius: 0)
            ]
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'New Service',
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
                          focusNode: _nameFocus,
                          autocorrect: false,
                          onChanged: (value) {
                            setState(() {
                              _name = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Service Name',
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
                          focusNode: _priceFocus,
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          onChanged: (value) {
                            setState(() {
                              _price = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Service Price',
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
                        child: RichText(
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          text: new TextSpan(
                            children: <TextSpan> [
                              new TextSpan(text: 'Duration ', style: TextStyle(fontSize: 18)),
                              TextSpan(text: '15 min increments', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                            ]
                          )
                        )
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          focusNode: _durationFocus,
                          autocorrect: false,
                          onChanged: (value) {
                            setState(() {
                              _duration = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Service Duration',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)
                            )
                          ),
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                      ),
                    ]
                  )
                )
              ),
              Column(
                children: <Widget> [
                  (_name != '' && _price != '' && _duration != '') ?
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: FlatButton(
                            color: Colors.blue,
                            onPressed: () async {
                              submitService();
                            },
                            child: Text('Add Service')
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
                            },
                            child: Text('Cancel')
                          )
                        )
                      )
                    ]
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }
}