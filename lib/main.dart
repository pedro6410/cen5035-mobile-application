import 'package:flutter/material.dart';
import 'widgets/travel_log.dart';

void main() => runApp(CarbonCreditEmployeeApp());

class CarbonCreditEmployeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
      ),
      home: Scaffold( // Wrap Travellog in a Scaffold
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.asset(
                'images/fau_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Content (Travellog)
            Travellog(),
          ],
        ),
      ),

    );
  }
}

