import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/src/dashboard/business_owner/business_owner_dashboard.dart';
import '../../authorization/authorization.dart';
import '../../user_data/igniter_data.dart';
import '../../user_data/payments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  TextEditingController emailController = TextEditingController();

  bool? _isSubscribed;

  @override
  void initState() {
    super.initState();
    Provider.of<Igniter>(context, listen: false)
        .getCurrentUserIgniterInformation();
    isIgniterSubscriptionActive().then((isSubscribed) {
      setState(() {
        _isSubscribed = isSubscribed;
      });
      if (isSubscribed) {
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    var igniterData = Provider.of<Igniter>(context);
    bool isFreeTrial = !((igniterData.dateCreated ?? DateTime(2000))
        .add(const Duration(days: 14))
        .isBefore(DateTime.now()));
    return Scaffold(
      drawer: const IgniterDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: (isFreeTrial || _isSubscribed!)
          ? (igniterData.igniterType == IgniterType.businessOwner)
              ? businessOwnerView[_currentIndex]
              : eventOrganizerView[_currentIndex]
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                      'You have not finished setting up your payment '
                      'for the Igniter account. You can continue the '
                      'set up process by pressing the button below',
                      textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await launchIgniterSubscription();
                    },
                    child: const Text('Pay for Igniter Account'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _isSubscribed!
          ? Theme(
              data: ThemeData(
                canvasColor: Theme.of(context).colorScheme.surface,
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
                  BottomNavigationBarItem(
                      label: 'Home',
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home)),
                  BottomNavigationBarItem(
                      label: 'Messages',
                      icon: Icon(Icons.chat_outlined),
                      activeIcon: Icon(Icons.chat)),
                  BottomNavigationBarItem(
                      label: 'Profile',
                      icon: Icon(Icons.account_circle_outlined),
                      activeIcon: Icon(Icons.account_circle)),
                ],
              ),
            )
          : const SizedBox(),
    );
  }

  List eventOrganizerView = [
    EventOrganizerDashboard(),
    const ChatsView(chatType: ChatRoomType.business),
    EventOrganizerProfile()
  ];

  List businessOwnerView = [
    BusinessOwnerDashboard(),
    const ChatsView(chatType: ChatRoomType.business),
    BusinessOwnerProfile()
  ];
}
