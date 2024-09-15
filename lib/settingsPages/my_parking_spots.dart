import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:myapp/my_parkingspot_pages/new_parkingspot.dart';
import 'package:myapp/my_parkingspot_pages/delete_parkingspot.dart';

class MyParkingSpotsPage extends StatelessWidget {
  const MyParkingSpotsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    // Helper method to build a button
    Widget buildButton(BuildContext context, String label, String parkingSpotID,
        IconData iconAfterText, VoidCallback onPressed) {
      return TextButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 8.0),
                Text(label,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.pink,
                    )),
              ],
            ),
            Icon(iconAfterText, color: Colors.pink),
          ],
        ),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('parkingSpots')
          .snapshots(),
      builder: (context, parkSnapshots) {
        if (parkSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!parkSnapshots.hasData || parkSnapshots.data!.docs.isEmpty) {
          // Render UI when there are no parking spots
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.pink,
              title: const Text('My Parking Spots'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildButton(
                    context,
                    'Add new',
                    'Null',
                    Icons.add_circle,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewParkingSpot()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        final loadedParkingSpots = parkSnapshots.data!.docs;

        // Render UI when there are parking spots
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.pink,
            title: const Text('My Parking Spots'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: loadedParkingSpots.length,
                    itemBuilder: (context, index) {
                      String name = loadedParkingSpots[index].data()['name'];
                      String parkingSpotID = loadedParkingSpots[index].id;

                      return buildButton(
                        context,
                        name,
                        parkingSpotID,
                        Icons.delete,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DeleteParkingspotPage(
                                    parkingSpotID: parkingSpotID,
                                    parkingSpotName: name)),
                          );
                        },
                      );
                    },
                  ),
                ),
                buildButton(
                  context,
                  'Add new',
                  'Null',
                  Icons.add_circle,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewParkingSpot()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
