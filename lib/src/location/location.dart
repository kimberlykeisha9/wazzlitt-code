import 'package:location/location.dart';

getLocationInfo() async {
  final location = await getLocation();
  print("Location: ${location.latitude}, ${location.longitude}");
}
