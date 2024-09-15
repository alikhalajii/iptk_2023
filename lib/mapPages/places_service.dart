import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart' as web;
import 'package:myapp/mapPages/api_keys.dart';
import 'package:google_maps_webservice/places.dart';

class PlacesService {
  static Future<void> searchAddressSuggestions(
      BuildContext context, TextEditingController searchController) async {
    const String apiKey = googleMapsApiKey;

    Prediction? prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: apiKey,
      mode: Mode.overlay,
      language: 'de',
      types: [],
      components: [Component(Component.country, 'de')],
    );

    if (prediction != null) {
      // Handles the selected prediction
      final String? placeId = prediction.placeId;
      final placeDetails = await web.GoogleMapsPlaces(apiKey: apiKey)
          .getDetailsByPlaceId(placeId!);
      final String? address = placeDetails.result.formattedAddress;

      // Use this information to populate the text field or perform further operations
      searchController.text = address ??
          ''; // Populate the text field with the selected address (handle null value)
    }
  }
}
