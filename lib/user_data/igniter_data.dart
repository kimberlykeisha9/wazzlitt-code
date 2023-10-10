import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/user_data/user_data.dart';

class Igniter extends ChangeNotifier {
  Igniter({this.igniterType, this.dateCreated, this.igniterPayment});

  IgniterType? igniterType;
  Map<String, dynamic>? igniterPayment;
  DateTime? dateCreated;

  // Get Igniter Information
  Future<Igniter?> getCurrentUserIgniterInformation() async {
  try {
    final doc = await currentUserIgniterProfile.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final igniterType = data['igniter_type'];
      final createdAtTimestamp = data['createdAt'] as Timestamp?;
      final igniterPayment = data['igniter_payment'];

      if (igniterType == 'business_owner') {
        return Igniter(
          igniterType: IgniterType.businessOwner,
          dateCreated: createdAtTimestamp?.toDate(),
          igniterPayment: igniterPayment,
        );
      } else if (igniterType == 'event_organizer') {
        return Igniter(
          igniterType: IgniterType.eventOrganizer,
          dateCreated: createdAtTimestamp?.toDate(),
          igniterPayment: igniterPayment,
        );
      }
    }
    // Return null if the document doesn't exist or doesn't match expected conditions.
    return null;
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

}

enum IgniterType { businessOwner, eventOrganizer }
