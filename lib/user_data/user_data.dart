import 'dart:developer';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wazzlitt/authorization/authorization.dart';

import '../src/registration/interests.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadImageToFirebase(File imageFile, String path) async {
  try {
    // Create a reference to the Firebase Storage location
    Reference storageReference =
    FirebaseStorage.instance.ref().child(path);

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

Future<void> topUpAccount(double topUp) async {
  try {
    await currentUserPatroneProfile.update({
      'balance' : FieldValue.increment(topUp),
    }).then((value) => log('Topped up'));
  } catch (e) {
    print(e);
  }
}

Future<void> uploadPost(File toBeUploaded, String? caption, String category, double latitude, double longitude) async {
  try {
    await uploadImageToFirebase(toBeUploaded, 'feed/${auth.currentUser!.uid}/').then((value) => firestore.collection('feed').add({
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

Future<void> deleteService(Map<String, dynamic> service) async {
  try {
    await currentUserIgniterProfile.update({
      'services': FieldValue.arrayRemove([service]),
    });
  } on Exception catch (e) {
    print(e);
  }
}

Future<void> addNewService({String? serviceName, String? description, String? image, double? price, int? available}) async {
  bool? isAvailable() {
    if(available == 1) {
      return true;
    } else {
      return false;
    }
  }
  try {
    await currentUserIgniterProfile.update({
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


FirebaseFirestore firestore = FirebaseFirestore.instance;

var currentUserProfile = firestore.collection('users').doc(auth.currentUser
    ?.uid);

var currentUserPatroneProfile = firestore.collection('users').doc(auth
    .currentUser
    ?.uid).collection('account_type').doc('patrone');

var currentUserIgniterProfile = firestore.collection('users').doc(auth
    .currentUser
    ?.uid).collection('account_type').doc('igniter');

Future<bool?> checkIfPatroneUser() async {
  bool? isPatrone;
  if (auth.currentUser != null) {
    await currentUserProfile.get().then((value) {
      Map<String, dynamic>? data = value.data();
      if (data!.keys.contains('is_patrone')) {
        log('User is patrone: ${data['is_patrone']}');
        isPatrone = data['is_patrone'] as bool;
      } else {
        log('No information found');
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
      Map<String, dynamic>? data = value.data();
      if (data!.keys.contains('is_igniter')) {
        log('User is igniter: ${data['is_igniter']}');
        isIgniter = data['is_igniter'] as bool;
      } else {
        log('No information found');
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
  }
    on FirebaseException catch (e) {
    log(e.code);
    log(e.message ?? 'No message');
  } catch (e) {
    log(e.toString());
  }
}

Future<void> saveUserInterests({List<Category>? interests}) async {
  try {
    await
        currentUserProfile.collection('account_type').doc('patrone').update({
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

Future<void> saveUserPatroneInformation({String? firstName, String? lastName,
  String?
username, DateTime? dob, bool? isGangMember, bool? isHIVPositive, String?
gender}) async {
  try {
    await currentUserProfile.update({
      'is_patrone': true
    }).then((value) =>
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

Future<void> saveUserIgniterInformation({String? businessName, String? location,
  String?
  igniterType, String? website, String? category, String?
  description, String? emailAddress, String? phoneNumber, String? profilePhoto, String? coverPhoto}) async {
  try {
    await currentUserProfile.update({
      'is_igniter': true
    }).then((value) =>
        currentUserProfile.collection('account_type').doc('igniter').set({
          'title': businessName?.trim(),
          'location': location?.trim(),
          'igniter_type': igniterType?.trim(),
          'website': website,
          'category' : category,
          'description': description,
          'email_address': emailAddress,
          'phone_number': phoneNumber,
          'profile_photo': profilePhoto,
          'cover_photo': coverPhoto,
        }));
  } on FirebaseException catch (e) {
    log(e.code);
    log(e.message ?? 'No message');
  } catch (e) {
    log(e.toString());
  }
}