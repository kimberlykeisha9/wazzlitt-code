import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../user_data/user_data.dart';
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

  List<Widget> view(BuildContext context, Map<String, dynamic> igniterData) {
    return [
      dashboard(context, igniterData),
      ChatsView(chatType: ChatRoomType.business),
      profile(context, igniterData)
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
      body: FutureBuilder<DocumentSnapshot>(
          future: currentUserIgniterProfile.get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> igniterData =
                  snapshot.data!.data() as Map<String, dynamic>;
              return view(context, igniterData)[_currentIndex];
            }
            return Center(child: CircularProgressIndicator());
          }),
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

  SafeArea dashboard(BuildContext context, Map<String, dynamic> igniterData) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'profile',
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      image: igniterData['profile_photo'] == null
                          ? null
                          : DecorationImage(
                              image: NetworkImage(igniterData['profile_photo'])),
                      color: Colors.grey,
                      shape: BoxShape.circle)),
            ),
            const SizedBox(height: 20),
            Text(igniterData['title'] ?? 'null',
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
                  igniterData.containsKey('services') || (igniterData['services'] as List<dynamic>).isNotEmpty
                      ? Wrap(
                          children: [
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
                              itemCount:
                                  (igniterData['services'] as List<dynamic>)
                                      .length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> service =
                                    (igniterData['services']
                                        as List<dynamic>)[index];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(service['service_name'] ?? 'null',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Sales'),
                                          Text('\$0.00')
                                        ]),
                                    const SizedBox(height: 5),
                                    const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Units Sold'),
                                          Text('0')
                                        ]),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                          ],
                        )
                      : Center(child: Text('You have not listed any services')),
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
                      children: [Text('Profile Visits (Monthly)'), Text('0')]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SafeArea profile(BuildContext context, Map<String, dynamic> igniterData) {
    String? openingTime() {
      if(igniterData.containsKey('opening_time')) {
        Timestamp openingTime = igniterData['opening_time'];
        return DateFormat('hh:mm a').format(openingTime.toDate());
      } else {
        return null;
      }
    }
    String? closingTime() {
      if(igniterData.containsKey('closing_time')) {
        Timestamp openingTime = igniterData['closing_time'];
        return DateFormat('hh:mm a').format(openingTime.toDate());
      } else {
        return null;
      }
    }
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
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      image: igniterData['cover_photo'] == null
                          ? null
                          : DecorationImage(
                              image: NetworkImage(igniterData['cover_photo'])),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Hero(
                      tag: 'profile',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                          image: igniterData['profile_photo'] == null
                              ? null
                              : DecorationImage(
                                  image:
                                      NetworkImage(igniterData['profile_photo'])),
                        ),
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
                  Text(igniterData['title'] ?? 'null',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 20),
                  const Text('0 Followers'),
                  const SizedBox(height: 10),
                  const Text('97% Popularity'),
                  const SizedBox(height: 10),
                  Text(igniterData['location'] ?? 'null',
                      style: TextStyle(fontSize: 14)),
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
                            onPressed: () => Navigator.pushNamed(context, 'igniter_profile', arguments: igniterData['igniter_type']),
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(openingTime() == null ? 'You have not defined your operating hours' : 'Open from ${openingTime()} to ${closingTime()}'),
                        TextButton(
                          child: const Text('Edit'),
                          onPressed: () {},
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('About Us',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          child: const Text(''),
                          onPressed: () {},
                        )
                      ]),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      igniterData['description'] ?? 'null',
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Services',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          child: const Text(''),
                          onPressed: () {},
                        )
                      ]),
                  igniterData.containsKey('services') || (igniterData['services'] as List<dynamic>).isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              (igniterData['services'] as List<dynamic>).length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> service = (igniterData['services'] as List<dynamic>)[index];
                            return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceOverview(
                                      service: service),
                                ),
                              );
                            },
                              trailing: IconButton(onPressed: () => deleteService(service), icon: Icon(Icons.delete, color: Colors.red),),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                image: service['image'] == null ? null : DecorationImage(image: NetworkImage(
                                  service['image']
                                ), fit: BoxFit.cover)
                              ),
                            ),
                            title: Text(service['service_name'] ?? 'null'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(service['service_description'] ?? 'null'),
                                Text('\$${(service['price'] as double).toStringAsFixed(2)}'),
                              ],
                            ),
                          );
                          },
                        )
                      : Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'You have not listed any services',
                          ),
                        ),
                  const SizedBox(height: 20),
                  const Text('Tagged Photos',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
