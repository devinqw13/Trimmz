import 'package:stripe_payment/stripe_payment.dart';

const String stripeURL = "https://api.stripe.com/V1/";
const String stripeSecretKey = "sk_test_5h8VY4cc8ZUKHpIHO0TQWNkN00KJNxvrgY";
const String stripePublishablekey = "pk_test_X7T99aRCpPlsEHCjm7TOHnuO00JlKLGdal";
const String merchantId = "Test";

stripeInit() {
  StripePayment.setOptions(
    StripeOptions(
      publishableKey: "$stripePublishablekey",
      merchantId: "$merchantId",
      androidPayMode: 'test',
    ),
  );
}