import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import '../app.dart';
import 'dart:io';
import '../location/location.dart';
import 'chats_view.dart';
import 'explore.dart';
import 'feed.dart';
import 'feed_image.dart';
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

  @override
  void initState() {
    super.initState();
    _exploreController = TabController(length: 2, vsync: this);
  }

  List<Widget> views(BuildContext context) {
    return [
      Feed(),
      Explore(
        tabController: _exploreController!,
      ),
      ChatsView(chatType: ChatRoomType.individual),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: PatroneDrawer(),
      appBar: AppBar(
        title: titleWidget(context),
        actions: [
          trailingIcon() ?? const SizedBox(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: views(context)[_currentIndex]),
          ],
        ),
      ),
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
            BottomNavigationBarItem(
                label: 'Explore', icon: Icon(Icons.explore)),
            BottomNavigationBarItem(label: 'Messages', icon: Icon(Icons.chat)),
            BottomNavigationBarItem(
                label: 'Profile', icon: Icon(Icons.account_circle)),
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

  Widget? trailingIcon() {
    switch (_currentIndex) {
      case 0:
        return IconButton(
          onPressed: () {
            _getImage().then((value) => _toBeUploaded != null ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadImage(uploadedImage: _toBeUploaded!),
              ),
            ) : null);
          },
          icon: const Icon(Icons.photo_camera),
        );
      case 1:
        return IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        );
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

