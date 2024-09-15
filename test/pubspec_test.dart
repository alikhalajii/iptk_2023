import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  test('Validate pubspec.yaml', () {
    final pubspecFile = File('pubspec.yaml');

    // Read the pubspec.yaml file
    final pubspecContent = pubspecFile.readAsStringSync();

    // Validate the required fields
    expect(pubspecContent.contains('name: myapp'), isTrue);
    expect(pubspecContent.contains('version: 0.1.0'), isTrue);
    expect(pubspecContent.contains('dependencies:'), isTrue);
    expect(pubspecContent.contains('flutter:'), isTrue);

    // Validate specific dependencies
    expect(pubspecContent.contains('firebase_auth: ^4.6.3'), isTrue);
    expect(pubspecContent.contains('fluttertoast: ^8.2.2'), isTrue);
    expect(pubspecContent.contains('firebase_core: ^2.14.0'), isTrue);
    expect(pubspecContent.contains('firebase_database: ^10.2.3'), isTrue);
    expect(pubspecContent.contains('graphview: ^1.2.0'), isTrue);
    expect(pubspecContent.contains('google_maps_flutter: ^2.2.0'), isTrue);
    expect(pubspecContent.contains('google_fonts: ^4.0.0'), isTrue);
    expect(pubspecContent.contains('geocoding: ^2.1.0'), isTrue);
    expect(pubspecContent.contains('url_launcher: ^6.1.11'), isTrue);
    expect(pubspecContent.contains('location: ^4.4.0'), isTrue);
    expect(pubspecContent.contains('http: ^0.13.3'), isTrue);
    expect(pubspecContent.contains('image: ^3.2.2'), isTrue);
    expect(pubspecContent.contains('logging: ^1.1.0'), isTrue);
    expect(pubspecContent.contains('logger: ^1.3.0'), isTrue);
    expect(pubspecContent.contains('sqflite: ^2.0.0'), isTrue);
    expect(pubspecContent.contains('path: any'), isTrue);
    expect(pubspecContent.contains('provider: ^6.0.5'), isTrue);
    expect(pubspecContent.contains('image_picker: ^0.8.7+5'), isTrue);
    expect(pubspecContent.contains('custom_marker: ^1.0.0'), isTrue);
    expect(pubspecContent.contains('xml: ^6.0.1'), isTrue);
    expect(pubspecContent.contains('intl: ^0.17.0'), isTrue);
    expect(pubspecContent.contains('table_calendar: ^3.0.8'), isTrue);
    expect(pubspecContent.contains('cloud_firestore: ^4.8.0'), isTrue);
    expect(pubspecContent.contains('firebase_storage: ^11.2.2'), isTrue);
    expect(pubspecContent.contains('flutter_google_places: ^0.3.0'), isTrue);
    expect(pubspecContent.contains('google_maps_webservice: ^0.0.19'), isTrue);
    expect(pubspecContent.contains('autocomplete_textfield: ^2.0.1'), isTrue);
    expect(pubspecContent.contains('flutter_local_notifications: ^14.1.1'),
        isTrue);
    expect(pubspecContent.contains('google_api_headers: ^1.0.0'), isTrue);
    expect(pubspecContent.contains('mockito: ^5.4.0'), isTrue);
    expect(pubspecContent.contains('matcher: ^0.12.13'), isTrue);

    // Validate dev_dependencies
    expect(pubspecContent.contains('flutter_test:'), isTrue);
    expect(pubspecContent.contains('flutter_lints: ^2.0.0'), isTrue);
  });
}
