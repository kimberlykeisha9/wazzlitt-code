import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/src/event/event_order.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';

import '../app.dart';

class Event extends StatefulWidget {
  const Event({super.key, required this.event});

  final EventData event;

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  late bool hasTickets;
  @override
  void initState() {
    super.initState();
    getEventInfo = (val) {
      return val;
    };
    hasTickets = ((widget.event.tickets ?? []).isNotEmpty);
  }

  late final Future<DocumentSnapshot> Function(
      Future<DocumentSnapshot<Object?>>) getEventInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventName ?? ''),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                height: height(context) * 0.5,
                width: width(context),
                child: Hero(
                  tag: widget.event.eventName ?? '',
                  child: Image.network(widget.event.image!, fit: BoxFit.cover),
                )),
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: height(context) * 0.36,
                    child: Column(
                      children: [
                        Text(widget.event.eventName ?? '',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text(
                          '${widget.event.eventName} location',
                        ),
                        const Text('0 km away', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        Text(
                          (widget.event.date != null)
                              ? DateFormat.yMEd().format((widget.event.date!))
                              : 'Date TBA',
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: width(context),
                          child: ElevatedButton(
                              onPressed: hasTickets
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EventOrder(event: widget.event),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Text(hasTickets
                                  ? 'Buy Tickets'
                                  : 'No Tickets available')),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About ${widget.event.eventName}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Text(
                          widget.event.description ?? '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                      child:
                          Chip(label: Text(widget.event.category ?? 'Unkown'))),
                  const SizedBox(height: 20),
                  const Text('Organizer',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  FutureBuilder<DocumentSnapshot>(
                      future: getEventInfo((widget.event.eventOrganizer)
                          ?.collection('account_type')
                          .doc('igniter')
                          .get() as Future<DocumentSnapshot<Object?>>),
                      builder: (context, snapshot) {
                        Map<String, dynamic>? organizerData =
                            snapshot.data?.data() as Map<String, dynamic>?;
                        if (snapshot.hasData) {
                          return ListTile(
                            leading: CircleAvatar(
                              foregroundImage: NetworkImage(organizerData?[
                                      'image'] ??
                                  'https://corsproxy.io/?https://i.pinimg.com/736x/58/58/c9/5858c9e33da2df781d11a0993f9b7030.jpg'),
                            ),
                            title: Text(
                                organizerData?['organizer_name'] ?? 'null'),
                            subtitle:
                                Text(organizerData?['category'] ?? 'null'),
                            trailing: TextButton(
                                onPressed: () {}, child: const Text('Follow')),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
