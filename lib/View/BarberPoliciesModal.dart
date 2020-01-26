import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../calls.dart';
import '../globals.dart' as globals;
import '../Model/BarberPolicies.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class BarberPoliciesModal extends StatefulWidget {
  BarberPoliciesModal({@required this.policies, this.setPolicies,});
  final BarberPolicies policies;
  final ValueChanged setPolicies;

  @override
  _BarberPoliciesModal createState() => _BarberPoliciesModal();
}

class _BarberPoliciesModal extends State<BarberPoliciesModal> {
  BarberPolicies policies;
  bool _isCancelPercent = false;
  bool _isNoShowPercent = false;
  bool _cancellationEnabled = false;
  bool _noshowEnabled = false;
  int finalCancelFeeAmount;
  int finalCancelChargeTime;
  int finalNoShowFeeAmount;
  final FocusNode _number1Focus = FocusNode();
  final FocusNode _number2Focus = FocusNode();
  final FocusNode _number3Focus = FocusNode();
  TextEditingController _cancelFeeAmount = new TextEditingController();
  TextEditingController _cancelChargeTime = new TextEditingController();
  TextEditingController _noShowFeeAmount = new TextEditingController();

  @override
  void initState() {
    updatePolicies(widget.policies);
    super.initState();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Color.fromARGB(255, 21, 21, 21),
      nextFocus: true,
      actions: [
        KeyboardAction(
          focusNode: _number1Focus,
          closeWidget: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Done'),
          ),
        ),
        KeyboardAction(
          focusNode: _number2Focus,
          closeWidget: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Done'),
          ),
        ),
        KeyboardAction(
          focusNode: _number3Focus,
          closeWidget: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Done'),
          ),
        ),
      ],
    );
  }

  updatePolicies([BarberPolicies policiesInfo]) {
    if(policiesInfo != null) {
      setState(() {
        policies = policiesInfo;
        _cancelFeeAmount.text = policies.cancelFee.replaceAll(new RegExp('[\$\\%]'), '');
        _isCancelPercent = policies.cancelFee.contains('\$') ? false : true;
        _cancelChargeTime.text = policies.cancelWithinTime.toString();
        _noShowFeeAmount.text = policies.noShowFee.replaceAll(new RegExp('[\$\\%]'), '');
        _isNoShowPercent = policies.noShowFee.contains('\$') ? false : true;
        _cancellationEnabled = policies.cancelEnabled;
        _noshowEnabled = policies.noShowEnabled;
      });
    }else {
      updateBarberPolicies(context, globals.token, _cancelFeeAmount.text != policies.cancelFee.replaceAll(new RegExp('[\$\\%]'), '') ? _cancelFeeAmount.text : null, _isCancelPercent != policies.cancelFee.contains('\%') ? _isCancelPercent : null, _cancelChargeTime.text != policies.cancelWithinTime.toString() ? int.parse(_cancelChargeTime.text) : null, _noShowFeeAmount.text != policies.noShowFee.replaceAll(new RegExp('[\$\\%]'), '') ? _noShowFeeAmount.text : null, _isNoShowPercent != policies.noShowFee.contains('\%') ? _isNoShowPercent : null, _cancellationEnabled != policies.cancelEnabled ? _cancellationEnabled : null, _noshowEnabled != policies.noShowEnabled ? _noshowEnabled : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      autoScroll: false,
      config: _buildConfig(context),
      child: Padding(
        padding: EdgeInsets.all(0),
        //padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  Column(
                    children: <Widget>[
                      SwitchListTile(
                        contentPadding: EdgeInsets.all(0),
                        activeColor: Colors.blue,
                        title: Text('Cancellation Policy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        subtitle: Text('Enable to set a cancellation policy', style: TextStyle(fontStyle: FontStyle.italic)),
                        value: _cancellationEnabled,
                        onChanged: (value) {
                          setState(() {
                            _cancellationEnabled = value;
                          });
                        },
                      ),
                      _cancellationEnabled ? Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * .42,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Fee Amount: '),
                                      Container(
                                        child: TextField(
                                          controller: _cancelFeeAmount,
                                          focusNode: _number1Focus,
                                          onChanged: (value) {
                                            setState(() {
                                              _cancelFeeAmount.text = value;
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: _isCancelPercent ? '1 - 100%' : 'Dollar Amount',
                                            suffixIcon: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isCancelPercent = !_isCancelPercent;
                                                });
                                              },
                                              child: _isCancelPercent ? Icon(FontAwesomeIcons.percent, color: Colors.blue, size: 20) : Icon(FontAwesomeIcons.dollarSign, color: Colors.blue, size: 20)
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blue)
                                            )
                                          ),
                                        )
                                      )
                                    ]
                                  )
                                )
                              ]
                            )
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * .42,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Charge Within: '),
                                      Container(
                                        child: TextField(
                                          controller: _cancelChargeTime,
                                          focusNode: _number2Focus,
                                          onChanged: (value) {
                                            setState(() {
                                              _cancelChargeTime.text = value;
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Hours',
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blue)
                                            )
                                          ),
                                        )
                                      )
                                    ]
                                  )
                                )
                              ]
                            )
                          )
                        ]
                      ) : Container()
                    ]
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SwitchListTile(
                        contentPadding: EdgeInsets.all(0),
                        activeColor: Colors.blue,
                        title: Text('No-Show Policy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        subtitle: Text('Enable to set a no-show policy', style: TextStyle(fontStyle: FontStyle.italic)),
                        value: _noshowEnabled,
                        onChanged: (value) {
                          setState(() {
                            _noshowEnabled = value;
                          });
                        },
                      ),
                      _noshowEnabled ? Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Fee Amount: '),
                                      Container(
                                        child: TextField(
                                          controller: _noShowFeeAmount,
                                          focusNode: _number3Focus,
                                          onChanged: (value) {
                                            setState(() {
                                              _noShowFeeAmount.text = value;
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: _isNoShowPercent ? 'Percent Amoung (1 - 100)' : 'Dollar Amount',
                                            suffixIcon: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isNoShowPercent = !_isNoShowPercent;
                                                });
                                              },
                                              child: _isNoShowPercent ? Icon(FontAwesomeIcons.percent, color: Colors.blue, size: 20) : Icon(FontAwesomeIcons.dollarSign, color: Colors.blue, size: 20)
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blue)
                                            )
                                          ),
                                        )
                                      )
                                    ]
                                  )
                                )
                              ]
                            )
                          ),
                        ]
                      ) : Container()
                    ]
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  (_cancellationEnabled != policies.cancelEnabled || _noshowEnabled != policies.noShowEnabled || _cancelChargeTime.text != policies.cancelWithinTime.toString() || _isCancelPercent != policies.cancelFee.contains('\%') || _isNoShowPercent != policies.noShowFee.contains('\%') || _cancelFeeAmount.text != policies.cancelFee.replaceAll(new RegExp('[\$\\%]'), '') || _noShowFeeAmount.text != policies.noShowFee.replaceAll(new RegExp('[\$\\%]'), '')) ? Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: FlatButton(
                            color: Colors.blue,
                            onPressed: () async {
                              //Navigator.pop(context);
                              updatePolicies();
                              //widget.setPolicies(true);
                            },
                            child: Text('Save')
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
                              //widget.updatePolicies(true);
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
          ),
        )
      )
    );
  }
}