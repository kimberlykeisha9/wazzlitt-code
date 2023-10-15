import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:wazzlitt/src/dashboard/business_owner/business_owner_dashboard.dart';
import 'package:wazzlitt/src/dashboard/igniter_chats_view.dart';
import 'package:wazzlitt/src/event/edit_event.dart';
import '../../authorization/authorization.dart';

import 'package:shared_preferences/shared_preferences.dart';
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

  Future<bool> hasWatchedTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var watchedIntro = prefs.getBool('watchedIgniterIntro') ?? false;
    return watchedIntro;
  }

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
              align: ContentAlign.top,
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      instruction,
                      style: const TextStyle(
                        color: Colors.white,
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

    addToTarget(key, '1',
        'This is where you will find you can access your dashboard for your WazzLitt content');
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
      onFinish: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('watchedIgniterIntro', true);
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

  void _layout(BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 100));
    await hasWatchedTutorial().then((hasWatched) {
      if (!hasWatched) {
        showTutorial(context);
      }
    });
  }

  @override
  void initState() {
    if (!isLoggedIn()) {
      Navigator.popAndPushNamed(context, 'home');
    }
    initTargets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _layout(context);
    });
    super.initState();
    isIgniterSubscriptionActive().then((isSubscribed) {
      setState(() {
        _isSubscribed = isSubscribed;
      });
      if (isSubscribed) {
      } else {}
    });
  }

  late final Future<Igniter?> getIgniterInfo =
      Igniter().getCurrentUserIgniterInformation();

  @override
  Widget build(BuildContext context) {
    while (_isSubscribed == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<Igniter?>(
        future: getIgniterInfo,
        builder: (context, snapshot) {
          print(snapshot.hasData);
          if (snapshot.hasData) {
            Igniter igniter = snapshot.data!;
            bool isFreeTrial = !((igniter.dateCreated ?? DateTime(2000))
                .add(const Duration(days: 14))
                .isBefore(DateTime.now()));
            return Scaffold(
              drawer: const IgniterDrawer(),
              appBar: AppBar(
                title: const Text('Dashboard'),
              ),
              body: (isFreeTrial)
                  ? (igniter.igniterType == IgniterType.businessOwner)
                      ? businessOwnerView[_currentIndex]
                      : eventOrganizerView[_currentIndex]
                  : (_isSubscribed ?? false)
                      ? (igniter.igniterType == IgniterType.businessOwner)
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
              bottomNavigationBar: Theme(
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
                        icon: Icon(Icons.account_circle_outlined,
                            key: profileKey),
                        activeIcon:
                            Icon(Icons.account_circle, key: profileKey)),
                  ],
                ),
              ),
              floatingActionButton: igniter.igniterType != null
                  ? floatingButton(igniter.igniterType!)
                  : null,
            );
          }

          if (!snapshot.hasData) {
            return Center(
                child: Text(
                    'Sorry, an error has occured. Please try again in a few minutes'));
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget? floatingButton(IgniterType igniterType) {
    switch (_currentIndex) {
      case 0:
        if (igniterType == IgniterType.businessOwner) {
          return FloatingActionButton.extended(
              onPressed: () {},
              label: const Text('List a new place'),
              icon: const Icon(Icons.place));
        } else {
          return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const EditEvent()));
              },
              label: const Text('List a new event'),
              icon: const Icon(Icons.calendar_month));
        }
    }
    return null;
  }

  List eventOrganizerView = [
    EventOrganizerDashboard(),
    const IgniterChatsView(chatType: ChatRoomType.business),
    const EventOrganizerProfile()
  ];

  List businessOwnerView = [
    const BusinessOwnerDashboard(),
    const IgniterChatsView(chatType: ChatRoomType.business),
    const BusinessOwnerProfile()
  ];
}
