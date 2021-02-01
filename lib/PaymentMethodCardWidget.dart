import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:stripe_payment/stripe_payment.dart';

class PaymentMethodCard extends StatefulWidget {
  PaymentMethodCard();

  @override
  _PaymentMethodCard createState() => _PaymentMethodCard();
}

class _PaymentMethodCard extends State<PaymentMethodCard> {
  globals.PaymentMethod paymenMethod;

  @override
  void initState() {
    getPMData();
    super.initState();
  }

  getPMData() async {
    if(globals.stripe.customerId != null) {
      var result = await getPaymentMethod(context, globals.stripe.customerId);
      print(result);
    }
  }

  buildLast4() {
    return Container();
  }

  addPaymentMethod() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) async {
      print(paymentMethod.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(paymenMethod != null) {
      return Container(
        child: Row(
          children: [
            buildLast4()
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