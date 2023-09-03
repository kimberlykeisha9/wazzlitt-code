import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'order_data.dart' as wz;

import '../src/location/location.dart';
import 'user_data.dart';

var firestore = FirebaseFirestore.instance;

class BusinessOwner extends ChangeNotifier {
  List<BusinessPlace> get listings => _listings;
  final List<BusinessPlace> _listings = [];

  Future<List<BusinessPlace>> getListedBusiness() async {
    try {
      final doc = await currentUserIgniterProfile.get();
      final data = doc.data();
      final List<BusinessPlace> listedBusinesses = [];
      final List<dynamic> listings = data?['listings'];

      for (DocumentReference listing in listings) {
        final place = await listing.get();
        final placeData = place.data() as Map<String, dynamic>?;
        final List<Service> servicesList = [];
        final List<wz.Order> placeOrders = [];

        final orders = await firestore
            .collection('orders')
            .where('place', isEqualTo: listing)
            .get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> order in orders.docs) {
          final orderData = order.data();
          placeOrders.add(
            wz.Order(
              datePlaced: (orderData['date_placed'] as Timestamp).toDate(),
              details: orderData['service'],
              orderID: orderData['order_id'],
              paymentType: orderData['payment_type'],
              orderType: wz.OrderType.service,
              reference: orderData['place'],
            ),
          );
        }

        if (placeData!.containsKey('services')) {
          for (Map<String, dynamic> service
              in (placeData['services'] as List<dynamic>)) {
            servicesList.add(Service(
              available: service['available'],
              title: service['service_name'],
              price: service['price'],
              image: service['image'],
              description: service['service_description'],
              quantity: service['quantity'],
            ));
          }
        }

        final BusinessPlace foundBusinessPlace = BusinessPlace(
          placeName: placeData['place_name'],
          location: placeData['location']['geopoint'],
          category: placeData['category'],
          placeType: placeData['place_type'],
          closingTime: (placeData['closing_time'] as Timestamp?)?.toDate(),
          openingTime: (placeData['opening_time'] as Timestamp?)?.toDate(),
          emailAddress: placeData['email_address'],
          image: placeData['image'],
          coverImage: placeData['cover_image'],
          description: placeData['place_description'],
          lister: placeData['lister'],
          placeReference: listing,
          chatroom: placeData['chat_room'],
          phoneNumber: placeData['phone_number'],
          website: placeData['website'],
          services: servicesList,
          orders: placeOrders,
        );

        if (listedBusinesses.contains(foundBusinessPlace)) {
          listedBusinesses
              .where((place) =>
                  place.placeReference == foundBusinessPlace.placeReference)
              .toList()
              .forEach((removablePlace) {
            listedBusinesses.remove(removablePlace);
          });
          print('Removed listing. New value is ${listedBusinesses.length}');
        } else {
          listedBusinesses.add(foundBusinessPlace);
          print('Added listing. New value is ${listedBusinesses.length}');
        }
      }
      return listedBusinesses;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}

class BusinessPlace {
  BusinessPlace({
    this.placeName,
    this.location,
    this.category,
    this.placeType,
    this.closingTime,
    this.openingTime,
    this.emailAddress,
    this.image,
    this.coverImage,
    this.description,
    this.lister,
    this.placeReference,
    this.chatroom,
    this.phoneNumber,
    this.website,
    this.services,
    this.orders,
  });

  String? placeName;
  GeoPoint? location;
  String? category;
  String? placeType;
  DateTime? closingTime;
  DateTime? openingTime;
  String? emailAddress;
  String? image;
  String? coverImage;
  String? description;
  DocumentReference? lister;
  DocumentReference? placeReference;
  DocumentReference? chatroom;
  String? phoneNumber;
  String? website;
  List<Service>? services = [];
  List<wz.Order>? orders = [];

  Future<void> savePlaceProfile({
    DocumentReference? place,
    String? businessName,
    String? website,
    String? category,
    String? description,
    String? emailAddress,
    String? phoneNumber,
    String? profilePhoto,
    String? coverPhoto,
    double? latitude,
    double? longitude,
    Timestamp? openingTime,
    Timestamp? closingTime,
    String? placeType,
  }) async {
    try {
      final placeData = {
        'place_name': businessName?.trim(),
        'website': website,
        'category': category,
        'place_description': description,
        'email_address': emailAddress,
        'phone_number': phoneNumber,
        'image': profilePhoto,
        'cover_image': coverPhoto,
        'opening_time': openingTime,
        'closing_time': closingTime,
        'lister': currentUserProfile,
        'place_type': placeType,
      };
      if (place != null) {
        await place.update(placeData).then((value) {
          log('Uploaded place data');
          uploadPlaceLocation(place, latitude!, longitude!);
        });
      } else {
        await firestore
            .collection('places')
            .add(placeData)
            .then((newPlace) => currentUserIgniterProfile.get().then((value) {
                  if (value.exists) {
                    currentUserIgniterProfile.update({
                      'listings': FieldValue.arrayUnion([newPlace]),
                      'igniter_type': 'business_owner'
                    }).then(
                      (_) => firestore.collection('messages').add({
                        'owner': newPlace,
                        'welcome_message': 'Hi welcome to our chat room',
                        'last_message': null,
                      }).then((chatroom) {
                        newPlace.update({
                          'chat_room': chatroom,
                        });
                        uploadPlaceLocation(newPlace, latitude!, longitude!);
                      }),
                    );
                  } else {
                    currentUserProfile.update({'is_igniter': true});
                    currentUserIgniterProfile.set({
                      'listings': FieldValue.arrayUnion([newPlace]),
                      'igniter_type': 'business_owner',
                      'createdAt': DateTime.now(),
                    }).then(
                      (_) => firestore.collection('messages').add({
                        'owner': newPlace,
                        'welcome_message': 'Hi welcome to our chat room',
                        'last_message': null,
                      }).then((chatroom) {
                        newPlace.update({
                          'chat_room': chatroom,
                        });
                        uploadPlaceLocation(chatroom, latitude!, longitude!);
                      }),
                    );
                  }
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

class Service {
  String? title;
  double? price;
  String? image;
  bool? available;
  String? description;
  int? quantity;

  Service({
    this.title,
    this.price,
    this.image,
    this.available,
    this.description,
    this.quantity,
  });

  Future<void> updateService({
    required DocumentReference place,
    required Map<String, dynamic> service,
    required String serviceName,
    required String description,
    String? image,
    required double price,
    required int available,
  }) async {
    bool? isAvailable() {
      return available == 1;
    }

    try {
      await place.update({
        'services': FieldValue.arrayRemove([service]),
      }).then((value) => place.update({
            'services': FieldValue.arrayUnion([
              {
                'service_name': serviceName,
                'service_description': description,
                'image': image,
                'price': price,
                'available': isAvailable(),
              }
            ]),
          }));
    } catch (e) {
      print(e);
    }
  }

  Future<void> addNewService({
    required DocumentReference place,
    String? serviceName,
    String? description,
    String? image,
    double? price,
    int? available,
  }) async {
    bool? isAvailable() {
      return available == 1;
    }

    try {
      await place.update({
        'services': FieldValue.arrayUnion([
          {
            'service_name': serviceName,
            'service_description': description,
            'image': image,
            'price': price,
            'available': isAvailable(),
          }
        ]),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteService(
      Map<String, dynamic> service, DocumentReference place) async {
    try {
      await place.update({
        'services': FieldValue.arrayRemove([service]),
      });
    } on Exception catch (e) {
      print(e);
    }
  }
}
