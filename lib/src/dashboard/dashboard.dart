import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/user_data/user_data.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {

        return Scaffold(
          body: StreamBuilder<DocumentSnapshot>(
        stream: currentUserProfile.snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        Map<String, dynamic>? data = snapshot.data!.data() as Map<String,
            dynamic>;
        print(data);
        if (data.containsKey('is_patrone') && data.containsKey('is_igniter')) {
          print('User is patrone and igniter');
        }
      }
      return Placeholder();
      }
          ),);
}
