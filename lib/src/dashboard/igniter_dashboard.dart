
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../place/new_service.dart';
import '../place/service_overview.dart';
import 'chats_view.dart';
import 'igniter_drawer.dart';

class IgniterDashboard extends StatefulWidget {
  const IgniterDashboard({super.key});

  @override
  State<IgniterDashboard> createState() => _IgniterDashboardState();
}

class _IgniterDashboardState extends State<IgniterDashboard> {
  var _currentIndex = 0;
  DateTime period = DateTime.now();
  List<String> getCurrentWeek() {
    final DateTime monday = period.subtract(Duration(days: period.weekday - 1));
    final DateFormat formatter = DateFormat('MMM d');

    final List<DateTime> weekDays =
        List.generate(7, (index) => monday.add(Duration(days: index)));

    final List<String> formattedDates =
        weekDays.map((date) => formatter.format(date)).toList();

    return formattedDates;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        period = pickedDate;
      });
    }
  }

  List<Widget> view(BuildContext context) {
    return [
      dashboard(context),
      const ChatsView(chatType: ChatRoomType.business),
      profile(context)
    ];
  }

  @override
  Widget build(BuildContext context) {
    getCurrentWeek();
    return Scaffold(
      drawer: const IgniterDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: view(context)[_currentIndex],
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

  SafeArea dashboard(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 60,
                width: 60,
                decoration:
                    const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(height: 20),
            const Text('Business Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            const SizedBox(height: 20),
            const Card(
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    Text('Daily Stats Overview',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text('Services Sold',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              Text('Revenue Earned',
                                  style: TextStyle(fontSize: 12)),
                              Text('\$0.00',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Daily Chats',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              Text('Tagged Posts',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Daily Impressions',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              Text('New Followers',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ])
                  ]),
                )),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Services Overview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Week (${getCurrentWeek()[0]} - ${getCurrentWeek()[6]})'),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Change Period'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Service $index',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text('Sales'), Text('\$0.00')]),
                        const SizedBox(height: 5),
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text('Units Sold'), Text('0')]),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: width(context),
                    child: ElevatedButton(
                      child: const Text('Add a new service'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewService(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Performance Overview',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Chats received today'), Text('0')]),
                  const SizedBox(height: 5),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Reports received'), Text('0')]),
                  const SizedBox(height: 5),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Tagged posts'), Text('0')]),
                  const SizedBox(height: 5),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Followers'), Text('0')]),
                  const SizedBox(height: 5),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Profile Visits (Monthly'), Text('0')]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SafeArea profile(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Container(
                    width: width(context),
                    height: 150,
                    color: Colors.grey,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Business Name',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 20),
                  const Text('0 Followers'),
                  const SizedBox(height: 10),
                  const Text('97% Popularity'),
                  const SizedBox(height: 10),
                  const Text('Something Street, Town', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 10,
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(5)),
                            onPressed: () {},
                            child: const Text('Edit Profile',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 10,
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(5)),
                            onPressed: () {},
                            child: const Text('Social Links',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Open - 09:00 AM to 09:00 PM'),
                    TextButton(
                      child: const Text('Edit'),
                      onPressed: () {},
                    )
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('About Us', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      child: const Text('Edit'),
                      onPressed: () {},
                    )
                  ]),
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Praesent vel enim ipsum. Donec sit amet scelerisque justo, non'
                        ' eleifend sem. Phasellus vestibulum sapien quis sodales accumsan. '
                        'Ut consectetur felis id nunc volutpat tristique. Suspendisse '
                        'euismod volutpat augue nec bibendum. In ut nisl odio. Quisque '
                        'diam risus, pharetra suscipit egestas sit amet, laoreet feugiat '
                        'nunc. Phasellus bibendum dui at sapien consequat, vel vestibulum '
                        'elit consequat. Sed ullamcorper tortor mauris, eu volutpat turpis'
                        ' hendrerit at.',
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Services', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      child: const Text('Edit'),
                      onPressed: () {},
                    )
                  ]),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index) => ListTile(
                        onTap: () {
                          Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => ServiceOverview
                              (serviceTitle: 'Service $index'),
                          ),
                          );
                        },
                          leading: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey,
                          ),
                          title: Text('Service $index'),
                          subtitle: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Product Brief Description'),
                                Text('\$0.00'),
                              ]))),
                  const SizedBox(height: 20),
                  const Text('Tagged Photos',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  TextButton(
                    child: const Text('Tap to review'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150,
              width: width(context),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) => Container(
                  height: 150,
                  width: width(context) * 0.25,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}