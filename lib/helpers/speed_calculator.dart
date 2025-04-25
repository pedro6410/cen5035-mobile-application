double? calculateAverageSpeed({
  required double startLat,
  required double startLong,
  required double endLat,
  required double endLong,
  required DateTime startTime,
  required DateTime endTime,
  required double Function({
  required double startLatitude,
  required double startLongitude,
  required double endLatitude,
  required double endLongitude,
  }) distanceFunction,
}) {
  final duration = endTime.difference(startTime).inSeconds;


  final distance = distanceFunction(
    startLatitude: startLat,
    startLongitude: startLong,
    endLatitude: endLat,
    endLongitude: endLong,
  );

  final speed = (distance / duration) * 3600;
  print("Speed: $speed");
  return speed;
}
