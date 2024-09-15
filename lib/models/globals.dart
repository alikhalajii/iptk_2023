import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/models/location_data.dart';
import 'package:myapp/models/notification_data.dart';
import 'package:location/location.dart' as location_package;
import 'package:myapp/homePages/homepage.dart' as map;
import 'dart:developer';
import 'dart:math' show asin, cos, pi, sin, sqrt;

import 'booking_data.dart';

class Globals {
  static bool filterByCovered = false;
  static bool filterByDisabledAccess = false;
  static bool filterByChargingStation = false;
  static bool filterBySecured = false;
  static double filterPrice = 5.0;
  static bool filterapplied = false;

  static CustomLocationData selectedLocation = CustomLocationData(
    name: "dummy",
    id: '',
    city: '',
    description: "dummy location",
    latitude: 0,
    longitude: 0,
    price: 0,
    reviewScore: "",
    reviewList: [],
    covered: false,
    videoSurveillance: false,
    chargingStation: false,
    handicappedAccess: false,
    image:
        'https://www.solidus24.de/wp-content/uploads/2023/03/placeholder-2-1.png',
    availability: [],
  );

  static setSelectedLocation(CustomLocationData location) {
    selectedLocation = location;
  }

  static List<NotificationData> notificationList = [
    NotificationData(
      title: "Incoming Booking",
      body:
          "User xy booked your parking lot \"Darmstadt Parking\" for 10.10.2021 10:00 - 11:00",
      id: '',
      timestamp: Timestamp(1654750800, 0),
      message: '',
    ),
  ];

  static removeNotification(NotificationData notification) {
    notificationList.remove(notification);
  }

  static List<BookingData> currentBookings = [];
  static String userId = FirebaseAuth.instance.currentUser!.uid;

  static getBookingHistory() {
    currentBookings.clear();
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    userRef.collection('bookingList').get().then((snapshot) {
      for (var element in snapshot.docs) {
        currentBookings.add(BookingData(
          longitude: element['longitude'],
          latitude: element['latitude'],
          startDate: element['start'].toDate(),
          endDate: element['end'].toDate(),
          price: element['price'],
          parkingSpotName: element['name'],
          parkingSpotImage: element['image'],
        ));
      }
    });
    currentBookings.sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  static location_package.LocationData locationData =
      location_package.LocationData.fromMap({
    "latitude": 0.0,
    "longitude": 0.0,
  });

  static CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 14.4746,
  );

  static Future<location_package.LocationData> getLocation() async {
    var location = location_package.Location();
    location_package.LocationData locationData;
    try {
      locationData = await location.getLocation();
    } catch (error) {
      // Handle location exception/error
      locationData = location_package.LocationData.fromMap({
        "latitude": 0.0,
        "longitude": 0.0,
      });
    }
    return locationData;
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const int radiusOfEarth = 6371; // Radius of the Earth in kilometers
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * asin(sqrt(a));
    double distance = radiusOfEarth * c;
    return distance;
  }

// Helper function to convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  static List<CustomLocationData> locationList = [];

  static double radius = 5;

  static Future<void> convertFutureToList() async {
    locationList = await readLocationData();
  }

  static Future<List<CustomLocationData>> readLocationData() async {
    //location_package.LocationData currentLocation = await getLocation();
    //double centerLat = currentLocation.latitude!;
    //double centerLong = currentLocation.longitude!;
    double centerLat = map.HomePageState.kGooglePlex.target.latitude;
    double centerLong = map.HomePageState.kGooglePlex.target.longitude;
    log(radius.toString());
    double latMin = centerLat -
        (radius / 111.045); // Approximate latitude degrees per kilometer
    double latMax = centerLat + (radius / 111.045);
    double longMin =
        centerLong - (radius / (111.045 * cos(_toRadians(centerLat))));
    double longMax =
        centerLong + (radius / (111.045 * cos(_toRadians(centerLat))));
    QuerySnapshot querySnapshotLat = await FirebaseFirestore.instance
        .collection('parkingSpots')
        .where('latitude', isGreaterThan: latMin, isLessThan: latMax)
        .get();
    QuerySnapshot querySnapshotLong = await FirebaseFirestore.instance
        .collection('parkingSpots')
        .where('longitude', isGreaterThan: longMin, isLessThan: longMax)
        .get();
    // Extract document IDs from both snapshots
    Set<String> latitudeDocumentIds =
        querySnapshotLat.docs.map((doc) => doc.id).toSet();
    Set<String> longitudeDocumentIds =
        querySnapshotLong.docs.map((doc) => doc.id).toSet();

    // Find the intersection of document IDs
    Set<String> commonDocumentIds =
        latitudeDocumentIds.intersection(longitudeDocumentIds);

    // Filter the documents that appear in both snapshots
    List<QueryDocumentSnapshot<Object?>> commonDocuments = querySnapshotLat.docs
        .where((doc) => commonDocumentIds.contains(doc.id))
        .toList();
    List<CustomLocationData> locations = [];
    if (commonDocuments.isNotEmpty) {
      for (DocumentSnapshot document in commonDocuments) {
        // Access individual documents and retrieve data
        String id = document.id;
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String documentId = document.id;
        String name = data['name'];
        String city = data['city'];
        String description = data['description'];
        double latitude = data['latitude'] as double;
        double longitude = data['longitude'] as double;
        double price = data['price'];
        bool covered = data['covered'];
        bool chargingStation = data['chargingStation'];
        bool videoSurveillance = data['videoSurveillance'];
        bool handicappedAccess = data['handicappedAccess'];
        List<dynamic> reviewList = data['reviewList'];

        var url = data['image'];
        if (((data['covered'] == filterByCovered) ||
            !filterByCovered) && ((data['videoSurveillance'] == filterBySecured) ||
            !filterBySecured) &&
            ((data['chargingStation'] == filterByChargingStation) ||
            !filterByChargingStation) &&
            ((data['handicappedAccess'] == filterByDisabledAccess) ||
            !filterByDisabledAccess) && (data['price'] <= filterPrice)) {
          locations.add(CustomLocationData(
            city: city,
            name: name,
            description: description,
            latitude: latitude,
            longitude: longitude,
            price: price,
            reviewList: reviewList,
            reviewScore: calculateReviewScore(reviewList),
            covered: covered,
            chargingStation: chargingStation,
            videoSurveillance: videoSurveillance,
            handicappedAccess: handicappedAccess,
            image: url,
            availability: availability1,
            id: id,
          ));
          log('Document ID: $documentId');
          log('Name: $name');
        }
      }
    } else {
      log('No documents found.');
    }
    return locations;
  }
}
