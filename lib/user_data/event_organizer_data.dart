import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import 'order_data.dart' as wz;

import 'igniter_data.dart';

class EventOrganizer extends ChangeNotifier {
  List<EventData>? get events => _events;
  List<EventData> _events = [];
  String? get coverImage => _coverImage;
  String? _coverImage;
  String? get organizerName => _organizerName;
  String? _organizerName;
  String? get profileImage => _profileImage;
  String? _profileImage;
  String? get description => _description;
  String? _description;
  String? get website => _website;
  String? _website;
  String? get phone => _phone;
  String? _phone;
  String? get email => _email;
  String? _email;

  // Get organizer Info
  Future<void>getCurrentUserEventOrganizerInformation() async {
    try {
      await currentUserIgniterProfile.get().then((doc) async {
      Map<String, dynamic>? content = doc.data();
      _events = await getListedEvents();
      _coverImage = content!['cover_image'];
      _profileImage = content['image'];
      _organizerName = content['organizer_name'];
      _description = content['organizer_description'];
      _website = content['website'];
      _phone = content['phone_number'];
      _email = content['email_address'];
      notifyListeners();
    });
    } catch (e) {
      log(e.toString());
    }
  }

  // Get Events

  Future<List<EventData>> getListedEvents() async {
    try {
      final doc = await currentUserIgniterProfile.get();
      final data = doc.data();
      final List<dynamic> userEvents = data?['events'];
      final List<EventData> listedEvents = [];

      for (DocumentReference eventRef in userEvents) {
        final event = await eventRef.get();
        var eventData = event.data() as Map<String, dynamic>?;
        List<Ticket>? ticketsList = [];
        final List<wz.Order> eventOrders = [];

        final orders = await firestore
            .collection('orders')
            .where('event', isEqualTo: eventRef)
            .get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> order in orders.docs) {
          final orderData = order.data();
          eventOrders.add(
            wz.Order(
              datePlaced: (orderData['date_placed'] as Timestamp).toDate(),
              details: orderData['ticket'],
              orderID: orderData['order_id'],
              paymentType: orderData['payment_type'],
              orderType: wz.OrderType.ticket,
              reference: orderData['event'],
            ),
          );
        }

        if (eventData!.containsKey('tickets')) {
          for (Map<String, dynamic> ticket
              in (eventData['tickets'] as List<dynamic>)) {
            ticketsList.add(Ticket(
              available: ticket['available'],
              title: ticket['ticket_name'],
              price: ticket['price'],
              image: ticket['image'],
              description: ticket['ticket_description'],
              quantity: ticket['quantity'],
            ));
          }
        }

        final EventData foundEvent = EventData(
          eventName: eventData['event_name'],
          location: eventData['location']?['geopoint'],
          category: eventData['category'],
          date: (eventData['date'] as Timestamp?)?.toDate(),
          image: eventData['image'],
          description: eventData['event_description'],
          eventOrganizer: eventData['lister'],
          eventReference: eventRef,
          tickets: ticketsList,
          orders: eventOrders,
        );

        if (listedEvents.contains(foundEvent)) {
          listedEvents
              .where(
                  (event) => event.eventReference == foundEvent.eventReference)
              .toList()
              .forEach((element) {
            listedEvents.remove(element);
            log('Removed event. New value is ${listedEvents.length}');
          });
        } else {
          listedEvents.add(foundEvent);
          log('Added event. New value is ${listedEvents.length}');
        }
      }
      return listedEvents;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  // Saves Event Organizer Profile
  Future<void> saveEventOrganizerProfile(
      {String? organizerName,
      String? website,
      String? category,
      String? description,
      String? emailAddress,
      String? phoneNumber,
      String? profilePhoto,
      String? coverPhoto,
      String? placeType}) async {
    try {
      var organizerData = {
        'organizer_name': organizerName?.trim(),
        'website': website,
        'category': category,
        'organizer_description': description,
        'email_address': emailAddress,
        'phone_number': phoneNumber,
        'image': profilePhoto,
        'cover_image': coverPhoto,
        'place_type': placeType,
      };
      if (currentUserIgniterProfile != null) {
        await currentUserIgniterProfile.update(organizerData);
      } else {
        await currentUserIgniterProfile.set(organizerData);
      }
    } on FirebaseException catch (e) {
      log(e.code);
      log(e.message ?? 'No message');
    } catch (e) {
      log(e.toString());
    }
  }
}

class EventData {
  EventData({
    this.eventName,
    this.location,
    this.category,
    this.eventOrganizer,
    this.eventReference,
    this.tickets,
    this.date,
    this.image,
    this.description,
    this.orders,
  });

  String? eventName;
  GeoPoint? location;
  String? category;
  DocumentReference? eventReference;
  DocumentReference? eventOrganizer;
  List<Ticket>? tickets = [];
  DateTime? date;
  String? image;
  String? description;
  List<wz.Order>? orders;

  // Saves an event
  Future<void> saveEvent(
      {DocumentReference? event,
      String? eventName,
      String? location,
      String? category,
      String? description,
      String? eventPhoto,
      Timestamp? date}) async {
    try {
      var eventData = {
        'event_name': eventName?.trim(),
        'location': location?.trim(),
        'category': category,
        'date': date,
        'event_description': description,
        'image': eventPhoto,
        'lister': currentUserProfile,
      };
      if (event != null) {
        await event.update(eventData);
      } else {
        await firestore
            .collection('events')
            .add(eventData)
            .then((newEvent) => currentUserIgniterProfile.update({
                  'events': FieldValue.arrayUnion([newEvent]),
                  'igniter_type': 'event_organizer',
                }));
      }
    } on FirebaseException catch (e) {
      log(e.code);
      log(e.message ?? 'No message');
    } catch (e) {
      log(e.toString());
    }
  }
}

class Ticket {
  Ticket(
      {this.title,
      this.price,
      this.image,
      this.available,
      this.description,
      this.quantity});

  String? title;
  double? price;
  String? image;
  bool? available;
  String? description;
  int? quantity;

  // Adds a new ticket
  Future<void> addNewTicket(
      {required DocumentReference event,
      String? ticketName,
      String? description,
      DateTime? expiry,
      double? price,
      int? available}) async {
    bool? isAvailable() {
      if (available == 1) {
        return true;
      } else {
        return false;
      }
    }

    try {
      await event.update({
        'tickets': FieldValue.arrayUnion([
          {
            'ticket_name': ticketName,
            'ticket_description': description,
            'expiry_date': expiry,
            'price': price,
            'available': isAvailable(),
          }
        ]),
      });
    } catch (e) {
      log(e.toString());
    }
  }

// Updates a ticket
  Future<void> updateTicket(
      {required DocumentReference event,
      required Map<String, dynamic> ticket,
      String? ticketName,
      String? description,
      Timestamp? expiry,
      double? price,
      int? available}) async {
    bool? isAvailable() {
      if (available == 1) {
        return true;
      } else {
        return false;
      }
    }

    try {
      await event.update({
        'tickets': FieldValue.arrayRemove([ticket]),
      }).then((value) => event.update({
            'tickets': FieldValue.arrayUnion([
              {
                'ticket_name': ticketName,
                'ticket_description': description,
                'expiry_date': expiry,
                'price': price,
                'available': isAvailable(),
              }
            ]),
          }));
    } catch (e) {
      log(e.toString());
    }
  }
}
