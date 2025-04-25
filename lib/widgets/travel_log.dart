import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/speed_calculator.dart';
import 'login_logout_widget.dart';
import '../helpers/request_location_permission.dart';
import '../helpers/calculate_distance.dart';
import '../helpers/generate_tripId.dart';
import '../helpers/send_trip_data.dart';
import 'travel_mode_dropdown.dart';


class Travellog extends StatefulWidget {
  @override
  _TravelLogState createState() => _TravelLogState();
}

class _TravelLogState extends State<Travellog> {
  bool tripStarted = false;
  late Timer _timer;
  int elapsedSeconds = 0;

  DateTime? tripStartTimeCurrentTimeZone;
  DateTime? tripEndTimeCurrentTimeZone;

  DateTime? tripStartTime;
  DateTime? tripEndTime;

  double? startLatitude;
  double? startLongitude;
  double? endLatitude;
  double? endLongitude;
  String tripId = '';
  //String empId = "AB1234";
  //String employerId = "XY9999";
  String empId = "";
  String employerId = "";
  String modeOfTransport = '1';
  String displayString = 'Trip not started';
  String earnedCarbonCreditString = '';
  double earnedCarbonCredit = 0;
  int loginStatus = 0;
  bool showTripModeOption = false;
  double? tripAvgSpeed;




  Future<void> startTrip() async {
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      tripStarted = true;
      elapsedSeconds = 0;
      tripStartTimeCurrentTimeZone = DateTime.now();
      tripStartTime = DateTime.now().toUtc();
      startLatitude = position.latitude;
      startLongitude = position.longitude;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
        displayString = 'Elapsed Time: ${formatTime(elapsedSeconds)}';
        showTripModeOption = false;
      });
    });
  }



  Future<void> endTrip() async{
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      tripStarted = false;
      tripEndTimeCurrentTimeZone = DateTime.now();
      tripEndTime = DateTime.now().toUtc();
      endLatitude = position.latitude;
      endLongitude = position.longitude;
      tripId = generateTripId();
      displayString = 'Trip ended';
    });

    _timer.cancel();
    print('*************************');
    print('tripId: $tripId');
    print("start timestamp: $tripStartTimeCurrentTimeZone" );
    print("start timestamp UTC: $tripStartTime");
    print("end timestamp: $tripEndTimeCurrentTimeZone");
    print("end timestamp: $tripEndTime");
    print("--------------------------");
    print("startLatitude: $startLatitude");
    print("startLongitude: $startLongitude");
    print("endLatitude: $endLatitude");
    print("endLongitude: $endLongitude");
    double distance = calculateDistance(
      startLatitude: startLatitude!,
      startLongitude: startLongitude!,
      endLatitude: endLatitude!,
      endLongitude: endLongitude!,
    );
    print("distance: $distance");
    print("modeOfTransport: $modeOfTransport");
    if (double.parse(modeOfTransport) != 1.0){
      earnedCarbonCredit = double.parse(modeOfTransport) * distance;
    }else{
      earnedCarbonCredit =0.0;
    }
    earnedCarbonCreditString = earnedCarbonCredit.toString();

    print("earnedCarbonCreditString: $earnedCarbonCreditString");


    tripAvgSpeed = calculateAverageSpeed(
      startLat: startLatitude!,
      startLong: startLongitude!,
      endLat: endLatitude!,
      endLong: endLongitude!,
      startTime: tripStartTime!,
      endTime: tripEndTime!,
      distanceFunction: calculateDistance,
    );


    setState(() {
      showTripModeOption = true;
    });


  }

  void handleLoginStatusChange(int status) {
    setState(() {
      loginStatus = status;
      print('Login status changed to: $status');

      if (status == 0){
        setState(() {
          showTripModeOption = false;
        });

      }

    });
  }

  void handleUserData(String eId, String erId) {
    setState(() {
      empId = eId;
      employerId = erId;
    });
  }


  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }


  Future<void> submitTrip() async {
    double distance = calculateDistance(
      startLatitude: startLatitude!,
      startLongitude: startLongitude!,
      endLatitude: endLatitude!,
      endLongitude: endLongitude!,
    );


    if (tripAvgSpeed != null) {
      if (tripAvgSpeed! < 5) {
        modeOfTransport = '4';
      } else if (tripAvgSpeed! < 12) {
        modeOfTransport = '5';
      }
    }

    if (double.parse(modeOfTransport) != 1.0) {
      earnedCarbonCredit = double.parse(modeOfTransport) * distance;
    } else {
      earnedCarbonCredit = 0.0;
    }
    earnedCarbonCreditString = earnedCarbonCredit.toString();

    print("Submitting with mode: $modeOfTransport, distance: $distance");

    await sendTripData(
       tripId: tripId,
       empId: empId,
       employerId: employerId,
       distance: distance,
       modeOfTransport: modeOfTransport,
       tripStartTime: tripStartTime!,
       tripEndTime: tripEndTime!,
       carbonCredits: earnedCarbonCreditString,
     );

    setState(() {
      showTripModeOption = false;
      displayString = 'Trip submitted!';
    });
  }



  @override
  void dispose() {
    if (tripStarted) {
      _timer.cancel();
    }
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/fau_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.85),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Travel Logger app'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 150,
                  child: LoginLogoutWidget(
                    onLoginStatusChanged: handleLoginStatusChange,
                    onUserDataReceived: handleUserData,
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loginStatus == 0 || tripStarted ? null : startTrip,
                  child: Text('Start Trip'),
                ),

                SizedBox(height: 20),

                if (showTripModeOption)
                  Column(
                    children: [
                      if (tripAvgSpeed == null)
                        Text("**** Error: Invalid speed",
                            style: TextStyle(color: Colors.white)),
                      if (tripAvgSpeed != null && tripAvgSpeed! < 5)
                        Text("Travel Mode: Walk",
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                      if (tripAvgSpeed != null &&
                          tripAvgSpeed! >= 5 &&
                          tripAvgSpeed! < 12)
                        Text("Travel Mode: Bike",
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                      if (tripAvgSpeed != null && tripAvgSpeed! >= 12)
                        SizedBox(
                          width: 300,
                          child: TravelModeDropdown(
                            onModeChanged: (String selectedMode) {
                              setState(() {
                                if (selectedMode == 'Driving') {
                                  modeOfTransport = '1';
                                } else if (selectedMode == 'Carpooling') {
                                  modeOfTransport = '2';
                                } else if (selectedMode == 'Ridesharing') {
                                  modeOfTransport = '3';
                                }
                              });
                              print("modeOfTransport = $modeOfTransport");
                            },
                          ),
                        ),
                      SizedBox(height: 10),

                      // Submit Trip button
                      ElevatedButton(
                        onPressed: submitTrip,
                        child: Text("Submit Trip"),
                      ),
                    ],
                  ),

                SizedBox(height: 20),

                // Timer or Status Text
                Text(
                  displayString,
                  style: TextStyle(fontSize: 20),
                ),

                SizedBox(height: 20),

                // End Trip button
                ElevatedButton(
                  onPressed: tripStarted ? endTrip : null,
                  child: Text('End Trip'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}
