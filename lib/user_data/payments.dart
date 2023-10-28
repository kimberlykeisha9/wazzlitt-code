import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../user_data/patrone_data.dart';
import 'package:url_launcher/url_launcher.dart';

const apiKey = 'sk_test_51N6MV7Aw4gbUiKSOVcDYHBiDM5ibgvUiGZQQ2erLCvrDXerqrJXDY'
    'jhdc33LMfSKXgzf5doGBAtV75AIXK3u3eUw00stk6GUfw';

Future<String?> getExistingAccountLink() async {
  String? linkUrl;
  try {
    await currentUserProfile.get().then((value) async {
      String account = (value.data() as Map<String, dynamic>)['stripeAccountID'];
      print(account);
  
    final request = await http.post(
        Uri.parse(
            'https://corsproxy.io/?https://api.stripe.com/v1/account_links'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'account': account,
          'type': 'account_update',
          'refresh_url': 'https://wazzlitt.com/',
          'return_url': 'https://wazzlitt.com/',
        });
    log(request.body);

    if (request.statusCode == 200) {
      var body = jsonDecode(request.body);
      linkUrl = body['url'];
      log(linkUrl ?? 'No url found');
    } else {
      log('The account link did not return any response');
    }
    return linkUrl;
    });
    return linkUrl;
  } on Exception catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

Future<Map<String, dynamic>?> getProductPaymentLink(
    String accountId, String priceId, int quantity) async {
  Map<String, dynamic>? response;
  try {
    final Uri url = Uri.parse('https://api.stripe.com/v1/payment_links');
    var request = await http.post(url, headers: {
      'Authorization': 'Bearer $apiKey',
      'Stripe-Account': accountId,
    }, body: {
      'line_items[0][price]': priceId,
      'line_items[0][quantity]': quantity.toString(),
      'customer_creation': 'always',
    });
    log(request.body);
    var responseData = jsonDecode(request.body);
    response = responseData;
    if (request.statusCode == 200) {
      return responseData;
    }
    return response;
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

Future<Map<String, dynamic>?> addPriceToProduct(
    DocumentReference product, String accountId, String price) async {
  Map<String, dynamic>? response;
  try {
    await product.get().then((value) async {
      if (value.exists) {
        Map<String, dynamic> data = value.data() as Map<String, dynamic>;
        String? productId = data['stripeReference']?['id'];
        if (productId != null) {
          final Uri url = Uri.parse('https://api.stripe.com/v1/prices');
          var request = await http.post(url, headers: {
            'Authorization': 'Bearer $apiKey',
            'Stripe-Account': accountId,
          }, body: {
            'currency': 'usd',
            'product': productId,
            'unit_amount': ((int.tryParse(price) ?? 0) * 100).toString(),
          });
          log(request.body);
          var responseData = jsonDecode(request.body);
          response = responseData;
          if (request.statusCode == 200) {
            return responseData;
          }
          return response;
        }
        return response;
      }
      return response;
    });
    return response;
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

Future<Map<String, dynamic>?> listEventProductOnStripe(
    String productName, bool? isAvailable, String? description) async {
  Map<String, dynamic>? response;
  try {
    await currentUserProfile.get().then((value) async {
      if (value.exists) {
        Map<String, dynamic> data = value.data() as Map<String, dynamic>;
        String? accountId = data['stripeAccountID'];
        if (accountId != null) {
          final Uri url = Uri.parse(
              'https://corsproxy.io/?https://api.stripe.com/v1/products');
          var request = await http.post(url, headers: {
            'Authorization': 'Bearer $apiKey',
            'Stripe-Account': accountId,
          }, body: {
            'name': productName,
            'active': isAvailable.toString(),
            'description': description
          });
          log(request.body);
          var responseData = jsonDecode(request.body) as Map<String, dynamic>;
          if (request.statusCode == 200) {
            response = responseData;
            return responseData;
          }
          return response;
        }
        return response;
      }
      return response;
    });
    return response;
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

Future<void> launchIgniterSubscription() async {
  String? uid = auth.currentUser!.uid;
  final Uri url = Uri.parse(
      'https://corsproxy.io/?https://buy.stripe.com/test_28o3dGfsh5SQeKk147?client_reference_id=$uid-igniter');
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
      'https://corsproxy.io/?https://buy.stripe.com/test_dR63dG5RHbda7hS6os?client_reference_id=wazzlitt-balance-$uid-patrone');
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
      'https://corsproxy.io/?https://buy.stripe.com/test_00g01ucg5che8lW9AC?client_reference_id=$uid-patrone');
  try {
    await launchUrl(url, webOnlyWindowName: '_blank')
        .then((value) => log(value.toString()));
  } catch (e) {
    throw Exception('Could not launch $url because of $e');
  }
}

Future<bool?> checkIfAccountExistsOnStripe() async {
  bool? hasDetails;
  await currentUserProfile.get().then((value) async {
    if (value.exists) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      var id = data['stripeAccountID'];
      if (id == null) {
        hasDetails = false;
        log('Account ID is empty');
        return hasDetails;
      } else {
        final request = await http.get(
            Uri.parse(
                'https://corsproxy.io/?https://api.stripe.com/v1/accounts/$id'),
            headers: {
              'Authorization': 'Bearer $apiKey',
            });
        var body = jsonDecode(request.body);
        hasDetails = body['details_submitted'];
        return hasDetails;
      }
    }
  });
  return hasDetails;
}

createSellerAccount() async {
  Future<String?> getAccountID() async {
    try {
      String? accountID;
      final request = await http.post(
          Uri.parse('https://corsproxy.io/?https://api.stripe.com/v1/accounts'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'type': 'custom',
            'capabilities[card_payments][requested]': 'true',
            'capabilities[transfers][requested]': 'true',
          });

      var responseBody = jsonDecode(request.body);
      log(request.body);
      if (request.statusCode == 200) {
        accountID = responseBody['id'];
        if (accountID != null) {
          await currentUserProfile.update({
            'stripeAccountID': accountID,
          });
        }
        log(accountID.toString());
      }
      return accountID;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<String?> getAccountLink(String account) async {
    String? linkUrl;
    try {
      final request = await http.post(
          Uri.parse(
              'https://corsproxy.io/?https://api.stripe.com/v1/account_links'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'account': account,
            'type': 'account_onboarding',
            'refresh_url': 'https://wazzlitt.com/',
            'return_url': 'https://wazzlitt.com/',
          });
      log(request.body);

      if (request.statusCode == 200) {
        var body = jsonDecode(request.body);
        linkUrl = body['url'];
        log(linkUrl ?? 'No url found');
      } else {
        log('The account link did not return any response');
      }
      return linkUrl;
    } on Exception catch (e) {
      log(e.toString());
      throw Exception(e);
    
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    } 
  }

  await getAccountID().then((account) async {
    if (account != null) {
      getAccountLink(account).then((url) async {
        if (url != null) {
          try {
            await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
          } catch (e) {
            throw Exception('Could not launch $url because of $e');
          }
        } else {
          log('No url was found');
        }
      });
    } else {
      log('Account ID was not returned');
    }
  });
}

Future<Map<String, dynamic>?> checkIfOrderIsSuccess(
    String orderReferenceId) async {
  Map<String, dynamic>? session;
  final request = await http.get(
    Uri.parse(
        'https://corsproxy.io/?https://api.stripe.com/v1/checkout/sessions'),
    headers: {
      'Authorization': 'Bearer $apiKey',
    },
  );

  if (request.statusCode == 200) {
    final data = jsonDecode(request.body);
    List listedData = data['data'];
    var orderSessions = listedData
        .where((session) =>
            session['client_reference_id'] ==
            '${auth.currentUser!.uid}-$orderReferenceId')
        .toList()
        .where((orderSession) => orderSession['payment_status'] == 'paid')
        .toList();
    log('Order Sessions: $orderSessions');
    if (orderSessions.isNotEmpty) {
      log('Found paid order for order $orderReferenceId');
      session = orderSessions[0] as Map<String, dynamic>;
    } else {
      log('No paid order for order $orderReferenceId');
    }
  } else {
    log('There was an issue: ${request.statusCode} ${request.body}');
  }
  return session;
}

Future<Map<String, dynamic>?> checkIfIgniterUserIsSubscribed() async {
  Map<String, dynamic>? session;
  final request = await http.get(
    Uri.parse(
        'https://corsproxy.io/?https://api.stripe.com/v1/checkout/sessions'),
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
    log('Client Sessions: $clientSessions');
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
    Uri.parse(
        'https://corsproxy.io/?https://api.stripe.com/v1/checkout/sessions'),
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
    log('Client Sessions: $clientSessions');
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
            'https://corsproxy.io/?https://api.stripe.com/v1/subscriptions/$subscriptionID',
          ),
          headers: {
            'Authorization': 'Bearer $apiKey',
          });
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        log(body);
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
            'https://corsproxy.io/?https://api.stripe.com/v1/subscriptions/$subscriptionID',
          ),
          headers: {
            'Authorization': 'Bearer $apiKey',
          });
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        log(body);
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
    log(e.toString());
  }
  return null;
}

Future<bool> doesStripeCustomerExist(String email) async {
  const url = 'https://corsproxy.io/?https://api.stripe.com/v1/customers';

  final headers = {
    'Authorization': 'Bearer $apiKey',
  };

  final response =
      await http.get(Uri.parse('$url?email=$email'), headers: headers);

  if (response.statusCode == 200) {
    log(response.body);
    final responseData = json.decode(response.body);
    return responseData['data'].isNotEmpty;
  } else {
    log('Error finding Stripe Customer: ${response.statusCode}');
    log(response.body);
  }

  return false;
}

Future<void> createStripeCustomer(String email) async {
  const url = 'https://corsproxy.io/?https://api.stripe.com/v1/customers';

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
    log('Stripe Customer Created Successfully');
    log(response.body);
    try {
      await customerReference.set(jsonDecode(response.body));
    } on FirebaseException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  } else {
    log('Error creating Stripe Customer: ${response.statusCode}');
    log(response.body);
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
      Uri.parse(
          'https://corsproxy.io/?https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization':
            'Bearer sk_test_51N6MV7Aw4gbUiKSOVcDYHBiDM5ibgvUiGZQQ2e'
                'rLCvrDXerqrJXDYjhdc33LMfSKXgzf5doGBAtV75AIXK3u3eUw00stk6GUfw',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: body,
    );
    log(response.body);
    return json.decode(response.body);
  } catch (err) {
    throw Exception(err.toString());
  }
}
