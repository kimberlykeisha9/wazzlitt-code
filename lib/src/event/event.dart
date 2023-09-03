import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';

import '../app.dart';
import 'event_order.dart';

class Event extends StatelessWidget {
  const Event({super.key, required this.event});

  final EventData event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.eventName ?? ''),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height(context)*0.5, width: width(context),child:
            Hero(
              tag: event.eventName ?? '',
              child: Image
                  .network(event.image!, fit: BoxFit
                  .cover),
            )),
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: height(context)*0.36,
                    child: Column(
                      children: [
                        Text(event.eventName ?? '',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text(
                          '${event.eventName} location',
                        ),
                        const Text('0 km away',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        Text(
                          (event.date != null) ?
                          DateFormat.yMEd().format((event.date!))
                              : 'Date TBA',
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: width(context),
                          child: ElevatedButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         EventOrder(
                                //             event: event.eventReference!),
                                //   ),
                                // );
                              },
                              child: const Text('Buy Tickets')),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About ${event.eventName}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Text(event.description ?? '',),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(child: Chip(label: Text(event.category ?? 'Unkown'))),
                  const SizedBox(height: 20),
                  const Text('Organizer',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  FutureBuilder<DocumentSnapshot>(
                    future: (event.eventOrganizer)?.collection('account_type').doc('igniter').get(),
                    builder: (context, snapshot) {
                      Map<String, dynamic>? organizerData = snapshot.data?.data() as Map<String, dynamic>?;
                      if (snapshot.hasData) {
                        return ListTile(
                          leading: CircleAvatar(foregroundImage: NetworkImage(organizerData?['image']),),
                          title: Text(organizerData?['organizer_name'] ?? 'null'),
                          subtitle: Text(organizerData?['category'] ?? 'null'),
                          trailing: TextButton(
                              onPressed: () {},
                              child: const Text('Follow')),
                        );
                      } return const Center(child: CircularProgressIndicator());
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
