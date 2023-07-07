import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/igniter_dashboard.dart';
import 'package:wazzlitt/src/dashboard/patrone_dashboard.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import '../app.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: currentUserProfile.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic>? data =
                snapshot.data!.data() as Map<String, dynamic>;
            print(data);
            if (data.containsKey('is_patrone') &&
                data.containsKey('is_igniter')) {
              print('User is patrone and igniter');
            } else if (data.containsKey('is_patrone')) {
              print('User is patrone');
              return const PatroneDashboard();
            } else if (data.containsKey('is_igniter')) {
              print('User is igniter');
              return const IgniterDashboard();
            }
          }
            return Container(color: Colors.white,child:
            Center(child: CircularProgressIndicator()));

        });
  }
}
