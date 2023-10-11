import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../user_data/patrone_data.dart';
import 'package:url_launcher/url_launcher.dart';

final apiKey = 'sk_test_51N6MV7Aw4gbUiKSOVcDYHBiDM5ibgvUiGZQQ2erLCvrDXerqrJXDY'
    'jhdc33LMfSKXgzf5doGBAtV75AIXK3u3eUw00stk6GUfw';

Future<void> launchIgniterSubscription() async {
  String? uid = auth.currentUser!.uid;
  final Uri url = Uri.parse(
      'https://buy.stripe.com/test_28o3dGfsh5SQeKk147?client_reference_id=$uid-igniter');
  try {
    await launchUrl(url, webOnlyWindowName: '_blank')
        .then((value) => log(value.toString()));
  } catch (e) {
    throw Exception('Could not launch $url because of $e');
  }
}

Future<void> launchTopUpPage() async {
  String? uid = auth.currentUser!.uid;
  final Uri url = Uri.parse(
      'https://buy.stripe.com/test_dR63dG5RHbda7hS6os?client_reference_id=wazzlitt-balance-$uid-patrone');
  try {
    await launchUrl(url, webOnlyWindowName: '_blank')
        .then((value) => log(value.toString()));
  } catch (e) {
    throw Exception('Could not launch $url because of $e');
  }
}

Future<void> launchPatroneSubscription() async {
  String? uid = auth.currentUser!.uid;
  final Uri url = Uri.parse(
      'https://buy.stripe.com/test_00g01ucg5che8lW9AC?client_reference_id=$uid-patrone');
  try {
    await launchUrl(url, webOnlyWindowName: '_blank')
        .then((value) => log(value.toString()));
  } catch (e) {
    throw Exception('Could not launch $url because of $e');
  }
}

createSellerAccount() async {
  Future<String?> getAccountID() async {
    try {
      String? accountID;
      final request = await http
          .post(Uri.parse('https://api.stripe.com/v1/accounts'), headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      }, body: {
        'type': 'express'
      });

      var responseBody = jsonDecode(request.body);
      if (request.statusCode == 200) {
        accountID = responseBody['id'];
        print(accountID);
      }
      return accountID;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  await getAccountID().then((account) async {
    if (account != null) {
      final request = await http
          .post(Uri.parse('https://api.stripe.com/v1/account_links'), headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      }, body: {
        'account': account,
        'type': 'account_onboarding',
        'refresh_url': 'https://wazzlitt-d7c47.web.app/',
        'return_url': 'https://wazzlitt-d7c47.web.app/',
      });
      print(request.body);
    } else {
      log('Account ID was not returned');
    }
  });
}

Future<Map<String, dynamic>?> checkIfIgniterUserIsSubscribed() async {
  Map<String, dynamic>? session;
  final request = await http.get(
    Uri.parse('https://api.stripe.com/v1/checkout/sessions'),
    headers: {
      'Authorization': 'Bearer $apiKey',
    },
  );

  if (request.statusCode == 200) {
    final data = jsonDecode(request.body);
    List listedData = data['data'];
    var clientSessions = listedData
        .where((session) =>
            session['client_reference_id'] ==
            '${auth.currentUser!.uid}-igniter')
        .toList()
        .where((userSession) => userSession['payment_status'] == 'paid')
        .toList();
    print('Client Sessions: $clientSessions');
    if (clientSessions.isNotEmpty) {
      log('Found paid session');
      session = clientSessions[0] as Map<String, dynamic>;
    } else {
      log('No paid session available');
    }
  } else {
    log('There was an issue: ${request.statusCode} ${request.body}');
  }
  return session;
}

Future<Map<String, dynamic>?> checkIfPatroneUserIsSubscribed() async {
  Map<String, dynamic>? session;
  final request = await http.get(
    Uri.parse('https://api.stripe.com/v1/checkout/sessions'),
    headers: {
      'Authorization': 'Bearer $apiKey',
    },
  );

  if (request.statusCode == 200) {
    final data = jsonDecode(request.body);
    List listedData = data['data'];
    var clientSessions = listedData
        .where((session) =>
            session['client_reference_id'] ==
            '${auth.currentUser!.uid}-patrone')
        .toList()
        .where((userSession) => userSession['payment_status'] == 'paid')
        .toList();
    print('Client Sessions: $clientSessions');
    if (clientSessions.isNotEmpty) {
      log('Found paid session');
      session = clientSessions[0] as Map<String, dynamic>;
    } else {
      log('No paid session available');
    }
  } else {
    log('There was an issue: ${request.statusCode} ${request.body}');
  }
  return session;
}

