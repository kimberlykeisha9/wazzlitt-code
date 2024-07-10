import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/patrone_dashboard.dart';
import 'package:wazzlitt/user_data/user_data.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: currentUserProfile.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic>? data =
                snapshot.data!.data() as Map<String, dynamic>?;
            print(data);
            return PatroneDashboard();
          }
          return Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()));
        });
  }
}
