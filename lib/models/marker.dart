import 'package:flutter/material.dart';

import 'location_data.dart';

class MyMarker extends StatelessWidget {
  const MyMarker(this.customLocationData, {super.key});

  final CustomLocationData customLocationData;

  @override
  Widget build(BuildContext context) {
    // wrap your widget with RepaintBoundary and
    // pass your global key to RepaintBoundary
    return SizedBox(
      height: MediaQuery.of(context).size.width / 10,
      width: MediaQuery.of(context).size.width / 10,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          "${customLocationData.price.toStringAsFixed(2)}€",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
