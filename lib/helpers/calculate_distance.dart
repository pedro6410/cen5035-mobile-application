import 'dart:math';

double calculateDistance({
  required double startLatitude,
  required double startLongitude,
  required double endLatitude,
  required double endLongitude,
}) {
  const earthRadius = 3958.8;

  final lat1 = startLatitude;
  final lon1 = startLongitude;
  final lat2 = endLatitude;
  final lon2 = endLongitude;

  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _degToRad(double deg) => deg * pi / 180;
