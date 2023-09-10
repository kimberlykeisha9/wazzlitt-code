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

Future<BusinessPlace> getPlaceDetailsFromGoogle(String placeID) async {
  final apiUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
  final apiKey = "AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ";

  BusinessPlace googlePlace = BusinessPlace();
  final response =
      await http.get(Uri.parse('$apiUrl?place_id=$placeID&key=$apiKey'));

  print(response.statusCode);

  print('Place response is: ${json.decode(response.body)}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);

    String imagesURL = 'https://maps.googleapis'
        '.com/maps/api/place/photo/?key=$apiKey&photo_reference=';

    if (data['status'] == 'OK' && data['result'].isNotEmpty) {
      var result = data['result'];
      final location = result['geometry']['location'];
      final streetName = result['name'];
      final latitude = location['lat'];
      final longitude = location['lng'];
      final firstPhoto = result['photos']?[0]?['photo_reference'];
      // final secondPhoto = result['photos']?[1]?['photo_reference'];

      print(location);
      print(streetName);
      googlePlace = BusinessPlace(
          phoneNumber: result['international_phone_number'],
          formattedAddress: result['formatted_address'],
          website: result['website'],
          openingTime: DateTime(
              1,
              1,
              1,
              (int.tryParse((result['current_opening_hours']?['periods']?[0]
                          ['open']?['time'])
                      .toString()
                      .substring(0, 2)) ??
                  0),
              int.tryParse((result['current_opening_hours']?['periods']?[0]
                          ['open']?['time'])
                      .toString()
                      .substring(2)) ??
                  0),
          closingTime: DateTime(
              1,
              1,
              1,
              (int.tryParse((result['current_opening_hours']?['periods']?[0]
                          ['close']?['time'])
                      .toString()
                      .substring(0, 2)) ??
                  0),
              int.tryParse((result['current_opening_hours']?['periods']?[0]
                          ['close']?['time'])
                      .toString()
                      .substring(2)) ??
                  0),
          image: firstPhoto != null ? 
          'https://maps.googleapis.com/maps/api/place/photo?key=$apiKey&photoreference=$firstPhoto&maxwidth=400'
           : null,
           coverImage: firstPhoto != null ? 
          'https://maps.googleapis.com/maps/api/place/photo?key=$apiKey&photoreference=$firstPhoto&maxwidth=400'
           : null,
          location: GeoPoint(latitude, longitude),
          placeName: streetName);
      return googlePlace;
    } else {
      // No results found
      print('No result found');
      return googlePlace;
    }
  } else {
    // Handle HTTP error
    print('No result found cause of HTTP error');
    return googlePlace;
  }
}

Future<List<BusinessPlace?>?> searchBuildings(String query) async {
  final apiKey = "AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ";
  final apiUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json';

  List<BusinessPlace> _results = [];
  final response =
      await http.get(Uri.parse('$apiUrl?query=$query&key=$apiKey&maxresults=10'));

  print(response.statusCode);

  print('Search response is: ${json.decode(response.body)}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      for (var result in (data['results'] as List<dynamic>)) {
        print(result['place_id']);

        await getPlaceDetailsFromGoogle(result['place_id'])
            .then((place) => _results.add(place));
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
  return geo.collection(collectionRef: usersLocations).within(
      center: place, radius: 5, field: 'current_location', strictMode: true);
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
