import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import '../app.dart';
import '../location/location.dart';
import 'chats_view.dart';
import 'explore.dart';
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
      PageView.builder(
        itemBuilder: (context, index) => const FeedImage(),
        itemCount: 3,
        scrollDirection: Axis.vertical,
      ),
      Explore(
        tabController: _exploreController!,
      ),
      const ChatsView(chatType: ChatRoomType.individual),
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
      body: views(context)[_currentIndex],
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

  Widget? trailingIcon() {
    switch (_currentIndex) {
      case 0:
        return IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadImage(),
              ),
            );
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
