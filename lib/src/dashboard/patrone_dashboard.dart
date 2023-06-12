import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import '../app.dart';
import '../place/place.dart';
import '../place/place_order.dart';
import 'chats_view.dart';
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
  String? selectedReason;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _exploreController = TabController(length: 2, vsync: this);
  }

  void showPopupMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = Offset(overlay.size.width / 2, overlay.size.height);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'report',
          child: Text('Report'),
        ),
        const PopupMenuItem(
          value: 'block',
          child: Text('Block User'),
        ),
      ],
      elevation: 8,
    ).then((value) {
      if (value == 'report') {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: const Text('Make a Report'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedReason,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedReason = newValue;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Reason for Report',
                            // border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'Spam',
                              child: Text('Spam'),
                            ),
                            const DropdownMenuItem(
                              value: 'Harassment',
                              child: Text('Harassment'),
                            ),
                            const DropdownMenuItem(
                              value: 'Inappropriate Content',
                              child: Text('Inappropriate Content'),
                            ),
                            const DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Any further information?'),
                          minLines: 1,
                          maxLines: 5,
                        )
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () {}, child: const Text('Submit Report'))
                    ]));
      } else if (value == 'block') {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: const Text('Block User'),
                    content: const Text('Are you sure you want to block this user?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Yes, I am sure'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No'),
                      ),
                    ]));
      }
    });
  }

  Widget? trailingIcon() {
    switch (_currentIndex) {
      case 0:
        return IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadImage(),
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
      case 3:
        return PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'Settings') {
              Navigator.pushNamed(context, 'settings');
            } else if (value == 'Order') {
              Navigator.pushNamed(context, 'orders');
            } else if (value == 'Igniter') {
              Navigator.pushNamed(context, 'igniter_dashboard');
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Settings',
              child: Text('Settings'),
            ),
            const PopupMenuItem<String>(
              value: 'Order',
              child: Text('Orders'),
            ),
            const PopupMenuItem<String>(
              value: 'Igniter',
              child: Text('Switch to Igniter Profile'),
            ),
          ],
          icon: const Icon(Icons.more_vert),
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
          tabs: [const Tab(text: 'Lit'), const Tab(text: 'Places')],
        );
      case 2:
        return const Text('Messages');
      case 3:
        return const Text('Profile');
    }
    return null;
  }

  List<Widget> views(BuildContext context) {
    return [
      feed(context),
      explore(context),
      const ChatsView(chatType: ChatRoomType.individual),
      const ProfileScreen(),
    ];
  }

  String _selectedChip = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  Widget explore(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories
                .map(
                  (chip) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(chip),
                      selected: _selectedChip == chip,
                      onSelected: (selected) {
                        setState(() {
                          _selectedChip = selected ? chip : '';
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _exploreController,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: width(context) * 0.5,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: width(context) * 0.5,
                            width: width(context) * 0.5,
                            color: Colors.indigo,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Event $index',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Description $index',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Text('Upcoming Events',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: SizedBox(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListTile(
                            onTap: () => {
                              showModalBottomSheet(
                                useSafeArea: true,
                                isScrollControlled: true,
                                context: context,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.park, size: 80),
                                      const SizedBox(height: 10),
                                      Text('Event $index',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Event $index location',
                                      ),
                                      const Text('0 km away',
                                          style: TextStyle(fontSize: 14)),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Event $index date',
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Event $index price',
                                      ),
                                      const Text('Original price',
                                          style: TextStyle(
                                              fontSize: 14,
                                              decoration:
                                                  TextDecoration.lineThrough)),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: width(context),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PlaceOrder(
                                                          orderType:
                                                              OrderType.event,
                                                          orderTitle:
                                                              'Event $index'),
                                                ),
                                              );
                                            },
                                            child: const Text('Buy Tickets')),
                                      ),
                                      const SizedBox(height: 30),
                                      Text('About Event $index',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      const Text(
                                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porta, libero at ultricies lacinia, diam sapien lacinia mi, quis aliquet diam ex et massa. Sed a tellus ac tortor placerat rutrum in non nunc. Mauris porttitor dapibus neque, at efficitur erat hendrerit nec. Cras mollis volutpat eros, vestibulum accumsan arcu rutrum a.'),
                                      const SizedBox(height: 10),
                                      const Chip(label: Text('Category')),
                                      const SizedBox(height: 10),
                                      const Text('Organizer',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      ListTile(
                                        leading: const Icon(Icons.park),
                                        title: const Text('Organizer name'),
                                        subtitle: const Text('Category'),
                                        trailing: TextButton(
                                            onPressed: () {},
                                            child: const Text('Follow')),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            },
                            leading: const Icon(Icons.park),
                            title: Text('Event $index',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: const Wrap(
                              direction: Axis.vertical,
                              children: [
                                Text('01/01/1980',
                                    style: TextStyle(fontSize: 14)),
                                Text('\$0.00', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Text(categories[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 20,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(0)),
                                onPressed: () {},
                                child: const Text('See more',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: width(context),
                              height: 190,
                              child: ListView.builder(
                                itemCount: 3,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, i) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Place(
                                                placeName: 'Place $i',
                                                category: categories[index]))),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: width(context) / 3,
                                          width: width(context) / 3,
                                          color: Colors.indigo,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(
                                              'Place $i',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            // SizedBox(height: ),
                                            const Text(
                                              '0 km away',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Nearby Places',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Flexible(
                  child: SizedBox(
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: const Icon(Icons.place),
                          title: Text('Place $index',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Wrap(
                            direction: Axis.vertical,
                            children: [
                              Text('Location', style: TextStyle(fontSize: 14)),
                              Text('0 km away', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Column feed(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: width(context),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/igniter-2.png')),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('User Caption',
                      style: TextStyle(color: Colors.white)),
                ),
                Container(
                  width: width(context),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.25),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Colors.grey, shape: BoxShape.circle),
                        ),
                        const Spacer(),
                        const Wrap(
                          direction: Axis.vertical,
                          alignment: WrapAlignment.start,
                          children: [
                            Text('User Name',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text('0 days ago',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        const Spacer(flex: 4),
                        IconButton(
                          onPressed: () {},
                          icon: const FaIcon(
                            FontAwesomeIcons.heart,
                            color: Colors.white,
                          ),
                        ),
                        const Text('0', style: TextStyle(color: Colors.white)),
                        IconButton(
                          onPressed: () {},
                          icon: const FaIcon(FontAwesomeIcons.message,
                              color: Colors.white),
                        ),
                        const Text('0', style: TextStyle(color: Colors.white)),
                        IconButton(
                          onPressed: () {},
                          icon: const FaIcon(FontAwesomeIcons.share,
                              color: Colors.white),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {
                            showPopupMenu(context);
                          },
                        ),
                      ]),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: width(context),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.75),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.place, color: Colors.white),
                      Spacer(),
                      Text('Tagged Location',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Spacer(flex: 16),
                      Text('0 km away', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
