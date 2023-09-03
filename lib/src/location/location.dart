import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire_updated/geoflutterfire_updated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wazzlitt/user_data/business_owner_data.dart';
import '../../user_data/patrone_data.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<BusinessPlace?>> searchBuildings(String query) async {
  final apiKey = "AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ";
  final apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  try {
    List<BusinessPlace> _results = [];
    final response =
        await http.get(Uri.parse('$apiUrl?address=$query&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        for (var result in (data['results'] as List<dynamic>)) {
          final location = result['geometry']['location'];
          final streetName = result['formatted_address'];
          final latitude = location['lat'];
          final longitude = location['lng'];
          print(location);
          print(streetName);
          _results.add(BusinessPlace(
              location: GeoPoint(latitude, longitude),
              placeName: streetName));
        }
        return _results;
      } else {
        // No results found
        print('No result found');
        return _results;
      }
    } else {
      // Handle HTTP error
      print('No result found cause of HTTP error');
      return _results;
    }
  } catch (e) {
    // Handle other exceptions, e.g., network errors
    print(e);
    throw Exception(e);
  }
}

var geo = Geoflutterfire();

Stream<List<DocumentSnapshot>> getNearbyPeople(
    double latitude, double longitude) {
  GeoFirePoint place = geo.point(latitude: latitude, longitude: longitude);
  // Locations of users
  var usersLocations = firestore.collectionGroup('account_type');
  print(geo
      .collection(collectionRef: usersLocations)
      .within(center: place, radius: 5, field: 'current_location')
      .length);
  return geo
      .collection(collectionRef: usersLocations)
      .within(center: place, radius: 5, field: 'current_location');
}

Future<String> getLocationForPlace(DocumentReference place) async {
  String serverLocation = '';
  await place.get().then((data) async {
    if (data.exists) {
      Map<String, dynamic> placeData = data.data() as Map<String, dynamic>;
      GeoPoint? location = placeData['location']['geopoint'];
      if (location != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude);
        Placemark placemark = placemarks
            .where((placemark) => !(placemark.name!.contains('+')))
            .toList()[0];

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

Future<void> uploadLocation(
    DocumentReference reference, double latitude, double longitude) async {
  try {
    GeoFirePoint geoPoint = geo.point(latitude: latitude, longitude: longitude);

    await reference.update({
      'location': geoPoint.data,
    });
  } catch (e) {
    log(e.toString());
  }
}

Future<void> uploadCurrentLocation() async {
  try {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      LocationPermission permissionStatus =
          await Geolocator.requestPermission();
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

    GeoFirePoint geoPoint =
        geo.point(latitude: position.latitude, longitude: position.longitude);

    await Patrone().currentUserPatroneProfile.update({
      'current_location': geoPoint.data,
    });
  } catch (e) {
    log(e.toString());
  }
}
