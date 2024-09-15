import 'package:flutter/material.dart';
import 'package:myapp/models/globals.dart';

class FilterOptions {
  Future<bool> showFilterOptions(BuildContext context) async =>
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          // Create filter options instance
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text(
                  'Filter Options',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Radius: ${Globals.radius.toStringAsFixed(2)} km',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        Slider(
                          value: Globals.radius,
                          min: 1.0,
                          max: 50.0,
                          divisions: 50,
                          onChanged: (value) {
                            setState(() {
                              Globals.radius = value;
                            });
                          },
                        ),
                        Text(
                          'Maximum Price per Hour: ${Globals.filterPrice.toStringAsFixed(2)} €',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        Slider(
                          value: Globals.filterPrice,
                          min: 0.0,
                          max: 5.0,
                          divisions: 50,
                          onChanged: (value) {
                            setState(() {
                              Globals.filterPrice = value;
                            });
                          },
                        ),
                        CheckboxListTile(
                          value: Globals.filterByCovered,
                          onChanged: (value) {
                            // Handle covered option
                            setState(() {
                              Globals.filterByCovered = value ?? false;
                            });
                          },
                          title: Text(
                            'Covered',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                        CheckboxListTile(
                          value: Globals.filterByDisabledAccess,
                          onChanged: (value) {
                            // Handle disabled access option
                            setState(() {
                              Globals.filterByDisabledAccess = value ?? false;
                            });
                          },
                          title: Text(
                            'Handycapped Access',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                        CheckboxListTile(
                          value: Globals.filterByChargingStation,
                          onChanged: (value) {
                            // Handle charging station option
                            setState(() {
                              Globals.filterByChargingStation = value ?? false;
                            });
                          },
                          title: Text(
                            'Charging Station',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                        CheckboxListTile(
                          value: Globals.filterBySecured,
                          onChanged: (value) {
                            // Handle secured option
                            setState(() {
                              Globals.filterBySecured = value ?? false;
                            });
                          },
                          title: Text(
                            'Video Surveillance',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                      child: Text(
                        'Remove filters',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      onPressed: () async {
                        setState(() {
                          Globals.radius = 50.0;
                          Globals.filterByCovered = false;
                          Globals.filterByDisabledAccess = false;
                          Globals.filterByChargingStation = false;
                          Globals.filterBySecured = false;
                          Globals.filterPrice = 5.0;
                          Globals.filterapplied = false;
                          Navigator.pushReplacementNamed(context, '/home');
                        });
                      }),
                  TextButton(
                    child: Text(
                      'Apply',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    onPressed: () async {
                      //Globals.convertFutureToList();
                      Globals.filterapplied = true;
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                ],
              );
            },
          );
        },
      );
}
