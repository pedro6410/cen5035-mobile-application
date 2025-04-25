import 'package:geolocator/geolocator.dart';

Future<bool> requestLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("Location services are disabled.");
    return false;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("User denied permission.");
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("Permission permanently denied. Ask user to enable from settings.");
    return false;
  }

  return true; //
}
