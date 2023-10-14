import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:wazzlitt/src/dashboard/conversation_screen.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../user_data/payments.dart';
import '../app.dart';
import '../../user_data/patrone_data.dart';
import 'dart:io';
import '../location/location.dart';
import 'chats_view.dart';
import 'explore.dart';
import 'feed.dart';
import 'patrone_drawer.dart';
import 'upload_image.dart';

class PatroneDashboard extends StatefulWidget {
  const PatroneDashboard({super.key});

  @override
  State<PatroneDashboard> createState() => _PatroneDashboardState();
}

class _PatroneDashboardState extends State<PatroneDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  TabController? _exploreController;

  Future<bool> hasWatchedTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var watchedIntro = prefs.getBool('watchedPatroneIntro') ?? false;
    return watchedIntro;
  }

  bool? _isSubscribed;
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  GlobalKey key = GlobalKey();
  GlobalKey exploreKey = GlobalKey();
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
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
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
    addToTarget(exploreKey, '2',
        'This is where you can search for activities and see what is in your area');
    addToTarget(chatsKey, '3', 'This is where you can access your chats');
    addToTarget(profileKey, '4', 'This is where you can edit your profile');
  }

  void showTutorial(BuildContext context) {
    tutorialCoachMark = TutorialCoachMark(
      alignSkip: Alignment.topRight,
      targets: targets,
      colorShadow: Colors.pink,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('watchedPatroneIntro', true);
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
    initTargets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _layout(context);
    });
    super.initState();
    uploadCurrentLocation();
    _exploreController = TabController(length: 2, vsync: this);
    isPatroneSubscriptionActive().then((isSubscribed) {
      setState(() {
        _isSubscribed = isSubscribed;
      });
      if (isSubscribed) {
      } else {}
    });
    getInformation = Provider.of<Patrone>(context, listen: false)
        .getCurrentUserPatroneInformation();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  List<Widget> views(BuildContext context) {
    return [
      const Feed(),
      Explore(
        tabController: _exploreController!,
      ),
      const ChatsView(chatType: ChatRoomType.individual),
      ProfileScreen(
        userProfile: Provider.of<Patrone>(context),
      ),
    ];
  }

  late final Future getInformation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PatroneDrawer(),
      appBar: AppBar(
        title: titleWidget(context),
        actions: [
          (_isSubscribed ?? false)
              ? (trailingIcon() ?? const SizedBox())
              : const SizedBox(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: FutureBuilder<void>(
                    future: getInformation,
                    builder: (context, snapshot) {
                      while (_isSubscribed == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      bool isFreeTrial =
                          !((Provider.of<Patrone>(context).createdTime ??
                                  DateTime(2000))
                              .add(const Duration(days: 14))
                              .isBefore(DateTime.now()));
                      print(isFreeTrial);
                      if (isFreeTrial || _isSubscribed!) {
                        if (isFreeTrial) {
                          _isSubscribed = isFreeTrial;
                        }
                        return views(context)[_currentIndex];
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                      'You have not finished setting up your payment '
                                      'for the patrone account. You can continue the '
                                      'set up process by pressing the button below',
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                      onPressed: () {
                                        launchPatroneSubscription();
                                      },
                                      child: const Text(
                                          'Pay for Patrone Account')),
                                ]),
                          ),
                        );
                      }
                    })),
          ],
        ),
      ),
      floatingActionButton: floatingButton(),
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
                label: 'Explore',
                icon: Icon(Icons.explore_outlined, key: exploreKey),
                activeIcon: Icon(Icons.explore, key: exploreKey)),
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
      ),
    );
  }

  File? _toBeUploaded;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _toBeUploaded = File(pickedFile.path);
      });
      print("Image Path: ${pickedFile.path}");
    }
  }

  Widget? floatingButton() {
    switch (_currentIndex) {
      case 0:
        return FloatingActionButton.extended(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              _getImage().then((value) => _toBeUploaded != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UploadImage(uploadedImage: _toBeUploaded!),
                      ),
                    )
                  : null);
            },
            icon: const Icon(Icons.photo_camera),
            label: const Text('Create a post'));
      case 2:
        return FloatingActionButton.extended(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (_) => SizedBox(
                      height: height(context) * 0.75,
                      child: FutureBuilder<QuerySnapshot>(
                          future: firestore
                              .collectionGroup('account_type')
                              .where('username', isNull: false)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<QueryDocumentSnapshot<Object?>> users =
                                  snapshot.data!.docs;
                              return ListView.builder(
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    var user = users[index];

                                    Map<String, dynamic> data =
                                        user.data() as Map<String, dynamic>;
                                    return ListTile(
                                      onTap: () {
                                        firestore
                                            .collection('messages')
                                            .where('participants',
                                                arrayContains: [
                                                  currentUserProfile,
                                                  user.reference.parent.parent
                                                ])
                                            .get()
                                            .then((chats) {
                                              if (chats.size > 0) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ConversationScreen(
                                                                chats: chats
                                                                    .docs
                                                                    .first
                                                                    .reference)));
                                              } else {
                                                firestore
                                                    .collection('messages')
                                                    .add({
                                                  'participants': [
                                                    currentUserProfile,
                                                    user.reference.parent.parent
                                                  ],
                                                  'last_message': null,
                                                }).then((newChat) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ConversationScreen(
                                                                  chats:
                                                                      newChat)));
                                                });
                                              }
                                            });
                                      },
                                      leading: CircleAvatar(
                                          foregroundImage: NetworkImage(data[
                                                  'profile_picture'] ??
                                              'https://i.pinimg.com/474x/1e/23/e5/1e23e5e6441ce2c135e1e457dcf4f06f.jpg')),
                                      title: Text(
                                          '${data['first_name']} ${data['last_name']}'),
                                      subtitle: Text('@${data['username']}'),
                                    );
                                  });
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          })));
            },
            label: const Text('New chat'),
            icon: const Icon(Icons.add));
      case 3:
        return StreamBuilder<DocumentSnapshot>(
            stream: Patrone().currentUserPatroneProfile.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                bool isLit = data['isLit'] ?? false;
                return FloatingActionButton.extended(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () async {
                      if (isLit == true) {
                        await Patrone().currentUserPatroneProfile.update({
                          'isLit': false,
                        });
                      } else {
                        await Patrone().currentUserPatroneProfile.update({
                          'isLit': true,
                        });
                      }
                    },
                    icon: Icon(
                      FontAwesomeIcons.fire,
                      color: Colors.black,
                    ),
                    label: Text(
                      isLit ? 'I\'m Lit!' : 'Activate Lit Status',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ));
              }
              return CircularProgressIndicator();
            });
    }
    return null;
  }

  Widget? trailingIcon() {
    switch (_currentIndex) {
      case 0:
        return IconButton(
          onPressed: () {
            _getImage().then((value) => _toBeUploaded != null
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UploadImage(uploadedImage: _toBeUploaded!),
                    ),
                  )
                : null);
          },
          icon: const Icon(Icons.photo_camera),
        );
      case 1:
        return null;
    }
    return null;
  }

  Widget? titleWidget(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return const Text('WazzLitt! around me');
      case 1:
        return TabBar(
          unselectedLabelStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
          labelColor: Colors.green,
              unselectedLabelColor: Colors.white,
              indicatorColor: Colors.green,
          controller: _exploreController,
          tabs: const [Tab(text: 'Lit'), Tab(text: 'Places')],
        );
      case 2:
        return const Text('Messages');
      case 3:
        return const Text('Profile');
    }
    return null;
  }
}
