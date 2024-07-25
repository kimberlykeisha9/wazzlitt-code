import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';

import '../../user_data/patrone_data.dart';
import '../app.dart';
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
  late TabController _exploreController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    uploadCurrentLocation();
    _exploreController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await Provider.of<Patrone>(context, listen: false)
        .getCurrentUserPatroneInformation();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _smsController.dispose();
    _exploreController.dispose();
    super.dispose();
  }

  List<Widget> views(BuildContext context) {
    return [
      const Feed(),
      Explore(
        tabController: _exploreController,
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
          trailingIcon() ?? const SizedBox(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: views(context)[_currentIndex],
            ),
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
            _getImage().then((_) => _toBeUploaded != null
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
        return Text('Events around me');
      case 2:
        return const Text('Messages');
      case 3:
        return const Text('Profile');
    }
    return null;
  }
}
