import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:uuid/uuid.dart';
import '../src/registration/interests.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadImageToFirebase(File? imageFile, String path) async {
  if (imageFile != null) {
    try {
      // Create a reference to the Firebase Storage location
      Reference storageReference = FirebaseStorage.instance.ref().child(path);

      // Upload the file to Firebase Storage
      TaskSnapshot uploadTask = await storageReference.putFile(imageFile);

      // Get the download URL of the uploaded image
      String downloadURL = await uploadTask.ref.getDownloadURL();

      // Return the download URL
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

Future<String?> payFromBalance(double amount) async {
  String? paymentStatus;
  try {
    await currentUserPatroneProfile.get().then((doc) {
      Map<String, dynamic> account = doc.data()!;
      if (account.containsKey('balance')) {
        log('Balance found');
        if (account['balance'] > amount) {
          currentUserPatroneProfile.update(
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
    });
    return paymentStatus;
  } catch (e) {
    print(e);
  }
}

String generateUniqueId() {
  var uuid = Uuid();
  return uuid.v4(); // Returns a version 4 (random) UUID
}

Future<void> uploadPlaceOrder(Map<String, dynamic> service,
    Map<String, dynamic> place, String paymentType) async {
  // Add order to Orders Collection
  await firestore.collection('orders').add({
    'date_placed': DateTime.now(),
    'order_type': 'place',
    'service': service,
    'ordered_by': currentUserProfile,
    'payment_type': paymentType,
    'order_id': generateUniqueId(),
  }).then((order) {
    log('Added order to orders');
    // Query for business place
    firestore
        .collection('places')
        .where('place_name', isEqualTo: place['place_name'])
        .where('services', arrayContains: service)
        .limit(1)
        .get()
        .then((query) {
      // Update businesses orders
      DocumentReference place = query.docs[0].reference;
      order.update({'place': place});
      place.update({
        'orders': FieldValue.arrayUnion([order]),
      }).then((value) {
        // Update user's orders
        log('Added order to business');
        currentUserPatroneProfile.update({
          'orders': FieldValue.arrayUnion([order]),
        }).then(
            (val) => log('Completed uploading place order to user profile'));
      });
    });
  });
}

Future<void> uploadEventOrder(Map<String, dynamic> ticket, int index,
    Map<String, dynamic> event, String paymentType) async {
  // Add order to Orders Collection
  await firestore.collection('orders').add({
    'date_placed': DateTime.now(),
    'order_type': 'ticket',
    'ticket': ticket,
    'ordered_by': currentUserProfile,
    'payment_type': paymentType,
    'order_id': generateUniqueId(),
  }).then((order) {
    log('Added order to orders');
    // Query for event
    firestore
        .collection('events')
        .where('event_name', isEqualTo: event['event_name'])
        .where('tickets', arrayContains: ticket)
        .limit(1)
        .get()
        .then((query) {
      // Update event orders
      DocumentReference eventRef = query.docs[0].reference;
      order.update({'event': eventRef});
      eventRef.update({
        'orders': FieldValue.arrayUnion([order]),
        'tickets': event['tickets'],
      }).then((value) {
        // Update user's orders
        log('Added order to business');
        currentUserPatroneProfile.update({
          'orders': FieldValue.arrayUnion([order]),
        }).then(
            (val) => log('Completed uploading event order to user profile'));
      });
    });
  });
}

Future<void> topUpAccount(double topUp) async {
  try {
    await currentUserPatroneProfile.update({
      'balance': FieldValue.increment(topUp),
    }).then((value) => log('Topped up'));
  } catch (e) {
    print(e);
  }
}

Future<void> uploadPost(File toBeUploaded, String? caption, String category,
    double latitude, double longitude) async {
  try {
    await uploadImageToFirebase(toBeUploaded, 'feed/${auth.currentUser!.uid}/')
        .then((value) => firestore.collection('feed').add({
              'caption': caption,
              'creator_uid': currentUserProfile,
              'image': value,
              'likes': [],
              'date_created': DateTime.now(),
              'category': category,
              'location': GeoPoint(latitude, longitude),
            }).then((doc) => currentUserPatroneProfile.update({
                  'created_posts': FieldValue.arrayUnion([doc])
                }).then((value) => log('Uploaded post: ${doc.id}'))));
    log('Uploaded');
  } catch (e) {
    log(e.toString());
  }
}

Future<void> deleteService(
    Map<String, dynamic> service, DocumentReference place) async {
  try {
    await place.update({
      'services': FieldValue.arrayRemove([service]),
    });
  } on Exception catch (e) {
    print(e);
  }
}

Future<void> addNewService(
    {required DocumentReference place,
    String? serviceName,
    String? description,
    String? image,
    double? price,
    int? available}) async {
  bool? isAvailable() {
    if (available == 1) {
      return true;
    } else {
      return false;
    }
  }

  try {
    await place.update({
      'services': FieldValue.arrayUnion([
        {
          'service_name': serviceName,
          'service_description': description,
          'image': image,
          'price': price,
          'available': isAvailable()
        }
      ]),
    });
  } catch (e) {
    print(e);
  }
}

Future<void> updateService(
    {required DocumentReference place,
    required Map<String, dynamic> service,
    required String serviceName,
    required String description,
    String? image,
    required double price,
    required int available}) async {
  bool? isAvailable() {
    if (available == 1) {
      return true;
    } else {
      return false;
    }
  }

  try {
    await place.update({
      'services': FieldValue.arrayRemove([service]),
    }).then((value) => place.update({
          'services': FieldValue.arrayUnion([
            {
              'service_name': serviceName,
              'service_description': description,
              'image': image,
              'price': price,
              'available': isAvailable()
            }
          ]),
        }));
  } catch (e) {
    print(e);
  }
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

var currentUserProfile =
    firestore.collection('users').doc(auth.currentUser?.uid);

var currentUserPatroneProfile = firestore
    .collection('users')
    .doc(auth.currentUser?.uid)
    .collection('account_type')
    .doc('patrone');

var currentUserIgniterProfile = firestore
    .collection('users')
    .doc(auth.currentUser?.uid)
    .collection('account_type')
    .doc('igniter');

Future<bool?> checkIfPatroneUser() async {
  bool? isPatrone;
  if (auth.currentUser != null) {
    await currentUserProfile.get().then((value) {
      if (value.exists) {
        log('User has data in profile');
        Map<String, dynamic>? data = value.data();
        if (data!.keys.contains('is_patrone')) {
          log('User is patrone: ${data['is_patrone']}');
          isPatrone = data['is_patrone'] as bool;
        } else {
          log('No information found');
          isPatrone = false;
        }
      } else {
        log('User is completely new');
        isPatrone = false;
      }
    });
  } else {
    log('No active user');
  }
  return isPatrone;
}

Future<bool?> checkIfIgniterUser() async {
  bool? isIgniter;
  if (auth.currentUser != null) {
    await currentUserProfile.get().then((value) {
      log(value.data().toString());
      if (value.exists) {
        log('User has data in profile');
        Map<String, dynamic>? data = value.data();
        if (data!.keys.contains('is_igniter')) {
          log('User is igniter: ${data['is_igniter']}');
          isIgniter = data['is_igniter'] as bool;
        } else {
          log('No information found');
          isIgniter = false;
        }
      } else {
        log('User is completely new');
        isIgniter = false;
      }
    });
  } else {
    log('No active user');
  }
  return isIgniter;
}

Future<void> updateDisplayName(String? displayName) async {
  try {
    if (displayName != null && auth.currentUser != null) {
      auth.currentUser!.updateDisplayName(displayName);
    }
  } on FirebaseException catch (e) {
    log(e.code);
    log(e.message ?? 'No message');
  } catch (e) {
    log(e.toString());
  }
}

Future<void> saveUserInterests({List<Category>? interests}) async {
  try {
    await currentUserProfile.collection('account_type').doc('patrone').update({
      'interests': interests?.map((e) => {
            'display': e.display,
            'image': e.imageLink,
          }),
    });
  } on FirebaseException catch (e) {
    log(e.code);
    log(e.message ?? 'No message');
  } catch (e) {
    log(e.toString());
  }
}

Future<void> saveUserPatroneInformation(
    {String? firstName,
    String? lastName,
    String? username,
    DateTime? dob,
    bool? isGangMember,
    bool? isHIVPositive,
    String? gender}) async {
  try {
    await currentUserProfile.update({'is_patrone': true}).then((value) =>
        currentUserProfile.collection('account_type').doc('patrone').set({
          'first_name': firstName?.trim(),
          'last_name': lastName?.trim(),
          'username': username?.trim(),
          'dob': dob,
          'is_gang_member': isGangMember,
          'is_hiv_positive': isHIVPositive,
          'gender': gender,
        }).then((value) => updateDisplayName(username?.trim())));
  } on FirebaseException catch (e) {
    log(e.code);
    log(e.message ?? 'No message');
  } catch (e) {
    log(e.toString());
  }
}

Future<void> savePlaceProfile(
    {DocumentReference? place,
    String? businessName,
    String? location,
    String? website,
    String? category,
    String? description,
    String? emailAddress,
    String? phoneNumber,
    String? profilePhoto,
    String? coverPhoto,
    Timestamp? openingTime,
    Timestamp? closingTime,
    String? placeType}) async {
  try {
    var placeData = {
      'place_name': businessName?.trim(),
      'location': location?.trim(),
      'website': website,
      'category': category,
      'place_description': description,
      'email_address': emailAddress,
      'phone_number': phoneNumber,
      'image': profilePhoto,
      'cover_image': coverPhoto,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'lister': currentUserProfile,
      'place_type': placeType,
    };
    if (place != null) {
      await place.update(placeData);
    } else {
      await firestore.collection('places').add(placeData).then((newPlace) => currentUserIgniterProfile.update({
            'listings': FieldValue.arrayUnion([newPlace]),
          }));
    }
  } on FirebaseException catch (e) {
    log(e.code);
    log(e.message ?? 'No message');
  } catch (e) {
    log(e.toString());
  }
}

Future<void> saveEventOrganizerProfile(
    {String? organizerName,
    String? website,
    String? category,
    String? description,
    String? emailAddress,
    String? phoneNumber,
    String? profilePhoto,
    String? coverPhoto,
    String? placeType}) async {
  try {
    var organizerData = {
      'organizer_name': organizerName?.trim(),
      'website': website,
      'category': category,
      'organizer_description': description,
      'email_address': emailAddress,
      'phone_number': phoneNumber,
      'image': profilePhoto,
      'cover_image': coverPhoto,
      'place_type': placeType,
    };
    if (currentUserIgniterProfile != null) {
      await currentUserIgniterProfile.update(organizerData);
    } else {
      await currentUserIgniterProfile.set(organizerData);
    }
  } on FirebaseException catch (e) {
    log(e.code);
    log(e.message ?? 'No message');
  } catch (e) {
    log(e.toString());
  }
}
