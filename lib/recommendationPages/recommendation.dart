import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/parking_list_tile.dart';
import '../models/globals.dart';
import '../models/location_data.dart';

class Recommendation extends StatefulWidget {
  const Recommendation(
      {Key? key, required this.onTap, required this.selectedIndex})
      : super(key: key);
  final Function(int) onTap;
  final int selectedIndex;

  @override
  State<Recommendation> createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation> {
  final user = FirebaseAuth.instance.currentUser!;
  bool handicappedNecessary = false;
  bool coveredNecessary = false;
  bool electricPreferred = false;
  bool videoSurveillancePreferred = false;
  bool _isLoaded = false;
  String userName = '';
  List<CustomLocationData> perfectLocations = [];
  List<CustomLocationData> locationsForHandicapped = [];
  List<CustomLocationData> locationsForElectricPreference = [];
  List<CustomLocationData> locationsForVideoSurveillancePreference = [];
  List<CustomLocationData> locationsForCoveredPreference = [];

  @override
  initState() {
    super.initState();
    loadPreferences();
    getName();
  }

  getName() async{
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      userName = userData['firstName'] + userData['lastName'];
    });
  }

  // Load user preferences from Firestore
  void loadPreferences() async {
    log('Loading user preferences...');
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      handicappedNecessary = userData['handicappedNecessary'] ?? false;
      coveredNecessary = userData['coverNecessary'] ?? false;
      electricPreferred = userData['chargingStation'] ?? false;
      videoSurveillancePreferred =
          userData['videoSurveillancePreferred'] ?? false;
      _isLoaded = true;
      locationsForCoveredPreference =
          Globals.locationList.where((element) => element.covered).toList();
      locationsForHandicapped = Globals.locationList
          .where((element) => element.handicappedAccess)
          .toList();
      locationsForElectricPreference = Globals.locationList
          .where((element) => element.chargingStation)
          .toList();
      locationsForVideoSurveillancePreference = Globals.locationList
          .where((element) => element.videoSurveillance)
          .toList();
      locationsForCoveredPreference
          .sort((a, b) => b.reviewScore.compareTo(a.reviewScore));
      locationsForHandicapped
          .sort((a, b) => b.reviewScore.compareTo(a.reviewScore));
      locationsForElectricPreference
          .sort((a, b) => b.reviewScore.compareTo(a.reviewScore));
      locationsForVideoSurveillancePreference
          .sort((a, b) => b.reviewScore.compareTo(a.reviewScore));
      perfectLocations = Globals.locationList
          .where((element) =>
              (element.handicappedAccess ||
                  element.handicappedAccess == handicappedNecessary) &&
              (element.chargingStation ||
                  element.chargingStation == electricPreferred) &&
              (element.videoSurveillance ||
                  element.videoSurveillance == videoSurveillancePreferred) &&
              (element.covered || element.covered == coveredNecessary))
          .toList();
      perfectLocations.sort((a, b) => b.reviewScore.compareTo(a.reviewScore));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Recommendations'),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (perfectLocations.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Perfect locations according to your personal preferences:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink),
                      ),
                      const SizedBox(height: 20),
                      for (var location in perfectLocations)
                        _isLoaded ? ParkingListTile(location) : Container(),
                    ],
                  ),
                if (handicappedNecessary && locationsForHandicapped.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Because you prefer locations with handicapped access:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink),
                      ),
                      const SizedBox(height: 20),
                      for (var location in locationsForHandicapped)
                        _isLoaded ? ParkingListTile(location) : Container(),
                    ],
                  ),
                if (electricPreferred &&
                    locationsForElectricPreference.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Because you prefer locations with charging stations:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink),
                      ),
                      const SizedBox(height: 20),
                      for (var location in locationsForElectricPreference)
                        _isLoaded ? ParkingListTile(location) : Container(),
                    ],
                  ),
                if (videoSurveillancePreferred &&
                    locationsForVideoSurveillancePreference.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Because you prefer locations with video surveillance:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink),
                      ),
                      const SizedBox(height: 20),
                      for (var location
                          in locationsForVideoSurveillancePreference)
                        _isLoaded ? ParkingListTile(location) : Container(),
                    ],
                  ),
                if (coveredNecessary &&
                    locationsForCoveredPreference.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Because you prefer locations with covered parking:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink),
                      ),
                      const SizedBox(height: 20),
                      for (var location in locationsForCoveredPreference)
                        _isLoaded ? ParkingListTile(location) : Container(),
                    ],
                  ),
              ],
            ),
          ),
        )
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
}
