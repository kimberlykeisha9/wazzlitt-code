import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:wazzlitt/user_data/user_data.dart';

final apiKey = 'sk_test_51N6MV7Aw4gbUiKSOVcDYHBiDM5ibgvUiGZQQ2erLCvrDXerqrJXDY'
    'jhdc33LMfSKXgzf5doGBAtV75AIXK3u3eUw00stk6GUfw'; // Replace with your Stripe Secret Key

var customerReference =
    firestore.collection('customers').doc(auth.currentUser!.uid);

Future<Map<String, dynamic>> createEphemeralKey(String customerId) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable
      ('generateEphemeralSecret');
    final response = await callable.call({'customerId': customerId, 'apiVersion'
        : '2022-11-15'});
    print(response.data);
    return response.data;
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

Future<PaymentIntent> wasPaymentSuccessful(var paymentIntent) async {
  final paymentIntentResult;
  try {
    paymentIntentResult = await Stripe.instance.confirmPayment(
      paymentIntentClientSecret: paymentIntent["client_secret"],
      data: PaymentMethodParams.card(paymentMethodData: PaymentMethodData(
        billingDetails: BillingDetails(email: auth.currentUser!.email!),
      ))
    );

    if (paymentIntentResult.status == PaymentIntentsStatus.Succeeded) {
      print(paymentIntentResult.toJson());
    } else {
      print(paymentIntentResult.toJson());
    }
    return paymentIntentResult;
  } catch (error) {
    if (error is StripeException) {
      log('Stripe error: $error');
    } else {
      log('Normal error: $error');
    }
    throw Exception(error);
  }
}

Future<bool> doesStripeCustomerExist(String email) async {
  final url = 'https://api.stripe.com/v1/customers';

  final headers = {
    'Authorization': 'Bearer $apiKey',
  };

  final response =
      await http.get(Uri.parse('$url?email=$email'), headers: headers);

  if (response.statusCode == 200) {
    print(response.body);
    final responseData = json.decode(response.body);
    return responseData['data'].isNotEmpty;
  } else {
    print('Error finding Stripe Customer: ${response.statusCode}');
    print(response.body);
  }

  return false;
}

Future<void> createStripeCustomer(String email) async {
  final url = 'https://api.stripe.com/v1/customers';

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  final body = {
    'email': email, // Replace with customer's email
  };

  final response =
      await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    print('Stripe Customer Created Successfully');
    print(response.body);
    try {
      await customerReference.set(jsonDecode(response.body));
    } on FirebaseException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  } else {
    print('Error creating Stripe Customer: ${response.statusCode}');
    print(response.body);
  }
}

Future<void> payForPatrone(BuildContext context) async {
  try {
    var customerID;
    var ephemeralSecret;
    // Step 0: Ensure user is a customer
    await customerReference.get().then((customerData) async {
      if (customerData.exists) {
        customerID = customerData.data()?['id'];
        log('Customer exists. Customer ID is: $customerID');
        ephemeralSecret = await createEphemeralKey(customerID);
        print( Stripe.publishableKey.split('_')[1]);
        log(ephemeralSecret!);
      } else {
        log('Customer did not exist so a new customer is being created');
        createStripeCustomer(auth.currentUser!.email!).then((value) {
          customerReference.get().then((newCustomerData) async {
            if (newCustomerData.exists) {
              customerID = newCustomerData.data()?['id'];
              log('New customer created. Customer ID is: $customerID');
              ephemeralSecret = await createEphemeralKey(customerID);
              print( Stripe.publishableKey.split('_')[1]);
              log(ephemeralSecret!);
            } else {
              log('Customer is not getting created for some reason');
              return;
            }
          });
        });
      }
    });

    // Step 1
    var paymentIntent = await createPaymentIntent('1', 'USD');
    print('just checking: ' + customerID);
    // Step 2
    await Stripe.instance
        .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              billingDetailsCollectionConfiguration:
              BillingDetailsCollectionConfiguration(
                name: CollectionMode.automatic,
                email: CollectionMode.always,
                phone: CollectionMode.always,
              ),
              billingDetails: BillingDetails(
                email: auth.currentUser!.email,
              ),
                allowsDelayedPaymentMethods: false,
                customFlow: true,
                customerId: customerID!,
                customerEphemeralKeySecret: ephemeralSecret!,
                paymentIntentClientSecret: paymentIntent!['client_secret'],
                style: ThemeMode.system,
                merchantDisplayName: 'WazzLitt'))
        .then((value) {});

    // Step 3
    displayPaymentSheet(context, paymentIntent);

    wasPaymentSuccessful(paymentIntent);
  } catch (e) {
    print('$e');
  }
}

Future<void> displayPaymentSheet(BuildContext context, var paymentIntent)
async {
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

      // Confirm if a payment was successful
      wasPaymentSuccessful(paymentIntent);

      // Clears the payment intent
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
      'amount': (double.parse(amount) * 100).toInt().toString(),
      'currency': currency,
    };

    //Make post request to Stripe
    var response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization':
            'Bearer sk_test_51N6MV7Aw4gbUiKSOVcDYHBiDM5ibgvUiGZQQ2e'
                'rLCvrDXerqrJXDYjhdc33LMfSKXgzf5doGBAtV75AIXK3u3eUw00stk6GUfw',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: body,
    );
    print(response.body);
    return json.decode(response.body);
  } catch (err) {
    throw Exception(err.toString());
  }
}
