import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';

class AddressAutocomplete extends StatefulWidget {
  final ValueChanged<String> onAddressSelected;

  final TextEditingController controller;

  const AddressAutocomplete({
    required this.onAddressSelected,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  List<String> _suggestions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: widget.key,
          controller: widget.controller,
          onChanged: _onTextChanged,
          decoration: const InputDecoration(
            labelText: 'Address',
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_suggestions[index]),
              onTap: () {
                widget.onAddressSelected(_suggestions[index]);
                widget.controller.text = _suggestions[index];
                setState(() {
                  _suggestions = [];
                });
              },
            );
          },
        ),
      ],
    );
  }

  void _onTextChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(value);
      List<String> addressLines = [];

      // Darmstadt city center coordinates
      const double darmstadtLatitude = 49.8728;
      const double darmstadtLongitude = 8.6512;

      for (Location location in locations) {
        double distance = _calculateDistance(
          darmstadtLatitude,
          darmstadtLongitude,
          location.latitude,
          location.longitude,
        );

        if (distance <= 300.0) {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );

          String addressLine = '';

          if (placemarks.isNotEmpty) {
            Placemark placemark = placemarks.first;
            addressLine = placemark.street ?? '';
            if (placemark.postalCode != null &&
                placemark.postalCode!.isNotEmpty) {
              addressLine += ', ${placemark.postalCode!}';
            }
            if (placemark.locality != null && placemark.locality!.isNotEmpty) {
              addressLine += ', ${placemark.locality!}';
            }
          }

          addressLines.add(addressLine);
        }
      }

      setState(() {
        _suggestions = addressLines;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
      });
    }
  }

  double _calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadius = 6371.0; // in kilometers

    double lat1 = _degreesToRadians(startLatitude);
    double lon1 = _degreesToRadians(startLongitude);
    double lat2 = _degreesToRadians(endLatitude);
    double lon2 = _degreesToRadians(endLongitude);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}
