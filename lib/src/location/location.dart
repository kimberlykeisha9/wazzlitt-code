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

const apiKey = "AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ";

Future<BusinessPlace> getPlaceDetailsFromGoogle(String placeID) async {
  try {
    const apiUrl =
        'https://corsproxy.io/?https://maps.googleapis.com/maps/api/place/details/json';

    BusinessPlace googlePlace = BusinessPlace();
    final response = await http.get(Uri.parse(
        '$apiUrl?place_id=$placeID&key=$apiKey&fields=name,formatted_address,geometry,website,international_phone_number,photos,types'));

    log(response.statusCode.toString());

    log('Place response is: ${jsonDecode(response.body.toString())}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body.toString()) as Map<String, dynamic>;

      if (data['status'] == 'OK' && data.containsKey('result')) {
        var result = data['result'] as Map<String, dynamic>;
        final location = result['geometry']['location'] as Map<String, dynamic>;
        final streetName = result['name'];
        final latitude = location['lat'];
        final longitude = location['lng'];
        final category = ((result['types']?[0] as String?) ?? '').replaceAll(RegExp(r'(\W)'), ' ');
        final firstPhoto = result['photos']?[0]?['photo_reference'];

        log(location.toString());
        log(streetName);

        final openingTime =
            result['opening_hours']?['periods']?[0]?['open']?['time'];
        final closingTime =
            result['opening_hours']?['periods']?[0]?['close']?['time'];

        googlePlace = BusinessPlace(
          category: category,
          googleId: placeID,
          phoneNumber: result['international_phone_number'],
          formattedAddress: result['formatted_address'],
          website: result['website'],
          openingTime: DateTime(
            1,
            1,
            1,
            int.tryParse(openingTime?.substring(0, 2) ?? '0') ?? 0,
            int.tryParse(openingTime?.substring(2) ?? '0') ?? 0,
          ),
          closingTime: DateTime(
            1,
            1,
            1,
            int.tryParse(closingTime?.substring(0, 2) ?? '0') ?? 0,
            int.tryParse(closingTime?.substring(2) ?? '0') ?? 0,
          ),
          image: firstPhoto != null
              ? 'https://corsproxy.io/?https://maps.googleapis.com/maps/api/place/photo?key=$apiKey&photoreference=$firstPhoto&maxwidth=400'
              : null,
          coverImage: firstPhoto != null
              ? 'https://corsproxy.io/?https://maps.googleapis.com/maps/api/place/photo?key=$apiKey&photoreference=$firstPhoto&maxwidth=400'
              : null,
          location: GeoPoint(latitude, longitude),
          placeName: streetName,
        );
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
  } on Exception catch (e) {
    log('Error from Places API Search: ${e.toString()}');
    throw Exception(e);
  }
}

Future<List<BusinessPlace>> searchBuildings(String query) async {
  const apiUrl =
      'https://corsproxy.io/?https://maps.googleapis.com/maps/api/place/textsearch/json';

  List<BusinessPlace> results = [];
  final response = await http.get(
    Uri.parse('$apiUrl?query=$query&key=$apiKey&maxResults=10&fields=place_id'),
  );

  log(response.statusCode.toString());

  log('Search response is: ${jsonDecode(response.body.toString())}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body.toString()) as Map<String, dynamic>;

    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      final placeIds = (data['results'] as List<dynamic>)
          .map((result) => result['place_id'] as String)
          .toList();

      // Use Future.wait to perform multiple asynchronous operations and handle timeouts.
      final placeFutures = placeIds.map((placeId) {
        return getPlaceDetailsFromGoogle(placeId)
            .timeout(const Duration(seconds: 1));
      });

      final placeResults = await Future.wait(placeFutures);

      results.addAll(placeResults);

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
      .length
      .toString());
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
