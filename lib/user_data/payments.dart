import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

Future<void> payForPatrone(BuildContext context) async {
  try {
    // Step 1
    var paymentIntent = await createPaymentIntent('1', 'USD');

    // Step 2
    await Stripe.instance
        .initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent![
            'client_secret'],
            style: ThemeMode.system,
            merchantDisplayName: 'WazzLitt'))
        .then((value) {
      displayPaymentSheet(context, paymentIntent);
    });

  } catch (e) {
    print('$e');
  }
}

displayPaymentSheet(BuildContext context, var paymentIntent) async {
  try {
    await Stripe.instance.presentPaymentSheet().then((value) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100.0,
                ),
                SizedBox(height: 10.0),
                Text("Payment Successful!"),
              ],
            ),
          ));

      paymentIntent = null;
    }).onError((error, stackTrace) {
      throw Exception(error);
    });
  } on StripeException catch (e) {
    print('Error is:---> $e');
    AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              Text("Payment Failed"),
            ],
          ),
        ],
      ),
    );
  } catch (e) {
    print('$e');
  }
}

createPaymentIntent(String amount, String currency) async {
  try {
    //Request body
    Map<String, dynamic> body = {
      'amount': (double.parse(amount) * 100).toString(),
      'currency': currency,
    };

    //Make post request to Stripe
    var response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer sk_test_51N6MV7Aw4gbUiKSOVcDYHBiDM5ibgvUiGZQQ2erLCvrDXerqrJXDYjhdc33LMfSKXgzf5doGBAtV75AIXK3u3eUw00stk6GUfw',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: body,
    );
    return json.decode(response.body);
  } catch (err) {
    throw Exception(err.toString());
  }
}