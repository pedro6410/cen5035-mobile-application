import 'dart:math';

String generateTripId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final idSuffix = (timestamp % 1000000).toString().padLeft(6, '0');
  return 'TRIP$idSuffix';
}
