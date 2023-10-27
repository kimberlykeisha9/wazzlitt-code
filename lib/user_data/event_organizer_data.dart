import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/location/location.dart';
import 'package:wazzlitt/user_data/payments.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import 'order_data.dart' as wz;

List<String> eventOrganizerCategories = [
  'Event Organizer',
  'Dancer',
  'Rapper',
  'Singer',
  'Entertainer',
];

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
  Future<void> getCurrentUserEventOrganizerInformation() async {
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
      final List<dynamic> userEvents = data?['events'] ?? [];
      final List<EventData> listedEvents = [];

      if (userEvents.isNotEmpty) {
        for (DocumentReference eventRef in userEvents) {
          final event = await eventRef.get();
          var eventData = event.data() as Map<String, dynamic>?;
          List<Ticket>? ticketsList = [];
          final List<wz.Order> eventOrders = [];

          final orders = await firestore
              .collection('orders')
              .where('event', isEqualTo: eventRef)
              .get();

          for (QueryDocumentSnapshot<Map<String, dynamic>> order
              in orders.docs) {
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
                map: ticket,
                paymentURL: ticket['paymentLink']['url'],
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
                .where((event) =>
                    event.eventReference == foundEvent.eventReference)
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
      }
      return listedEvents;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  // Saves Event Organizer Profile
  Future<void> saveEventOrganizerProfile({
    required String? organizerCategory,
    required String? organizerName,
    String? website,
    required String? category,
    required String? description,
    String? emailAddress,
    String? phoneNumber,
    String? profilePhoto,
    String? coverPhoto,
  }) async {
    try {
      Map<String, dynamic> organizerData = {
        'organizer_name': organizerName?.trim(),
        'organizer_category': organizerCategory,
        'website': website,
        'igniter_type': 'event_organizer',
        'category': category,
        'organizer_description': description,
        'email_address': emailAddress,
        'phone_number': phoneNumber,
        'image': profilePhoto,
        'cover_image': coverPhoto,
      };
      currentUserIgniterProfile.get().then((value) async {
        if (value.exists) {
          await currentUserIgniterProfile.update(organizerData);
        } else {
          currentUserProfile.update({'is_igniter': true}).then((value) async {
            await currentUserIgniterProfile.set(organizerData).then((value) =>
                currentUserIgniterProfile
                    .update({'createdAt': DateTime.now()}));
          });
        }
      });
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
      double? latitude,
      double? longitude,
      String? eventPhoto,
      DateTime? date}) async {
    try {
      var eventData = {
        'event_name': eventName?.trim(),
        'category': category,
        'date': date,
        'event_description': description,
        'image': eventPhoto,
        'lister': currentUserProfile,
      };
      if (event != null) {
        await event.update(eventData).then((value) {
          uploadLocation(event, latitude!, longitude!);
        });
      } else {
        await listEventProductOnStripe(eventName!.trim(), true, description)
            .then((response) async {
          await firestore
              .collection('events')
              .add(eventData)
              .then((newEvent) async {
            await newEvent.update({'stripeReference': response});
            await currentUserIgniterProfile.update({
              'events': FieldValue.arrayUnion([newEvent]),
              'igniter_type': 'event_organizer',
            });
            uploadLocation(newEvent, latitude!, longitude!);
          });
        });
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
      this.map,
      this.paymentURL,
      this.quantity});

  String? title;
  String? paymentURL;
  Map<String, dynamic>? map;
  double? price;
  String? image;
  bool? available;
  String? description;
  int? quantity;

  // Delete a ticket
  Future<void> deleteTicket(DocumentReference event, Ticket ticket) async {
    try {
      await event.update({
        'tickets': FieldValue.arrayRemove([ticket.map]),
      });
    } on Exception catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

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
      await currentUserProfile.get().then((value) async {
        Map<String, dynamic> data = value.data() as Map<String, dynamic>;
        String? accountID = data['stripeAccountID'];
        await addPriceToProduct(event, accountID ?? '', price.toString())
            .then((response) async {
          await getProductPaymentLink(accountID!, response!['id'], 1)
              .then((value) async {
            await event.update({
              'tickets': FieldValue.arrayUnion([
                {
                  'paymentLink': value,
                  'stripeReference': response,
                  'ticket_name': ticketName,
                  'ticket_description': description,
                  'expiry_date': expiry,
                  'price': price,
                  'available': isAvailable(),
                }
              ]),
            });
          });
        });
      });
    } catch (e) {
      log(e.toString());
    }
  }

// Updates a ticket
  Future<void> updateTicket(
      {required DocumentReference event,
      required Ticket ticket,
      String? ticketName,
      String? description,
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
        'tickets': FieldValue.arrayRemove([
          {
            'ticket_name': ticket.title,
            'ticket_description': ticket.description,
            'price': ticket.price,
            'available': ticket.available
          }
        ]),
      }).then((value) => event.update({
            'tickets': FieldValue.arrayUnion([
              {
                'ticket_name': ticketName,
                'ticket_description': description,
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
