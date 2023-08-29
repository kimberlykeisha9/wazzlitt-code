import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:uuid/uuid.dart';

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
  return null;
}

String generateUniqueId() {
  var uuid = const Uuid();
  return uuid.v4(); // Returns a version 4 (random) UUID
}

Future<void> addNewTicket(
    {required DocumentReference event,
    String? ticketName,
    String? description,
    DateTime? expiry,
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
    await event.update({
      'tickets': FieldValue.arrayUnion([
        {
          'ticket_name': ticketName,
          'ticket_description': description,
          'expiry_date': expiry,
          'price': price,
          'available': isAvailable(),
        }
      ]),
    });
  } catch (e) {
    print(e);
  }
}


Future<void> updateTicket(
    {required DocumentReference event,
    required Map<String, dynamic> ticket,
    String? ticketName,
    String? description,
    Timestamp? expiry,
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
    await event.update({
      'tickets': FieldValue.arrayRemove([ticket]),
    }).then((value) => event.update({
          'tickets': FieldValue.arrayUnion([
            {
              'ticket_name': ticketName,
              'ticket_description': description,
              'expiry_date': expiry,
              'price': price,
              'available': isAvailable(),
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

var currentUserIgniterProfile = firestore
    .collection('users')
    .doc(auth.currentUser?.uid)
    .collection('account_type')
    .doc('igniter');

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

Future<String> getCurrentLocation(DocumentReference userProfile) async {
  String serverLocation = '';
  await userProfile.get().then((data) async {
    if (data.exists) {
      Map<String, dynamic> userData = data.data() as Map<String, dynamic>;
      GeoPoint? location = userData['current_location']?['geopoint'];
      if (location != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude);
        Placemark placemark = placemarks
            .where((placemark) => !(placemark.name!.contains('+')))
            .toList()[0];

        serverLocation = '${placemark.name}, ${placemark.country}';
      } else {
        serverLocation = 'Not available';
      }
    } else {
      serverLocation = 'Not available';
    }
  });
  return serverLocation;
}

Future<void> sendMessage(
    CollectionReference chats, String messageContent) async {
  try {
    await chats.add({
      'senderID': currentUserProfile,
      'content': messageContent,
      'time_sent': DateTime.now(),
    }).then((chat) => chats.parent!.update({
          'last_message': chat,
        }));
  } catch (e) {
    log(e.toString());
  }
}


Future<void> saveEvent(
    {DocumentReference? event,
    String? eventName,
    String? location,
    String? category,
    String? description,
    String? eventPhoto,
    Timestamp? date}) async {
  try {
    var eventData = {
      'event_name': eventName?.trim(),
      'location': location?.trim(),
      'category': category,
      'date': date,
      'event_description': description,
      'image': eventPhoto,
      'lister': currentUserProfile,
    };
    if (event != null) {
      await event.update(eventData);
    } else {
      await firestore
          .collection('events')
          .add(eventData)
          .then((newEvent) => currentUserIgniterProfile.update({
                'events': FieldValue.arrayUnion([newEvent]),
                'igniter_type': 'event_organizer',
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
