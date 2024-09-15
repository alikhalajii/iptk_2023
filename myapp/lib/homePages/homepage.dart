// ignore_for_file: prefer_collection_literals

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:myapp/reviewPages/reviews_overview.dart';
import 'dart:async';
import '../models/location_data.dart';
import '../models/globals.dart';
import '../models/marker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:myapp/bookingProcessPages/booking_view.dart';
import 'filter_options.dart';

class HomePage extends StatefulWidget {
  final Function(int) onTap;
  final int selectedIndex;

  const HomePage({
    Key? key,
    required this.onTap,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  ///------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Set the background color to transparent
        elevation: 0, // Remove the elevation
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          _isLoaded
              ? GoogleMap(
                  mapType:
                      _isSatelliteView ? MapType.satellite : _currentMapType,
                  initialCameraPosition: kGooglePlex,
                  onMapCreated: !_controller.isCompleted? (GoogleMapController controller) {
                    _controller.complete(controller);
                    mapController = controller;
                  }: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  gestureRecognizers: Set()
                    ..add(Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer())),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onTap: (LatLng latLng) {
                    _setBoxVisibility(false, Globals.selectedLocation);
                  },
                  onCameraMove: (CameraPosition position) {
                    kGooglePlex = position;
                  },
                  markers: markers.values.toSet())
              : Column(children: [
                  for (int i = 0; i < data.length; i++)
                    Transform.translate(
                      offset: Offset(
                        -MediaQuery.of(context).size.width * 2,
                        -MediaQuery.of(context).size.height * 2,
                      ),
                      child: RepaintBoundary(
                        key: data[i]['globalKey'],
                        child: data[i]['widget'],
                      ),
                    )
                ]),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                    child: SizedBox(
                      child: TextField(
                        controller: _searchController,
                        cursorColor: Colors.pink,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          hintText: 'City/ZIP Code',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.pink,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.pink, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.pink, width: 2.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.pink, width: 0.0),
                          ),
                        ),
                        onChanged: (value) {
                          _setBoxVisibility(false, Globals.selectedLocation);
                          // Handle search text change
                          // You can use the entered value to filter the markers on the map
                        },
                        onSubmitted: (value) {
                          _searchAddress(value);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: 'btn1',
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      log('Current Location: $_currentLocation');
                      if (_currentLocation != null) {
                        mapController
                            .animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(_currentLocation!.latitude,
                                _currentLocation!.longitude),
                            zoom: 16.0,
                          ),
                        ));
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
                Expanded(
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: 'btn2',
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    // Put in try catch
                    onPressed: () async {
                      FilterOptions filterOptions = FilterOptions();
                      filterOptions.showFilterOptions(context);
                    },
                    child: const Icon(Icons.filter_list),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.width * 0.05,
            left: MediaQuery.of(context).size.width * 0.05,
            child: FloatingActionButton(
              mini: false,
              heroTag: 'btn3',
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              onPressed: () {
                Globals.getLocation().then((locationData) {
                  setState(() {
                      _currentLocation = CustomLocationData(
                        id: '',
                        city: '',
                        name: 'Current Location',
                        description: 'Your current location',
                        latitude: locationData.latitude!,
                        longitude: locationData.longitude!,
                        price: 0,
                        reviewScore: "",
                        reviewList: [],
                        covered: false,
                        videoSurveillance: false,
                        chargingStation: false,
                        handicappedAccess: false,
                        image: 'assets/current_location.jpg',
                        // Provide an image path here
                        availability: [],
                      );
                      data = [];
                      markers = {};
                      _isLoaded = false;
                      applyfilter();
                    });
                  });
              },
              child: const Icon(Icons.refresh),
            )
          ),
          AnimatedPositioned(
            bottom: 0,
            right: 0,
            left: 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isBoxVisible ? 300 : 0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  if (isBoxVisible)
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                    ),
                ],
              ),
              child: SingleChildScrollView(
                child: Visibility(
                  visible: isBoxVisible,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${Globals.selectedLocation.price.toStringAsFixed(2)} €/h',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700),
                                  ),
                                  FilledButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ReviewsOverview()),
                                      );
                                    },
                                    child: Text(
                                      '${Globals.selectedLocation.reviewScore} ★',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ]),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      imageResize = !imageResize;
                                    });
                                  },
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: Image.network(
                                          Globals.selectedLocation.image,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    Globals.selectedLocation.name,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                                constraints: const BoxConstraints(
                                  minHeight: 100,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Globals.selectedLocation.description,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                              'Covered',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Globals.selectedLocation
                                                        .covered
                                                    ? Colors.grey.shade700
                                                    : Colors.black12,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.roofing,
                                            color:
                                                Globals.selectedLocation.covered
                                                    ? Colors.grey.shade700
                                                    : Colors.black12,
                                          ),
                                          const SizedBox(width: 30),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                              'Charging Station',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Globals.selectedLocation
                                                        .chargingStation
                                                    ? Colors.grey.shade700
                                                    : Colors.black12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.ev_station,
                                            color: Globals.selectedLocation
                                                    .chargingStation
                                                ? Colors.grey.shade700
                                                : Colors.black12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                              'Video Surveillance',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Globals.selectedLocation
                                                        .videoSurveillance
                                                    ? Colors.grey.shade700
                                                    : Colors.black12,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.videocam,
                                            color: Globals.selectedLocation
                                                    .videoSurveillance
                                                ? Colors.grey.shade700
                                                : Colors.black12,
                                          ),
                                          const SizedBox(width: 30),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                              'Handicapped Access',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Globals.selectedLocation
                                                        .handicappedAccess
                                                    ? Colors.grey.shade700
                                                    : Colors.black12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.accessible,
                                            color: Globals.selectedLocation
                                                    .handicappedAccess
                                                ? Colors.grey.shade700
                                                : Colors.black12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FilledButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.pink),
                                    ),
                                    child: const Text('Book now'),
                                    onPressed: () async {
                                      var user =
                                          FirebaseAuth.instance.currentUser!;
                                      final parkingspot =
                                          await FirebaseFirestore.instance
                                              .collection('parkingSpots')
                                              .doc(Globals.selectedLocation.id)
                                              .get();
                                      String ownerID =
                                          parkingspot.data()!['ownerId'];
                                      if (mounted) {
                                        if (ownerID != user.uid) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const BookingView()),
                                          );
                                        } else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "You can not book your own parkingspot!",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.TOP,
                                              timeInSecForIosWeb: 2,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  FilledButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.pink),
                                    ),
                                    child: const Text('Navigate'),
                                    onPressed: () {
                                      _launchMaps(
                                        Globals.selectedLocation.latitude,
                                        Globals.selectedLocation.longitude,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedPositioned(
                        top: MediaQuery.of(context).size.width * 0.03125,
                        left: MediaQuery.of(context).size.width * 0.03125,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        height: imageResize
                            ? MediaQuery.of(context).size.width * 0.75
                            : 0,
                        width: imageResize
                            ? MediaQuery.of(context).size.width * 0.75
                            : 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              imageResize = !imageResize;
                            });
                          },
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: Image.network(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: MediaQuery.of(context).size.width * 0.75,
                              Globals.selectedLocation.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              left: 0,
              child: Container(
                width: 30,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
              ))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'For you',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_rounded),
            label: 'Account',
          ),
        ],
        currentIndex: widget.selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: widget.onTap,
      ),
    );
  }

  ///--------------------------
  ///
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late GoogleMapController mapController;
  CustomLocationData? _currentLocation;
  static CameraPosition kGooglePlex = const CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 15.0,
  );

  final MapType _currentMapType = MapType.normal;
  final bool _isSatelliteView = false;
  final TextEditingController _searchController = TextEditingController();

  final Logger logger = Logger();

  final GlobalKey globalKey = GlobalKey();
  List<Map<String, dynamic>> data = [];
  Map<String, Marker> markers = {};

  bool _isLoaded = false;

  bool isBoxVisible = false;
  bool imageResize = false;

  addMarker(CustomLocationData locationData) {
    data.add({
      'id': locationData.name,
      'globalKey': GlobalKey(),
      'position': LatLng(locationData.latitude, locationData.longitude),
      'data': locationData,
      'widget': MyMarker(locationData),
    });
  }

  @override
  void initState() {
    super.initState();
    Globals.convertFutureToList();
    Globals.getBookingHistory();

    Globals.getLocation().then((locationData) {
      setState(() {
        _currentLocation = CustomLocationData(
          id: '',
          city: '',
          name: 'Current Location',
          description: 'Your current location',
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          price: 0,
          reviewScore: "",
          reviewList: [],
          covered: false,
          videoSurveillance: false,
          chargingStation: false,
          handicappedAccess: false,
          image: 'assets/current_location.jpg', // Provide an image path here
          availability: [],
        );

        applyfilter();
        /*
        for (CustomLocationData location in Globals.locationList) {
          if (location.filtered == false) {
            addMarker(location);
          }
        }

        WidgetsBinding.instance.addPostFrameCallback((timestamp) {
          _onBuildCompleted();
        });
        */
      });
      if(kGooglePlex.target == const LatLng(0.0, 0.0)){
        kGooglePlex = CameraPosition(
          target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          zoom: 15.0,
        );
      }
    });
  }



  void _setBoxVisibility(bool visibility, CustomLocationData location) {
    setState(() {
      isBoxVisible = visibility;
      Globals.setSelectedLocation(location);
      imageResize = false;
    });
  }

  Future<void> _launchMaps(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');
    // ignore: deprecated_member_use
    if (await canLaunch(url.toString())) {
      // ignore: deprecated_member_use
      await launch(url.toString());
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  Future<void> _searchAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final Location location = locations.first;
        //final GoogleMapController controller = await _controller.future;
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 14.0,
          ),
        ));
      } else {
        logger.d('No location found for the address: $address');
      }
    } catch (e) {
      // Handle address search error
      logger.e('Address search error: $e');
    }
  }

  Future<void> _onBuildCompleted() async {
    await Future.wait(
      data.map((value) async {
        Marker marker = await _generateMarkersFromWidgets(value);
        markers[marker.markerId.value] = marker;
      }),
    );
    setState(() => _isLoaded = true);
  }

  Future<Marker> _generateMarkersFromWidgets(Map<String, dynamic> data) async {
    RenderRepaintBoundary boundary = data['globalKey']
        .currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 2);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return Marker(
      markerId: MarkerId(data['id']),
      position: data['position'],
      icon: BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List()),
      anchor: const Offset(0.5, 0.5),
      onTap: () {
        _setBoxVisibility(true, data['data']);
      },
    );
  }

  void applyfilter() async {
    await Globals.convertFutureToList();
    setState(() {
      for (CustomLocationData location in Globals.locationList) {
        //if (location.filtered == false) {
          addMarker(location);
        //}
      }

      WidgetsBinding.instance.addPostFrameCallback((timestamp) {
        _onBuildCompleted();
      });
    });
  }
}
