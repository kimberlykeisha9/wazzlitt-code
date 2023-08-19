import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire_updated/geoflutterfire_updated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wazzlitt/user_data/user_data.dart';

var geo = Geoflutterfire();

Stream<List<DocumentSnapshot>> getNearbyPeople(double latitude, double
longitude) {
  GeoFirePoint place = geo.point(latitude: latitude, longitude: longitude);
  // Locations of users
  var usersLocations = firestore.collectionGroup('account_type');
  print(geo.collection(collectionRef: usersLocations).within(center: place,
      radius: 5000, field: 'current_location').length);
  return geo.collection(collectionRef: usersLocations).within(center: place,
      radius: 5000, field: 'current_location');
}

Future<String> getLocationForPlace(DocumentReference place) async {
  String serverLocation = '';
  await place.get().then((data) async {
    if (data.exists) {
      Map<String, dynamic> placeData = data.data() as Map<String, dynamic>;
      GeoPoint? location = placeData['location'];
      if (location != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude);
        Placemark placemark =  placemarks.where((placemark) => !(placemark.name!.contains('+'))).toList()[0];

        serverLocation = '${placemark.name}, ${placemark.country}';
      } else {
        serverLocation = 'Not available';
      }
    } else {
      serverLocation = 'Not available';
    }
  });
  return serverLocation;
}

Future<void> uploadPlaceLocation(DocumentReference place, double latitude,
double longitude) async {
  try {
    GeoFirePoint geoPoint = geo.point(latitude: latitude, longitude:
    longitude);

    await place.update({
      'location': geoPoint.data,
    });
  } catch (e) {
    log(e.toString());
  }
}

Future<void> uploadLocation() async {
  try {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      LocationPermission permissionStatus = await Geolocator.requestPermission();
      if (permissionStatus == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
      }
    }

    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      print('Location permissions are denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    GeoFirePoint geoPoint = geo.point(latitude: position.latitude, longitude:
    position.longitude);

    await currentUserPatroneProfile.update({
      'current_location': geoPoint.data,
    });
  } catch (e) {
    log(e.toString());
  }
}