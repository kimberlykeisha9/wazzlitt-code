import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wazzlitt/authorization/authorization.dart';

import '../src/registration/interests.dart';

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
    await currentUserProfile.set({
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