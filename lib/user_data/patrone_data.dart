import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as db;
import 'package:flutter/material.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:wazzlitt/src/registration/interests.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import 'order_data.dart';

class Patrone extends ChangeNotifier {
  Patrone({
    this.firstNameSet,
    this.lastNameSet,
    this.profilePictureSet,
    this.coverPictureSet,
    this.bioSet,
    this.dobSet,
    this.genderSet,
    this.currentLocationSet,
    this.patroneReferenceSet,
    this.usernameSet,
    this.phoneNumberSet,
    this.interestsSet,
    this.createdPostsSet,
    this.followersSet,
    this.followingSet,
    this.isLit,
  });

  //Lit Status
  bool? isLit;
  // First name
  String? firstNameSet;
  String? get firstName => firstNameSet;
  // Last name
  String? lastNameSet;
  String? get lastName => lastNameSet;
  // Profile Picture
  String? profilePictureSet;
  String? get profilePicture => profilePictureSet;
  // Cover Picture
  String? get coverPicture => coverPictureSet;
  String? coverPictureSet;
  // User description
  String? get bio => bioSet;
  String? bioSet;
  // Date of birth
  DateTime? get dob => dobSet;
  DateTime? dobSet;
  // Date of creation
  DateTime? get createdTime => _createdTime;
  DateTime? _createdTime;
  // Payment Information
  Map<String, dynamic>? get patronePayment => _patronePayment;
  Map<String, dynamic>? _patronePayment;
  // Gender
  String? get gender => genderSet;
  String? genderSet;
  // Account Balance
  double? get accountBalance => _accountBalance;
  double? _accountBalance;
  // User current location
  db.GeoPoint? get currentLocation => currentLocationSet;
  db.GeoPoint? currentLocationSet;
  // User's document reference
  db.DocumentReference? get patroneReference => patroneReferenceSet;
  db.DocumentReference? patroneReferenceSet;
  // Username
  String? get username => usernameSet;
  String? usernameSet;
  // Phone Number
  String? get phoneNumber => phoneNumberSet;
  String? phoneNumberSet;
  // Email Address
  String? get emailAddress => _emailAddress;
  String? _emailAddress;
  // Created Posts
  List<dynamic>? get createdPosts => createdPostsSet!;
  List<dynamic>? createdPostsSet = [];
  // Placed Orders
  List<Order>? get placedOrders => _placedOrders;
  final List<Order> _placedOrders = [];
  // User's interests
  List<String>? get interests => interestsSet;
  List<String>? interestsSet = [];
  // User followers
  List<Map<String, dynamic>>? get followers => followersSet;
  List<Map<String, dynamic>>? followersSet = [];
  // User following
  List<dynamic>? get following => followingSet;
  List<dynamic>? followingSet = [];

  // User patrone reference
  db.DocumentReference currentUserPatroneProfile = firestore
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('account_type')
      .doc('patrone');
  // Current user uid
  String uid = auth.currentUser!.uid;

