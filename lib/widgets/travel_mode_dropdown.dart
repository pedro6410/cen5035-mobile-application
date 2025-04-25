import 'package:flutter/material.dart';

class TravelModeDropdown extends StatefulWidget {
  final ValueChanged<String> onModeChanged;

  TravelModeDropdown({required this.onModeChanged});

  @override
  _TravelModeDropdownState createState() => _TravelModeDropdownState();
}

class _TravelModeDropdownState extends State<TravelModeDropdown> {
  final List<String> travelModes = ['Driving', 'Carpooling', 'Ridesharing'];
  String selected = 'Driving';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selected,
      isExpanded: true,
      items: travelModes.map((mode) {
        return DropdownMenuItem<String>(
          value: mode,
          child: Text(mode),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selected = newValue!;
        });
        widget.onModeChanged(selected); // Send selected mode back to parent
      },
    );
  }
}
