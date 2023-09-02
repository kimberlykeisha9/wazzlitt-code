import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/user_data/user_data.dart';

class Igniter extends ChangeNotifier {
  IgniterType? get igniterType => _igniterType;
  IgniterType? _igniterType;
  Map<String, dynamic>? get igniterPayment => _igniterPayment;
  Map<String, dynamic>? _igniterPayment;
  DateTime? get dateCreated => _dateCreated;
  DateTime? _dateCreated;

  // Get Igniter Information
  Future<void>getCurrentUserIgniterInformation() async {
    await currentUserIgniterProfile.get().then((doc) {
      Map<String, dynamic>? content = doc.data();
      // Sets the getters
      if (content?['igniter_type'] == 'business_owner') {
        _igniterType = IgniterType.businessOwner;
        notifyListeners();
      } else if (content?['igniter_type'] == 'event_organizer') {
        _igniterType = IgniterType.eventOrganizer;
        notifyListeners();
      }
      _dateCreated = (content?['createdAt'] as Timestamp?)?.toDate();
      _igniterPayment = content?['igniter_payment'];
      notifyListeners();
    });
  }
}

enum IgniterType { businessOwner, eventOrganizer }
