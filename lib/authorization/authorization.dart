import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:google_sign_in/google_sign_in.dart';
import '../src/app.dart';

FirebaseAuth auth = FirebaseAuth.instance;

Future<User?> signInWithEmailPassword(
    String email, String password, BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    return userCredential.user;
  } catch (e) {
    log('Error: $e');
    showSnackbar(context, e.toString());
    return null;
  }
}

Future<bool> checkIfEmailExists(String email) async {
  try {
    List<String> signInMethods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return signInMethods.isNotEmpty;
  } catch (e) {
    log('Error: $e');
    return false;
  }
}

Future<void> signUpWithEmailPasswordAndLinkGoogle(
    String email, String password, BuildContext context) async {
  try {
    // Step 1: Sign up with email and password
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;

    // Step 2: Check for an existing Google credential
    final googleSignIn = GoogleSignIn();
    final googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Step 3: Link the Google credential to the user's email account
      await user?.linkWithCredential(googleCredential);
    }

    log('User signed up and Google account linked successfully.');
  } catch (e) {
    log('Error: $e');
    showSnackbar(context, e.toString());
  }
}

Future<UserCredential> signInWithGoogleOnMobile() async {
  try {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on FirebaseAuthException catch (e) {
    log(e.code);
    log(e.message ?? '');
    throw Exception(e.message);
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

Future<UserCredential> signInWithGoogleOnWeb() async {
  try {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('email');

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  } on FirebaseAuthException catch (e) {
    log(e.code);
    log(e.message ?? '');
    throw Exception(e.message);
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

linkGoogleCredential() async {
  final credential = GoogleAuthProvider.credential(
      idToken: await auth.currentUser!.getIdToken());

  try {
    final userCredential =
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
    log(userCredential?.additionalUserInfo?.profile?.toString() ?? '');
  } on FirebaseAuthException catch (e) {
    log(e.code);
    log(e.message ?? '');
  }
}

unlinkGoogleCredential() async {
  try {
    await FirebaseAuth.instance.currentUser?.unlink('google.com');
  } on FirebaseAuthException catch (e) {
    log(e.code);
    log(e.message ?? '');
  }
}

bool isLoggedIn() {
  return auth.currentUser != null;
}

Future<void> signOut() async {
  await auth.signOut();
  auth.currentUser?.reload();
  log('Logged user out');
}

bool isEmailActivated() {
  return auth.currentUser!.email != null;
}

bool isGoogleActivated() {
  // Check if Google is linked to the user's account
  bool isGoogleLinked = auth.currentUser!.providerData
      .any((provider) => provider.providerId == 'google.com');

  if (isGoogleLinked) {
    log('Google is linked to the user\'s account');
  } else {
    log('Google is not linked to the user\'s account');
  }
  return isGoogleLinked;
}

bool isFacebookActivated() {
  // Check if Google is linked to the user's account
  bool isFacebookLinked = auth.currentUser!.providerData
      .any((provider) => provider.providerId == 'facebook.com');

  if (isFacebookLinked) {
    log('Facebook is linked to the user\'s account');
  } else {
    log('Facebook is not linked to the user\'s account');
  }
  return isFacebookLinked;
}

Future<void> verificationWidget(BuildContext context,
    TextEditingController controller, String verificationCode) async {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Enter your '
              'verification code'),
          content: PinCodeTextField(
              controller: controller,
              validator: (val) {
                if (val == null) {
                  return 'Please enter a value';
                }
                if (val.length != 6) {
                  return 'Please enter a valid code';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              appContext: context,
              length: 6,
              onChanged: (val) {}),
          actions: [
            TextButton(
                child: const Text('Verify'),
                onPressed: () async {
                  await verifyCode(controller.text, verificationCode).then(
                      (value) {
                    Navigator.of(context).pop();
                    Navigator.popAndPushNamed(context, 'dashboard');
                  }, onError: (e) {
                    log(e.toString());
                    Navigator.of(context).pop();
                  });
                }),
          ],
        );
      });
}

Future<void> signInWithPhoneNumber(
    String phoneNumber, BuildContext context) async {
  final TextEditingController smsController = TextEditingController();
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
    verificationWidget(context, smsController, verificationId);
    showSnackbar(context, 'Code has been sent');
  }

  // Function to handle the code auto-retrieval timeout event
  void codeAutoRetrievalTimeout(String verificationId) {
    log('The code timed out');
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(actions: [
      TextButton(
          onPressed: () {
            signInWithPhoneNumber(phoneNumber, context);
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
          child: const Text('Resend Code')),
      TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
          child: const Text('Dismiss')),
    ], content: const Text('Your verification code has timed out.')));
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

Future<PhoneAuthCredential?> verifyCode(
    String smsCode, String verificationId) async {
  PhoneAuthCredential? credential;
  try {
    // Create PhoneAuthCredential with the verification ID and code
    credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    // Sign in with the phone credential
    UserCredential userCredential = await auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      log('Phone number verification successful: $smsCode');
    }
    return credential;
  } catch (e) {
    log('Error verifying phone number: ${e.toString()}');
    throw Exception(e);
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
