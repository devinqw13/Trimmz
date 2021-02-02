import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:stripe_payment/stripe_payment.dart';
import 'package:trimmz/Controller/BookAppointmentController.dart';

class PaymentMethodCard extends StatefulWidget {
  final controllerState;
  PaymentMethodCard({Key key, this.controllerState});

  @override
  _PaymentMethodCard createState() => _PaymentMethodCard();
}

class _PaymentMethodCard extends State<PaymentMethodCard> {
  globals.StripePaymentMethod paymentMethod;

  @override
  void initState() {
    super.initState();

    StripePayment.setOptions(
      new StripeOptions(
        publishableKey: globals.strpk,
        merchantId: "",
        androidPayMode: '',
      ),
    );

    getPMData();
  }

  getPMData() async {
    if(globals.stripe.customerId != null) {
      globals.StripePaymentMethod result = await getPaymentMethod(context, globals.stripe.customerId);
      setState(() {
        paymentMethod = result;
      });
    }
  }

  Widget _buildLast4() {
    List<Widget> _cardDots = List<Widget>.generate(12, (index) => 
      Container(
        margin: EdgeInsets.all(2),
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: globals.darkModeEnabled ? Colors.white : Colors.black
        ),
      )
    );

    return Container(
      child: Row(children: _cardDots)
    );
  }

  void onError(var error) {
    print(error);
  }

  addPaymentMethod() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod payMethod) async {
      widget.controllerState.progressHUD();
      var result = await updatePaymentMethod(context, globals.user.token, payMethod.id);
      setState(() {
        paymentMethod = result;
      });
      widget.controllerState.progressHUD();
    }).catchError(onError);
  }

  @override
  Widget build(BuildContext context) {
    if(paymentMethod != null) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                paymentMethod.brandIcon,
                Padding(padding: EdgeInsets.all(5)),
                _buildLast4(),
                Padding(padding: EdgeInsets.all(1)),
                Text(paymentMethod.last4)
              ]
            ),
            GestureDetector(
              onTap: () {
                addPaymentMethod();
              },
              child: Container(
                child: Text(
                  "Change Card",
                  style: TextStyle(
                    color: Colors.blue
                  ),
                )
              )
            )
          ],
        )
      );
    }else {
      return GestureDetector(
        onTap: () {
          addPaymentMethod();
        },
        child: Container(
          child: Text(
            "Add Card",
            style: TextStyle(
              color: Colors.blue
            ),
          )
        )
      );
    }
  }
}