import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../src/app.dart';

FirebaseAuth auth = FirebaseAuth.instance;

Future<void> signOut() async {
  await auth.signOut();
  log('Logged user out');
}

Future<void> signInWithPhoneNumber(
    String phoneNumber, BuildContext context, dynamic onCodeSent) async {
  // Function to handle the verification completed event
  void verificationCompleted(PhoneAuthCredential credential) async {
    String? verificationId = await getData('verificationID');
    if (verificationId != null) {
      // Verify the code manually instead of automatic sign-in
      verifyCode(credential.smsCode ?? '', verificationId);
    }
    log(
      'Phone number automatically verified and signed in: ${credential.smsCode}',
    );
  }

  // Function to handle the verification failed event
  void verificationFailed(FirebaseAuthException e) {
    showSnackbar(
        context,
        'The verification has failed. Please try again '
        'later.');
    log(e.code);
    log(e.message ?? 'No message');
  }

  // Function to handle the code sent event
  void codeSent(String verificationId, [int? forceResendingToken]) {
    // Store the verification ID somewhere (e.g., in a global variable)
    storeData('verificationID', verificationId);
    onCodeSent;
    showSnackbar(context, 'Code has been sent');
  }

  // Function to handle the code auto-retrieval timeout event
  void codeAutoRetrievalTimeout(String verificationId) {
    log('The code timed out');
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(actions: [
      TextButton(
          onPressed: () {
            signInWithPhoneNumber(phoneNumber, context, onCodeSent);
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
          child: Text('Resend Code')),
      TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
          child: Text('Dismiss')),
    ], content: Text('Your verification code has timed out.')));
  }

  try {
    final PhoneVerificationCompleted verificationCompletedCallback =
        verificationCompleted;
    final PhoneVerificationFailed verificationFailedCallback =
        verificationFailed;
    final PhoneCodeSent codeSentCallback = codeSent;
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeoutCallback =
        codeAutoRetrievalTimeout;

    // Start the phone number verification process
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompletedCallback,
      verificationFailed: verificationFailedCallback,
      codeSent: codeSentCallback,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeoutCallback,
    );
  } catch (e) {
    log('Phone number verification failed: ${e.toString()}');
    showSnackbar(context, 'Something went wrong, please try again later');
  }
}

Future<void> verifyCode(String smsCode, String verificationId) async {
  try {
    // Create PhoneAuthCredential with the verification ID and code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    // Sign in with the phone credential
    UserCredential userCredential = await auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      log('Phone number verification successful: $smsCode');
      // Check if the user is new or existing
    }
  } catch (e) {
    log('Error verifying phone number: ${e.toString()}');
  }
}


Future<bool> isNewUser() async {
  // Check if the phone number is already registered
  final user = auth.currentUser;
  final bool isNew = user == null;

  try {
    // If the user exists, it's not a new registration
    if (user != null) {
      log('Phone number is already registered.');
    } else {
      log('New registration for the phone number.');
    }
  } catch (e) {
    log('Error checking phone number registration: ${e.toString()}');
  }
  return isNew;
}
