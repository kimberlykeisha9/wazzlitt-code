import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' as db;
import 'package:flutter/material.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:wazzlitt/src/registration/interests.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import 'order_data.dart';

class Patrone extends ChangeNotifier {
  // First name
  String? _firstName;
  String? get firstName => _firstName;
  // Last name
  String? _lastName;
  String? get lastName => _lastName;
  // Profile Picture
  String? _profilePicture;
  String? get profilePicture => _profilePicture;
  // Cover Picture
  String? get coverPicture => _coverPicture;
  String? _coverPicture;
  // User description
  String? get bio => _bio;
  String? _bio;
  // Date of birth
  DateTime? get dob => _dob;
  DateTime? _dob;
  // Date of creation
  DateTime? get createdTime => _createdTime;
  DateTime? _createdTime;
  // Payment Information
  Map<String, dynamic>? get patronePayment => _patronePayment;
  Map<String, dynamic>? _patronePayment;
  // Gender
  String? get gender => _gender;
  String? _gender;
  // Account Balance
  double? get accountBalance => _accountBalance;
  double? _accountBalance;
  // User current location
  db.GeoPoint? get currentLocation => _currentLocation;
  db.GeoPoint? _currentLocation;
  // User's document reference
  db.DocumentReference? get patroneReference => _patroneReference;
  db.DocumentReference? _patroneReference;
  // Username
  String? get username => _username;
  String? _username;
  // Phone Number
  String? get phoneNumber => _phoneNumber;
  String? _phoneNumber;
  // Email Address
  String? get emailAddress => _emailAddress;
  String? _emailAddress;
  // Created Posts
  List<dynamic> get createdPosts => _createdPosts;
  List<dynamic> _createdPosts = [];
  // Placed Orders
  List<Order> get placedOrders => _placedOrders;
  List<Order> _placedOrders = [];
  // User's interests
  List<String> get interests => _interests;
  List<String> _interests = [];
  // User followers
  List<Map<String, dynamic>> get followers => _followers;
  List<Map<String, dynamic>> _followers = [];
  // User following
  List<dynamic> get following => _following;
  List<dynamic> _following = [];

  // User patrone reference
  db.DocumentReference currentUserPatroneProfile = firestore
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('account_type')
      .doc('patrone');
  // Current user uid
  String uid = auth.currentUser!.uid;

  // Get user patrone information
  getCurrentUserPatroneInformation() {
    currentUserPatroneProfile.snapshots().listen((document) {
      Map<String, dynamic>? content = document.data() as Map<String, dynamic>?;
      // Sets the getters
      _firstName = content?['first_name'];
      _lastName = content?['last_name'];
      _createdTime = (content?['createdAt'] as db.Timestamp?)?.toDate();
      _dob = (content?['dob'] as db.Timestamp?)?.toDate();
      _emailAddress = content?['email'];
      _username = content?['username'];
      _patronePayment = content?['patrone_payment'];
      _accountBalance = content?['balance'] ?? 0;
      _bio = content?['bio'];
      _profilePicture = content?['profile_picture'];
      _coverPicture = content?['cover_photo'];
      _gender = content?['gender'];
      _createdPosts = content?['created_posts'];
      notifyListeners();
    });
  }

  // Get the current users followers

  getCurrentUserFollowers() {
    currentUserPatroneProfile.get().then((document) {
      Map<String, dynamic>? content = document.data() as Map<String, dynamic>?;
      List<dynamic> serverFollowers = content?['followers'];
      for (var patrone in serverFollowers) {
        (patrone as db.DocumentReference).get().then((patroneDoc) {
          var data = patroneDoc.data() as Map<String, dynamic>?;
          _followers.add({
            'follower_name': '${data?['first_name']} ${data?['last_name']}',
            'follower_username': data?['username'],
            'follower_profile_picture': data?['profile_picture'],
            'follower_reference': patrone,
          });
          notifyListeners();
        });
      }
    });
  }

  // Get the current users followers

  getCurrentUserFollowing() {
    currentUserPatroneProfile.get().then((document) {
      Map<String, dynamic>? content = document.data() as Map<String, dynamic>?;
      List<dynamic> serverFollowing = content?['following'];
      for (var follow in serverFollowing) {
        (follow as db.DocumentReference).get().then((doc) {
          // var data = doc.data() as Map<String, dynamic>;
          _following.add({
            'follow_reference': follow,
          });
          notifyListeners();
        });
      }
    });
  }

  // Get the current users orders

  getCurrentUserOrders() {
    currentUserPatroneProfile.get().then((document) {
      Map<String, dynamic>? content = document.data() as Map<String, dynamic>?;
      List<dynamic> serverOrders = content?['orders'];
      for (var order in serverOrders) {
        (order as db.DocumentReference).get().then((doc) {
          var orderData = doc.data() as Map<String, dynamic>;
          if (orderData['order_type'] == 'ticket') {
            _placedOrders.add(
              Order(
                datePlaced: (orderData['date_placed'] as db.Timestamp).toDate(),
                details: orderData['ticket'],
                orderID: orderData['order_id'],
                paymentType: orderData['payment_type'],
                orderType: OrderType.ticket,
                reference: orderData['event'],
              ),
            );
            notifyListeners();
          } else if (orderData['order_type'] == 'service') {
            _placedOrders.add(
              Order(
                datePlaced: (orderData['date_placed'] as db.Timestamp).toDate(),
                details: orderData['service'],
                orderID: orderData['order_id'],
                paymentType: orderData['payment_type'],
                orderType: OrderType.service,
                reference: orderData['place'],
              ),
            );
            notifyListeners();
          }
          notifyListeners();
        });
      }
    });
  }

