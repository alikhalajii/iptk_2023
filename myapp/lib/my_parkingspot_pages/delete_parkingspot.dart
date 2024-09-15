// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/globals.dart';

class DeleteParkingspotPage extends StatelessWidget {
  final String parkingSpotID;
  final String parkingSpotName;

  const DeleteParkingspotPage(
      {Key? key, required this.parkingSpotID, required this.parkingSpotName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Delete Parkingspot'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Do you want to delete this parking spot?',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('parkingSpots')
                        .doc(parkingSpotID)
                        .collection('bookingList')
                        .get()
                        .then((querySnapshot) {
                      for (var document in querySnapshot.docs) {
                        document.reference.delete();
                      }
                    });

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(Globals.userId)
                        .collection('parkingSpots')
                        .doc(parkingSpotID)
                        .delete();

                    await FirebaseFirestore.instance
                        .collection('parkingSpots')
                        .where('name', isEqualTo: parkingSpotName)
                        .get()
                        .then((querySnapshot) {
                      querySnapshot.docs.forEach((document) {
                        document.reference.delete();
                      });
                    });

                    Globals.convertFutureToList();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(100, 10, 5, 50),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    ' No ',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
