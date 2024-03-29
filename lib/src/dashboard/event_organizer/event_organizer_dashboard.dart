import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';

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
  DateTime period = DateTime.now();
  List<EventData> events = [];

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

  List<String> getCurrentWeek() {
    final DateTime monday = period.subtract(Duration(days: period.weekday - 1));
    final DateFormat formatter = DateFormat('MMM d');

    final List<DateTime> weekDays =
        List.generate(7, (index) => monday.add(Duration(days: index)));

    return weekDays.map((date) => formatter.format(date)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          height: height(context),
          width: width(context),
          decoration: BoxDecoration(
            image: moon,
          ),
          child: FutureBuilder<List<EventData>>(
            future: EventOrganizer().getListedEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No events available.'));
              } else {
                events = snapshot.data!;
                return PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final tickets = event.tickets ?? [];

                    return Column(
                      children: [
                        Hero(
                          tag: 'profile',
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              image: event.image == null
                                  ? null
                                  : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(event.image!)),
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(event.eventName ?? 'null',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            )),
                        const SizedBox(height: 10),
                        Text(DateFormat('E, dd MMM yy').format(event.date!)),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
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
                                            style: TextStyle(fontSize: 12)),
                                        Text('${event.orders?.length ?? 0}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                        const SizedBox(height: 20),
                                        const Text('Revenue Earned',
                                            style: TextStyle(fontSize: 12)),
                                        const Text('\$0.00',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                    const Column(
                                      children: [
                                        Text('Daily Chats',
                                            style: TextStyle(fontSize: 12)),
                                        Text('0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                        SizedBox(height: 20),
                                        Text('Tagged Posts',
                                            style: TextStyle(fontSize: 12)),
                                        Text('0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                    const Column(
                                      children: [
                                        Text('Daily Impressions',
                                            style: TextStyle(fontSize: 12)),
                                        Text('0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                        SizedBox(height: 20),
                                        Text('New Followers',
                                            style: TextStyle(fontSize: 12)),
                                        Text('0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
                              event.orders != null
                                  ? Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'Week (${getCurrentWeek()[0]} - ${getCurrentWeek()[6]})'),
                                            TextButton(
                                              onPressed: () =>
                                                  _selectDate(context),
                                              child: const Text('Change Period'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: event.tickets?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            Ticket ticket =
                                                event.tickets![index];
                                            return GestureDetector(
                                              onTap: () {
                                                // Navigator.push(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //         builder:
                                                //             (context) =>
                                                //                 EditTicket(
                                                //                   event:
                                                //                       data,
                                                //                   ticket:
                                                //                       ticket,
                                                //                 )));
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(ticket.title ?? 'null',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text('Sales'),
                                                      Text(
                                                          '\$${(ticket.price! * (event.orders?.length ?? 0)).toStringAsFixed(2)}')
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text('Tickets Sold'),
                                                      Text(
                                                          '${event.orders?.length ?? 0}'),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
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
                                  child: const Text('Add a new ticket'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NewTicket(
                                          event: event,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text('Performance Overview',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text('Reports received'), Text('0')],
                              ),
                              const SizedBox(height: 5),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text('Tagged posts'), Text('0')],
                              ),
                              const SizedBox(height: 5),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text('Followers'), Text('0')],
                              ),
                              const SizedBox(height: 5),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Profile Visits (Monthly)'),
                                  Text('0')
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
