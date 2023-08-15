import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/business_owner/business_owner_dashboard.dart';
import '../../user_data/user_data.dart';
import '../app.dart';
import 'business_owner/business_owner_profile.dart';
import 'chats_view.dart';
import 'event_organizer/event_organizer_dashboard.dart';
import 'event_organizer/event_organizer_profile.dart';
import 'igniter_drawer.dart';

class IgniterDashboard extends StatefulWidget {
  const IgniterDashboard({super.key});

  @override
  State<IgniterDashboard> createState() => _IgniterDashboardState();
}

class _IgniterDashboardState extends State<IgniterDashboard> {
  var _currentIndex = 0;

  List<Widget> businessOwnerView(List<dynamic> listings) {
    return [
      BusinessOwnerDashboard(listings: listings),
      const ChatsView(chatType: ChatRoomType.business),
      BusinessOwnerProfile(listings: listings)
    ];
  }

  List<Widget> eventOrganizerView(List<dynamic> events) {
    return [
      EventOrganizerDashboard(events: events),
      const ChatsView(chatType: ChatRoomType.business),
      const EventOrganizerProfile()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const IgniterDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: currentUserIgniterProfile.get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> igniterData =
                  snapshot.data!.data() as Map<String, dynamic>;
              if(igniterData['igniter_type'] == 'business_owner') {
                List<dynamic> listings = igniterData['listings'];
                return businessOwnerView(listings)[_currentIndex];
              } else if (igniterData['igniter_type'] == 'event_organizer') {
                List<dynamic> events = igniterData['events'];
                return eventOrganizerView(events)[_currentIndex];
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
      bottomNavigationBar: Theme(
        data: ThemeData(
          canvasColor: Theme.of(context).colorScheme.primary,
        ),
        child: BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          currentIndex: _currentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          selectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: 'Messages', icon: Icon(Icons.chat)),
            BottomNavigationBarItem(
                label: 'Profile', icon: Icon(Icons.account_circle)),
          ],
        ),
      ),
    );
  }
}
