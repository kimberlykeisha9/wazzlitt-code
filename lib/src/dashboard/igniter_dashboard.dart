import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
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

  late bool? _isSubscribed;

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  GlobalKey key = GlobalKey();
  GlobalKey chatsKey = GlobalKey();
  GlobalKey profileKey = GlobalKey();
   void initTargets() {
    void addToTarget(GlobalKey assignedKey, String target, String instruction) {
      targets.add(
        TargetFocus(
          identify: target,
          keyTarget: assignedKey,
          color: Colors.red,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        instruction,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
    }
    addToTarget(key, '1', 'This is where you will find your home feed');
    addToTarget(chatsKey, '3', 'This is where you can access your chats');
    addToTarget(profileKey, '4', 'This is where you can edit your profile');
  }

  void showTutorial(BuildContext context) {
  tutorialCoachMark = TutorialCoachMark(
    
    targets: targets,
    colorShadow: Colors.pink,
    textSkip: "SKIP",
    paddingFocus: 10,
    opacityShadow: 0.8,
    onFinish: () {
      print("finish");
    },
    onClickTarget: (target) {
      print('onClickTarget: $target');
    },
    onSkip: () {
      print("skip");
    },
    onClickOverlay: (target) {
      print('onClickOverlay: $target');
    },
  )..show(context: context);
}

void _layout(BuildContext context){
    Future.delayed(const Duration(milliseconds: 100));
    showTutorial(context);
  }


  @override
  void initState() {
    initTargets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _layout(context);
    });
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
        while (_isSubscribed == null) {
                        return Center(child: CircularProgressIndicator());
                      }
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
                items: [
                  BottomNavigationBarItem(
                   
                      label: 'Home',
                      icon: Icon(Icons.home_outlined, key: key),
                      activeIcon: Icon(Icons.home, key: key)),
                  BottomNavigationBarItem(
                      label: 'Messages',
                      icon: Icon(Icons.chat_outlined, key: chatsKey),
                      activeIcon: Icon(Icons.chat, key: chatsKey)),
                  BottomNavigationBarItem(
                      label: 'Profile',
                      icon: Icon(Icons.account_circle_outlined, key: profileKey),
                      activeIcon: Icon(Icons.account_circle, key: profileKey)),
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