  // Get user patrone profile
  Future<Patrone> getPatroneInformation(db.DocumentReference patroneRef) async {
    try {
      Patrone patrone = Patrone();
      await patroneRef.get().then((value) {
        if (value.exists) {
          Map<String, dynamic>? content = value.data() as Map<String, dynamic>?;
          patrone = Patrone(
            patroneReferenceSet: patroneRef,
            firstNameSet: content?['first_name'],
            lastNameSet: content?['last_name'],
            dobSet: (content?['dob'] as db.Timestamp?)?.toDate(),
            usernameSet: content?['username'],
            bioSet: content?['bio'],
            profilePictureSet: content?['profile_picture'],
            coverPictureSet: content?['cover_photo'],
            genderSet: content?['gender'],
            createdPostsSet: content?['created_posts'] ?? [],
            isLit: content?['isLit'],
          );
        }
      });
      return patrone;
    } on Exception catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  // Get user patrone information
  getCurrentUserPatroneInformation() async {
    await currentUserPatroneProfile.get().then((document) {
      Map<String, dynamic>? content = document.data() as Map<String, dynamic>?;
      // Sets the getters
      firstNameSet = content?['first_name'];
      lastNameSet = content?['last_name'];
      _createdTime =
          (content?['createdAt'] as db.Timestamp?)?.toDate() ?? DateTime(2000);
      dobSet = (content?['dob'] as db.Timestamp?)?.toDate();
      _emailAddress = content?['email'];
      usernameSet = content?['username'];
      _patronePayment = content?['patrone_payment'];
      _accountBalance = content?['balance'] ?? 0;
      bioSet = content?['bio'];
      patroneReferenceSet = currentUserPatroneProfile;
      profilePictureSet = content?['profile_picture'];
      coverPictureSet = content?['cover_photo'];
      genderSet = content?['gender'];
      createdPostsSet = content?['created_posts'] ?? [];
      notifyListeners();
    });
  }

  // Get user posts

  Future<List<dynamic>> getUserPosts(db.DocumentReference user) async {
    List<dynamic> posts = [];
    await user.get().then((document) {
      Map<String, dynamic>? content = document.data() as Map<String, dynamic>?;
      List<dynamic> createdPosts = content?['created_posts'] ?? [];
      posts = createdPosts;
    });
    return posts;
  }

  // Get the current users followers

  getCurrentUserFollowers(db.DocumentReference user) {
    user.get().then((document) {
      Map<String, dynamic>? content = document.data() as Map<String, dynamic>?;
      List<dynamic> serverFollowers = content?['followers'];
      for (var patrone in serverFollowers) {
        (patrone as db.DocumentReference).get().then((patroneDoc) {
          var data = patroneDoc.data() as Map<String, dynamic>?;
          followersSet?.add({
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

  getCurrentUserFollowing(db.DocumentReference user) {
    user.get().then((document) {
      Map<String, dynamic>? content = document.data() as Map<String, dynamic>?;
      List<dynamic> serverFollowing = content?['following'];
      for (var follow in serverFollowing) {
        (follow as db.DocumentReference).get().then((doc) {
          // var data = doc.data() as Map<String, dynamic>;
          followingSet?.add({
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
      List<dynamic> serverOrders = content?['orders'] ?? [];
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
      await uploadImageToFirebase(toBeUploaded,
              'feed/${auth.currentUser!.uid}/${generateUniqueId()}')
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
      log(e.toString());
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
      'https://corsproxy.io/?https://i.pinimg.com/564x/0c/4a/94/0c4a94df8cb5658d24be310fd2e8cff9.jpg', // Capricorn
      'https://corsproxy.io/?https://i.pinimg.com/564x/1e/e3/59/1ee359b28a0c0f3f7327a0144da828c3.jpg', // Aquarius
      'https://corsproxy.io/?https://i.pinimg.com/474x/e5/69/47/e56947ee8299bdb266d90c2e3c8f592c.jpg', // Pisces
      'https://corsproxy.io/?https://i.pinimg.com/564x/e8/db/88/e8db887d86dc48e9b5af1516d5cc4514.jpg', // Aries
      'https://corsproxy.io/?https://i.pinimg.com/564x/aa/df/e7/aadfe700221fd178fd997dad5c65dd70.jpg', // Taurus
      'https://corsproxy.io/?https://i.pinimg.com/564x/dd/df/06/dddf06b46bf15971a53388e066150195.jpg', // Gemini
      'https://corsproxy.io/?https://i.pinimg.com/564x/e1/7d/75/e17d75e748788b619b809fb85d3df90f.jpg', // Cancer
      'https://corsproxy.io/?https://i.pinimg.com/474x/c1/c2/43/c1c243e0c05b608b40f9c555ad05be0e.jpg', // Leo
      'https://corsproxy.io/?https://i.pinimg.com/564x/70/c8/e1/70c8e13a68aba0c9e791fe558a165dd0.jpg', // Virgo
      'https://corsproxy.io/?https://i.pinimg.com/564x/56/56/b1/5656b133723bce54934e145838b8e3dd.jpg', // Libra
      'https://corsproxy.io/?https://i.pinimg.com/474x/14/22/a7/1422a73879d0c718f795de826f75376b.jpg', // Scorpio
      'https://corsproxy.io/?https://i.pinimg.com/474x/33/7b/db/337bdb92eb00d5c21f799864a00796a2.jpg', // Saggitarius
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
      String? profilePic,
      String? coverPic,
      String? lastName,
      String? username,
      String? email,
      DateTime? dob,
      String? gender}) async {
    try {
      currentUserPatroneProfile.get().then((value) async {
        if (value.exists) {
          currentUserPatroneProfile.update({
            'first_name': firstName?.trim(),
            'email': email,
            'profile_picture': profilePic,
            'cover_photo': coverPic,
            'last_name': lastName?.trim(),
            'username': username?.trim(),
            'dob': dob,
            'gender': gender,
          }).then((value) => {
                updateDisplayName(username?.trim()),
                auth.currentUser!.updateEmail(email!),
              });
        } else {
          await currentUserProfile.update({'is_patrone': true}).then(
            (value) => currentUserProfile
                .collection('account_type')
                .doc('patrone')
                .set({
              'createdAt': DateTime.now(),
              'first_name': firstName?.trim(),
              'email': email,
              'profile_picture': profilePic,
              'cover_photo': coverPic,
              'last_name': lastName?.trim(),
              'username': username?.trim(),
              'dob': dob,
              'gender': gender,
            }).then((value) {
              try {
                updateDisplayName(username?.trim()).then(
                  (value) => auth.currentUser!.updateEmail(email!),
                );
              } catch (e) {
                log(e.toString());
              }
            }),
          );
        }
      });
    } on db.FirebaseException catch (e) {
      log(e.code);
      log(e.message ?? 'No message');
    } catch (e) {
      log(e.toString());
    }
  }
}
