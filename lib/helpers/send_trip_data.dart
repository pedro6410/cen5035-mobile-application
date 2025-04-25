import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendTripData({
  required String tripId,
  required String empId,
  required String employerId,
  required double distance,
  required String modeOfTransport,
  required DateTime tripStartTime,
  required DateTime tripEndTime,
  required String carbonCredits,
}) async {
  final url = Uri.parse(
    'https://lwkmm7m4rmy4m33vam2uhvqo6m0trfpa.lambda-url.us-east-1.on.aws/',
  );

  final data = {
    "payload": {
      "trip_id": tripId,
      "trip_date": tripStartTime.toUtc().toIso8601String(),
      "emp_id": empId,
      "employer_id": employerId,
      "distance_miles": distance.toStringAsFixed(2),
      "mode_of_transport": modeOfTransport,
      "start_time": tripStartTime.toUtc().toIso8601String(),
      "end_time": tripEndTime.toUtc().toIso8601String(),
      "carbon_credits": carbonCredits,
    }
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Trip data sent successfully!');
    } else {
      print('Failed to send trip data. Status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print(' Error sending trip data: $e');
  }
}
