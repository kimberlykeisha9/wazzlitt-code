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


