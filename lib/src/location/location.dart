import 'dart:developer';

import 'package:geoflutterfire_updated/geoflutterfire_updated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:wazzlitt/user_data/business_owner_data.dart';
import '../../user_data/patrone_data.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<BusinessPlace> getPlaceDetailsFromGoogle(String placeID) async {
  const apiUrl =
      'https://corsproxy.io/?https://maps.googleapis.com/maps/api/place/details/json';
  const apiKey = "AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ";

  BusinessPlace googlePlace = BusinessPlace();
  final response = await http.get(Uri.parse(
      '$apiUrl?place_id=$placeID&key=$apiKey&fields=name,formatted_address,geometry,website,international_phone_number,photos'));

  log(response.statusCode.toString());

  log('Place response is: ${json.decode(response.body)}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    log(data);


    if (data['status'] == 'OK' && data['result'].isNotEmpty) {
      var result = data['result'];
      final location = result['geometry']['location'];
      final streetName = result['name'];
      final latitude = location['lat'];
      final longitude = location['lng'];
      final firstPhoto = result['photos']?[0]?['photo_reference'];
      // final secondPhoto = result['photos']?[1]?['photo_reference'];

      log(location);
      log(streetName);
      googlePlace = BusinessPlace(
          googleId: placeID,
          phoneNumber: result['international_phone_number'],
          formattedAddress: result['formatted_address'],
          website: result['website'],
          openingTime: DateTime(
              1,
              1,
              1,
              (int.tryParse((result['current_opening_hours']?['periods']?[0]['open']?['time']).toString().substring(0, 2)) ??
                  0),
              int.tryParse((result['current_opening_hours']?['periods']?[0]['open']?['time']).toString().substring(2)) ??
                  0),
          closingTime: DateTime(
              1,
              1,
              1,
              (int.tryParse((result['current_opening_hours']?['periods']?[0]['close']?['time'])
                      .toString()
                      .substring(0, 2)) ??
                  0),
              int.tryParse((result['current_opening_hours']?['periods']?[0]['close']?['time']).toString().substring(2)) ??
                  0),
          image: firstPhoto != null
              ? 'https://maps.googleapis.com/maps/api/place/photo?key=$apiKey&photoreference=$firstPhoto&maxwidth=400'
              : null,
          coverImage: firstPhoto != null
              ? 'https://maps.googleapis.com/maps/api/place/photo?key=$apiKey&photoreference=$firstPhoto&maxwidth=400'
              : null,
          location: GeoPoint(latitude, longitude),
          placeName: streetName);
      return googlePlace;
    } else {
      // No results found
      log('No result found');
      return googlePlace;
    }
  } else {
    // Handle HTTP error
    log('No result found cause of HTTP error');
    return googlePlace;
  }
}

Future<List<BusinessPlace>> searchBuildings(String query) async {
  const apiKey = "AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ";
  const apiUrl =
      'https://corsproxy.io/?https://maps.googleapis.com/maps/api/place/textsearch/json';

  List<BusinessPlace> results = [];
  final response = await http.get(Uri.parse(
      '$apiUrl?query=$query&key=$apiKey&maxResults=10&&fields=place_id'));

  log(response.statusCode.toString());

  log('Search response is: ${json.decode(response.body)}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      for (var result in (data['results'] as List<dynamic>)) {
        log(result['place_id']);

        await getPlaceDetailsFromGoogle(result['place_id'])
            .then((place) => results.add(place));
      }
      if (results.length == 5) {
        return results;
      }
      return results;
    } else {
      // No results found
      log('No result found');
      return results;
    }
  } else {
    // Handle HTTP error
    log('No result found cause of HTTP error');
    return results;
  }
}

var geo = Geoflutterfire();

Stream<List<DocumentSnapshot>> getNearbyPeople(
    double latitude, double longitude) {
  GeoFirePoint place = geo.point(latitude: latitude, longitude: longitude);
  // Locations of users
  var usersLocations = firestore.collectionGroup('account_type');
  log(geo
      .collection(collectionRef: usersLocations)
      .within(center: place, radius: 5, field: 'current_location')
      .length.toString());
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
        const String googelApiKey = 'AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ';
        const bool isDebugMode = true;
        final api = GoogleGeocodingApi(googelApiKey, isLogged: isDebugMode);
        final reversedSearchResults = await api.reverse(
          '${location.latitude},${location.longitude}',
          language: 'en',
        );

        serverLocation = reversedSearchResults
            .results.first.addressComponents.first.longName;
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
        log('Location permissions are permanently denied.');
      }
    }

    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      log('Location permissions are denied.');
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
