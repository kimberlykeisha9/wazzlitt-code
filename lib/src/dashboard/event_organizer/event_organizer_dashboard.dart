import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../event/edit_ticket.dart';
import '../../event/new_ticket.dart';

class EventOrganizerDashboard extends StatefulWidget {
  EventOrganizerDashboard({super.key});

  @override
  State<EventOrganizerDashboard> createState() =>
      _EventOrganizerDashboardState();
}

class _EventOrganizerDashboardState extends State<EventOrganizerDashboard>
    with SingleTickerProviderStateMixin {
  List<String> getCurrentWeek() {
    final DateTime monday = period.subtract(Duration(days: period.weekday - 1));
    final DateFormat formatter = DateFormat('MMM d');

    final List<DateTime> weekDays =
        List.generate(7, (index) => monday.add(Duration(days: index)));

    final List<String> formattedDates =
        weekDays.map((date) => formatter.format(date)).toList();

    return formattedDates;
  }

  DateTime period = DateTime.now();

  List events = [];

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

  var _eventController;
  List<String> eventNames = [];

  @override
  void initState() {
    super.initState();
    _eventController = TabController(length: 1, vsync: this);
    //   for (var event in widget.events) {
    //     (event as DocumentReference).get().then((eventData) {
    //       eventNames.add(eventData.get('event_name'));
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          width: width(context),
          height: height(context),
          child: Column(
            children: [
              TabBar(
                controller: _eventController,
                tabs: eventNames.map((name) => Tab(text: name)).toList(),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: _eventController,
                  children: events
                      .map((data) => FutureBuilder<DocumentSnapshot>(
                          future: null,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> eventData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              return Column(
                                children: [
                                  Hero(
                                    tag: 'profile',
                                    child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                            image: eventData['image'] == null
                                                ? null
                                                : DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        eventData['image'])),
                                            color: Colors.grey,
                                            shape: BoxShape.circle)),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(eventData['event_name'] ?? 'null',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      )),
                                  const SizedBox(height: 10),
                                  Text(DateFormat('E, dd MMM yy')
                                      .format(eventData['date'].toDate())),
                                  const SizedBox(height: 20),
                                  Card(
                                      elevation: 10,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(children: [
                                          const Text('Daily Stats Overview',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              )),
                                          const SizedBox(height: 20),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    const Text('Tickets Sold',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                    Text(
                                                        '${(eventData['orders'] != null || eventData.containsKey('orders')) ? (eventData['orders'] as List).length : 0}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    const SizedBox(height: 20),
                                                    const Text('Revenue Earned',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                    const Text('\$0.00',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                const Column(
                                                  children: [
                                                    Text('Daily Chats',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                    Text('0',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    SizedBox(height: 20),
                                                    Text('Tagged Posts',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                    Text('0',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                const Column(
                                                  children: [
                                                    Text('Daily Impressions',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                    Text('0',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    SizedBox(height: 20),
                                                    Text('New Followers',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                    Text('0',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
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
                                        const Text('Tickets Overview',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                        const SizedBox(height: 10),
                                        eventData.containsKey('tickets') ||
                                                ((eventData['tickets']
                                                        as List<dynamic>?) !=
                                                    null)
                                            ? Wrap(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          'Week (${getCurrentWeek()[0]} - ${getCurrentWeek()[6]})'),
                                                      TextButton(
                                                        onPressed: () =>
                                                            _selectDate(
                                                                context),
                                                        child: const Text(
                                                            'Change Period'),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: (eventData[
                                                                'tickets']
                                                            as List<dynamic>)
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      Map<String, dynamic>
                                                          ticket =
                                                          (eventData['tickets']
                                                                  as List<
                                                                      dynamic>)[
                                                              index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          EditTicket(
                                                                            event:
                                                                                data,
                                                                            ticket:
                                                                                ticket,
                                                                          )));
                                                        },
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                ticket['ticket_name'] ??
                                                                    'null',
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            const SizedBox(
                                                                height: 5),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  const Text(
                                                                      'Sales'),
                                                                  Text(
                                                                      '\$${double.parse((ticket['price'] * ((eventData['orders'] == null || !eventData.containsKey('orders')) ? 0 : eventData['orders'].length)).toString()).toStringAsFixed(2)}')
                                                                ]),
                                                            const SizedBox(
                                                                height: 5),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  const Text(
                                                                      'Tickets Sold'),
                                                                  Text(
                                                                      '${((eventData['orders'] == null || !eventData.containsKey('orders')) ? 0 : eventData['orders'].length)}'),
                                                                ]),
                                                            const SizedBox(
                                                                height: 10),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              )
                                            : const Center(
                                                child: Text(
                                                    'You have not listed any tickets')),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: width(context),
                                          child: ElevatedButton(
                                            child:
                                                const Text('Add a new ticket'),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewTicket(
                                                    event: data,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text('Performance Overview',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 20),
                                        const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Reports received'),
                                              Text('0')
                                            ]),
                                        const SizedBox(height: 5),
                                        const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Tagged posts'),
                                              Text('0')
                                            ]),
                                        const SizedBox(height: 5),
                                        const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Followers'),
                                              Text('0')
                                            ]),
                                        const SizedBox(height: 5),
                                        const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Profile Visits (Monthly)'),
                                              Text('0')
                                            ]),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          }))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