  // Upload a post
  Future<void> uploadPost(File toBeUploaded, String? caption, String category,
      double latitude, double longitude) async {
    try {
      await uploadImageToFirebase(
              toBeUploaded, 'feed/${auth.currentUser!.uid}/')
          .then((postImage) => firestore.collection('feed').add({
                'caption': caption,
                'creator_uid': currentUserPatroneProfile,
                'image': postImage,
                'likes': [],
                'date_created': DateTime.now(),
                'category': category,
                'location': db.GeoPoint(latitude, longitude),
              }).then((doc) => currentUserPatroneProfile.update({
                    'created_posts': db.FieldValue.arrayUnion([doc])
                  }).then((value) => log('Uploaded post: ${doc.id}'))));
      log('Uploaded');
    } catch (e) {
      log(e.toString());
    }
  }

  // Top up WazzLitt Balance
  Future<void> topUpAccount(double topUp) async {
    try {
      await currentUserPatroneProfile.update({
        'balance': db.FieldValue.increment(topUp),
      }).then((value) => log('Topped up'));
    } catch (e) {
      print(e);
    }
  }

  // Check if user is a patrone
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

  // Get Star Sign of user
  String getStarSign(DateTime date) {
    const List<String> starSigns = [
      'Capricorn',
      'Aquarius',
      'Pisces',
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius'
    ];

    List<DateTime> signDates = [
      DateTime(0, 12, 22),
      DateTime(0, 1, 20),
      DateTime(0, 2, 19),
      DateTime(0, 3, 21),
      DateTime(0, 4, 20),
      DateTime(0, 5, 21),
      DateTime(0, 6, 21),
      DateTime(0, 7, 23),
      DateTime(0, 8, 23),
      DateTime(0, 9, 23),
      DateTime(0, 10, 23),
      DateTime(0, 11, 22)
    ];

    int index = date.month - 1;
    if (date.day < signDates[index].day) {
      index = (index - 1) % 12;
      if (index < 0) {
        index = 11;
      }
    }

    return starSigns[index];
  }

// Check if following a certain user
  Future<bool> isFollowingUser(db.DocumentReference user) async {
    bool isFollowing = false;
    try {
      await currentUserPatroneProfile.get().then((value) {
        Map<String, dynamic> data = value.data() as Map<String, dynamic>;
        List<dynamic> following = data['following'];
        isFollowing = following.contains(user);
      });
      return isFollowing;
    } catch (e) {
      log(e.toString());
      return isFollowing;
    }
  }

  // Follows a user
  followUser(db.DocumentReference user) async {
    try {
      await currentUserPatroneProfile.update({
        'following': db.FieldValue.arrayUnion([user]),
      }).then((value) async {
        await user.update({
          'followers': db.FieldValue.arrayUnion([currentUserPatroneProfile]),
        });
      });
      log('followed ${user.path}');
    } catch (e) {
      log(e.toString());
    }
  }

// Unfollows a user
  unfollowUser(db.DocumentReference user) async {
    try {
      await currentUserPatroneProfile.update({
        'following': db.FieldValue.arrayRemove([user]),
      }).then((value) async {
        await user.update({
          'followers': db.FieldValue.arrayRemove([currentUserPatroneProfile]),
        });
      });
      log('unfollowed ${user.path}');
    } catch (e) {
      log(e.toString());
    }
  }

// Updates user display name
  Future<void> updateDisplayName(String? displayName) async {
    try {
      if (displayName != null && auth.currentUser != null) {
        auth.currentUser!.updateDisplayName(displayName);
      }
    } on db.FirebaseException catch (e) {
      log(e.code);
      log(e.message ?? 'No message');
    } catch (e) {
      log(e.toString());
    }
  }

// Saves the users interests
  Future<void> saveUserInterests({List<Category>? interests}) async {
    try {
      await currentUserProfile
          .collection('account_type')
          .doc('patrone')
          .update({
        'interests': interests?.map((e) => {
              'display': e.display,
              'image': e.imageLink,
            }),
      });
    } on db.FirebaseException catch (e) {
      log(e.code);
      log(e.message ?? 'No message');
    } catch (e) {
      log(e.toString());
    }
  }

  // Saves the Patrone data of the user

  Future<void> saveUserPatroneInformation(
      {String? firstName,
      String? lastName,
      String? username,
      String? email,
      DateTime? dob,
      String? gender}) async {
    try {
      await currentUserProfile.update({'is_patrone': true}).then((value) =>
          currentUserProfile.collection('account_type').doc('patrone').set({
            'first_name': firstName?.trim(),
            'email': email,
            'last_name': lastName?.trim(),
            'username': username?.trim(),
            'dob': dob,
            'gender': gender,
          }).then((value) => {
                updateDisplayName(username?.trim()),
                auth.currentUser!.updateEmail(email!),
              }));
    } on db.FirebaseException catch (e) {
      log(e.code);
      log(e.message ?? 'No message');
    } catch (e) {
      log(e.toString());
    }
  }
}