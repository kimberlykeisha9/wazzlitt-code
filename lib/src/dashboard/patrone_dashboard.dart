import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
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

  bool? _isSubscribed;

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PatroneDrawer(),
      appBar: AppBar(
        title: titleWidget(context),
        actions: [
          (_isSubscribed!)
              ? (trailingIcon() ?? const SizedBox())
              : const SizedBox(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: FutureBuilder<void>(
                    future: Provider.of<Patrone>(context)
                        .getCurrentUserPatroneInformation(),
                    builder: (context, snapshot) {
                      bool isFreeTrial =
                          !((Provider.of<Patrone>(context).createdTime ??
                                  DateTime(2000))
                              .add(const Duration(days: 14))
                              .isBefore(DateTime.now()));
                      if (isFreeTrial || _isSubscribed!) {
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
                      label: 'Explore',
                      icon: Icon(Icons.explore_outlined),
                      activeIcon: Icon(Icons.explore)),
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
          indicatorColor: Theme.of(context).colorScheme.primary,
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
