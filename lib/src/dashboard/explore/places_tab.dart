import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import 'package:wazzlitt/src/location/location.dart';
import 'package:wazzlitt/src/place/place.dart';
import 'package:wazzlitt/src/registration/interests.dart';
import 'package:wazzlitt/user_data/business_owner_data.dart';
import 'package:wazzlitt/user_data/patrone_data.dart';
import 'package:wazzlitt/user_data/user_data.dart';

class PlacesTab extends StatefulWidget {
  const PlacesTab({
    Key? key,
    required this.categories,
  }) : super(key: key);

  final List<Category> categories;

  @override
  State<PlacesTab> createState() => _PlacesTabState();
}

class _PlacesTabState extends State<PlacesTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToPlace(BuildContext context, BusinessPlace placeData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreamBuilder<List<DocumentSnapshot<Object?>>>(
            stream: getNearbyPeople(
                placeData.location!.latitude, placeData.location!.longitude),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Set<Marker> newMarkers = {};
                if (snapshot.hasData) {
                  for (var patrone in snapshot.data!) {
                    Map<String, dynamic> data =
                        patrone.data() as Map<String, dynamic>;
                    log(data.toString());
                    GeoPoint location = data['current_location']['geopoint'];

                    newMarkers.add(
                      Marker(
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                          infoWindow: InfoWindow(title: data['username']),
                          position:
                              LatLng(location.latitude, location.longitude),
                          markerId:
                              MarkerId(patrone.reference.parent.parent!.id),
                          onTap: () {
                            Patrone()
                                .getPatroneInformation(patrone.reference)
                                .then((value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                        title: Text(value.usernameSet ?? '')),
                                    body: ProfileScreen(
                                      userProfile: value,
                                    ),
                                  ),
                                ),
                              );
                            });
                          }),
                    );
                  }
                }
                return Place(
                  place: placeData,
                  patroneMarkers: newMarkers,
                  patronesAround: snapshot.data!.length,
                );
              } else {
                return Place(
                  place: placeData,
                  patroneMarkers: const {},
                  patronesAround: snapshot.data?.length ?? 0,
                );
              }
            }),
      ),
    );
  }

  List<BusinessPlace> allPlaces = [];

  late Future<List<BusinessPlace>> getPlaceFuture = getAllPlaces();

  Future<List<BusinessPlace>> getPlacesFromGoogle =
      searchBuildings('Clubs near me');

  Future<List<BusinessPlace>> getAllPlaces() async {
    try {
      List<BusinessPlace> placesList = [];
      await firestore.collection('places').get().then((places) {
        for (var place in places.docs) {
          var placeData = place.data();
          List<Service>? servicesList = [];

          if (placeData.containsKey('services')) {
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
            placeReference: place.reference,
            chatroom: placeData['chat_room'],
            phoneNumber: placeData['phone_number'],
            website: placeData['website'],
            services: servicesList,
          );

          if (placesList.contains(foundBusinessPlace)) {
            placesList
                .where((place) =>
                    place.placeReference == foundBusinessPlace.placeReference)
                .toList()
                .forEach((removablePlace) {
              placesList.remove(removablePlace);
            });
          } else {
            placesList.add(foundBusinessPlace);
          }
        }
      });

      return placesList;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Featured Places',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: FutureBuilder<List<BusinessPlace>>(
            future: getPlacesFromGoogle.timeout(const Duration(seconds: 5)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                allPlaces = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: allPlaces.length,
                  itemBuilder: (BuildContext context, int index) {
                    final place = allPlaces[index];
                    return GestureDetector(
                      onTap: () => _navigateToPlace(context, place),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              place.image ??
                                  'https://corsproxy.io/?https://i.pinimg.com/564x/90/0b/c3/900bc32b424bc3b817ff1edd38476991.jpg',
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  place.category ?? 'Not available',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              place.placeName ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                    child: Text('No places are currently available'));
              }
            },
          ),
        ),
      ],
    );
  }
}
