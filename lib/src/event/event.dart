import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../place/place_order.dart';

class Event extends StatelessWidget {
  const Event({super.key, required this.event});

  final Map<String, dynamic> event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['event_name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height(context)*0.5, width: width(context),child:
            Hero(
              tag: event['event_name'],
              child: Image
                  .network(event['image'], fit: BoxFit
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
                        Text(event['event_name'],
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text(
                          '${event['event_name']} location',
                        ),
                        const Text('0 km away',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        Text(
                          (event.containsKey('date')) ?
                          DateFormat.yMEd().format((event['date'] as Timestamp)
                              .toDate())
                              : 'Date TBA',
                        ),
                        const SizedBox(height: 10),
                        Text(
                            (event.containsKey('price')) ? '\$'
                                '${double.parse(event['price'].toString()).toStringAsFixed(2)}'
                                : 'Free',
                        ),
                        Text((event.containsKey('price')) ? '\$'
                            '${((event['price'] * 1.25) as double).toStringAsFixed(2)}'
                            : 'N/A',
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
                                            event: event,
                                            orderTitle:
                                            event['event_name']),
                                  ),
                                );
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
                        Text('About ${event['event_name']}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Text(event['event_description'],),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(child: Chip(label: Text(event['category']))),
                  const SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }
}
