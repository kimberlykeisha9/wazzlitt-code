import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/src/event/event.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';
import 'package:wazzlitt/user_data/user_data.dart';

class LitTab extends StatefulWidget {
  const LitTab({
    Key? key,
  }) : super(key: key);

  @override
  State<LitTab> createState() => _LitTabState();
}

class _LitTabState extends State<LitTab> {
  List<EventData> allEvents = [];

  Future<List<EventData>> getAllEvents() async {
    try {
      List<EventData> listedEvents = [];
      await firestore
          .collection('events')
          .where('date', isGreaterThan: DateTime.now())
          .get()
          .then((events) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> event in events.docs) {
          var eventData = event.data();
          List<Ticket>? ticketsList = [];

          if (eventData.containsKey('tickets') && eventData['tickets'] != []) {
            for (Map<String, dynamic> ticket
                in (eventData['tickets'] as List<dynamic>)) {
              ticketsList.add(Ticket(
                paymentURL: ticket['paymentLink']['url'],
                map: ticket,
                available: ticket['available'],
                title: ticket['ticket_name'],
                price: double.tryParse(ticket['price'].toString()),
                image: ticket['image'],
                description: ticket['ticket_description'],
                quantity: ticket['quantity'],
              ));
            }
          }

          listedEvents.add(EventData(
            eventName: eventData['event_name'],
            location: eventData['location']?['geopoint'],
            category: eventData['category'],
            date: (eventData['date'] as Timestamp?)?.toDate(),
            image: eventData['image'],
            description: eventData['event_description'],
            eventOrganizer: eventData['lister'],
            eventReference: event.reference,
            tickets: ticketsList,
          ));
        }
      });
      return listedEvents;
    } on Exception catch (e) {
      throw Exception(e);
    }
    // catch (e) {
    //   log("Error fetching events: $e");
    //   throw Exception(e);
    // }
  }

  void _navigateToEvent(BuildContext context, EventData eventData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Event(event: eventData),
      ),
    );
  }

  late final Future<List<EventData>> getEvents = getAllEvents();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventData>>(
      future: getEvents,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events are currently available'));
        } else {
          allEvents = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Featured Events',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: SizedBox(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemCount: allEvents.length,
                    itemBuilder: (context, index) {
                      final event = allEvents[index];
                      return ZoomIn(
                        child: GestureDetector(
                          onTap: () => _navigateToEvent(context, event),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(event.image!),
                                ),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      child: Text(
                                        DateFormat.yMMMd().format(
                                            (event.date ?? DateTime(2000))),
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      event.eventName ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    child: Text(
                                      event.category ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
