import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';
import 'package:wazzlitt/user_data/patrone_data.dart';

import 'user_data.dart';

class Order {
  DateTime? datePlaced;
  String? orderID;
  OrderType? orderType;
  String? paymentType;
  Map<String, dynamic>? details;
  DocumentReference? reference;

  Order({
    this.datePlaced,
    this.orderID,
    this.paymentType,
    this.orderType,
    this.details,
    this.reference,
  });

  // Uploads Order for an event

  Future<void> uploadPlaceOrder(Map<String, dynamic> service,
      Map<String, dynamic> place, String paymentType) async {
    // Add order to Orders Collection
    await firestore.collection('orders').add({
      'date_placed': DateTime.now(),
      'order_type': 'place',
      'service': service,
      'ordered_by': currentUserProfile,
      'payment_type': paymentType,
      'order_id': generateUniqueId(),
    }).then((order) {
      log('Added order to orders');
      // Query for business place
      firestore
          .collection('places')
          .where('place_name', isEqualTo: place['place_name'])
          .where('services', arrayContains: service)
          .limit(1)
          .get()
          .then((query) {
        // Update businesses orders
        DocumentReference place = query.docs[0].reference;
        order.update({'place': place});
        place.update({
          'orders': FieldValue.arrayUnion([order]),
        }).then((value) {
          // Update user's orders
          log('Added order to business');
          Patrone().currentUserPatroneProfile.update({
            'orders': FieldValue.arrayUnion([order]),
          }).then(
              (val) => log('Completed uploading place order to user profile'));
        });
      });
    });
  }

  // Uploads order for an event

  Future<void> uploadEventOrder(Ticket ticket, int index,
    EventData event, String paymentType) async {
  // Add order to Orders Collection
  await firestore.collection('orders').add({
    'date_placed': DateTime.now(),
    'order_type': 'ticket',
    'ticket': {'ticket_name': ticket.title, 'ticket_description': ticket.description, 'price': ticket.price},
    'ordered_by': currentUserProfile,
    'payment_type': paymentType,
    'order_id': generateUniqueId(),
  }).then((order) {
    log('Added order to orders');
    // Query for event
    firestore
        .collection('events')
        .where('event_name', isEqualTo: event.eventName)
        .where('tickets', arrayContains: {'ticket_name': ticket.title, 'ticket_description': ticket.description, 'price': ticket.price})
        .limit(1)
        .get()
        .then((query) {
      // Update event orders
      DocumentReference eventRef = query.docs[0].reference;
      order.update({'event': eventRef});
      eventRef.update({
        'orders': FieldValue.arrayUnion([order]),
      }).then((value) {
        // Update user's orders
        log('Added order to business');
        Patrone().currentUserPatroneProfile.update({
          'orders': FieldValue.arrayUnion([order]),
        }).then(
            (val) => log('Completed uploading event order to user profile'));
      });
    });
  });
}

}

enum OrderType { ticket, service }