Future<bool> isIgniterSubscriptionActive() async {
  bool isSubscribed = false;
  await checkIfIgniterUserIsSubscribed().then((session) async {
    if (session != null) {
      String subscriptionID = session['subscription'];
      final response = await http.get(
          Uri.parse(
            'https://api.stripe.com/v1/subscriptions/$subscriptionID',
          ),
          headers: {
            'Authorization': 'Bearer $apiKey',
          });
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        print(body);
        String subscriptionStatus = body['status'];
        if (subscriptionStatus == 'active') {
          log('User has an active subscription');
          isSubscribed = true;
        } else {
          log('User subscription is $subscriptionStatus');
        }
      }
    }
  });
  return isSubscribed;
}

Future<bool> isPatroneSubscriptionActive() async {
  bool isSubscribed = false;
  await checkIfPatroneUserIsSubscribed().then((session) async {
    if (session != null) {
      String subscriptionID = session['subscription'];
      final response = await http.get(
          Uri.parse(
            'https://api.stripe.com/v1/subscriptions/$subscriptionID',
          ),
          headers: {
            'Authorization': 'Bearer $apiKey',
          });
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        print(body);
        String subscriptionStatus = body['status'];
        if (subscriptionStatus == 'active') {
          log('User has an active subscription');
          isSubscribed = true;
        } else {
          log('User subscription is $subscriptionStatus');
        }
      }
    }
  });
  return isSubscribed;
}

Future<void> saveIgniterSessionOnFirebase() async {
  await checkIfIgniterUserIsSubscribed().then(
    (session) async {
      if (session != null) {
        customerReference.get().then((value) async {
          if (value.exists) {
            log('Customer object exists');
            await customerReference
                .collection('sessions')
                .add(session)
                .then((value) {
              currentUserIgniterProfile.update(
                {'recentSession': value},
              );
            });
          } else {
            await customerReference.set(session['customer']).then(
                  (value) => customerReference
                      .update(session['customer_details'])
                      .then(
                    (value) async {
                      await customerReference
                          .collection('sessions')
                          .add(session)
                          .then((value) {
                        currentUserIgniterProfile.update(
                          {'recentSession': value},
                        );
                      });
                    },
                  ),
                );
          }
        });
      }
    },
  );
}

Future<void> savePatroneSessionOnFirebase() async {
  await checkIfPatroneUserIsSubscribed().then(
    (session) async {
      if (session != null) {
        customerReference.get().then((value) async {
          if (value.exists) {
            log('Customer object exists');
            await customerReference
                .collection('sessions')
                .add(session)
                .then((value) {
              Patrone().currentUserPatroneProfile.update(
                {'recentSession': value},
              );
            });
          } else {
            await customerReference.set(session['customer']).then(
                  (value) => customerReference
                      .update(session['customer_details'])
                      .then(
                    (value) async {
                      await customerReference
                          .collection('sessions')
                          .add(session)
                          .then((value) {
                        currentUserIgniterProfile.update(
                          {'recentSession': value},
                        );
                      });
                    },
                  ),
                );
          }
        });
      }
    },
  );
}

var customerReference =
    firestore.collection('customers').doc(auth.currentUser!.uid);

Future<String?> payFromBalance(double amount, BuildContext context) async {
  String? paymentStatus;
  try {
    var account = Provider.of<Patrone>(context).accountBalance;
    if (account != null) {
      log('Balance found');
      if (account > amount) {
        Patrone().currentUserPatroneProfile.update(
            {'balance': FieldValue.increment(double.parse('-$amount'))});
        paymentStatus = 'paid';
      } else {
        log('Balance is less than amount to be deducted');
        paymentStatus = 'unpaid';
      }
    } else {
      log('Balance not found');
      paymentStatus = 'unpaid';
    }
    return paymentStatus;
  } catch (e) {
    print(e);
  }
  return null;
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
