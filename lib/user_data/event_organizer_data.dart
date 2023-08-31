import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/user_data/user_data.dart';

class EventOrganizer extends ChangeNotifier {
  List<EventData>? get events => _events;
  List<EventData>_events = [];
  String? get coverImage => _coverImage;
  String? _coverImage;
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

  // Get Events

  getListedEvents() {
    currentUserIgniterProfile.snapshots().listen((doc) {
      var data = doc.data();
      List<dynamic> userEvents = data?['events'];

      for (DocumentReference eventRef in userEvents) {
        eventRef.get().then((event) {
          var eventData = event.data() as Map<String, dynamic>?;
          List<Ticket>? ticketsList = [];

          for (Map<String, dynamic> ticket in (eventData?['tickets'] as List<dynamic>)) {
            ticketsList.add(Ticket(available: ticket['available'],
            title: ticket['ticket_name'],
            price: ticket['price'],
            image: ticket['image'],
            description: ticket['ticket_description'],
            quantity: ticket['quantity'],
            ));
          }

          _events.add(
            EventData(
              eventName: eventData?['event_name'],
              location: eventData?['location']?['geopoint'],
              category: eventData?['category'],
              date: (eventData?['date'] as Timestamp?)?.toDate(),
              image: eventData?['image'],
              description: eventData?['event_description'],
              eventOrganizer: eventData?['lister'],
              eventReference: eventRef,
              tickets: ticketsList,
            ),
          );
          notifyListeners();
        });
        notifyListeners();
      }
      notifyListeners();
    });
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
      print(e);
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
      print(e);
    }
  }
}
