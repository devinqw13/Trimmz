import 'package:stripe_payment/stripe_payment.dart';
import '../globals.dart' as globals;

stripeInit() {
  StripePayment.setOptions(
    StripeOptions(
      publishableKey: "${globals.stripePublishablekey}",
      merchantId: "${globals.stripeMerchantId}",
      androidPayMode: '',
    ),
  );
}