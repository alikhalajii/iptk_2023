import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/globals.dart';
import 'booking_info.dart';

class History extends StatelessWidget {
  const History({Key? key, required this.onTap, required this.selectedIndex})
      : super(key: key);
  final Function(int) onTap;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    var currentBookings = Globals.currentBookings
        .where((booking) => booking.isCurrentBooking());
    var pastBookings = Globals.currentBookings
        .where((booking) => !booking.isCurrentBooking());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('History'),
      ),
      body: currentBookings.isNotEmpty || pastBookings.isNotEmpty
          ? SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 20),
          const Text(
            "Current Bookings",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(children: [
            for (var booking in currentBookings) BookingInfo(booking: booking)
          ]),
          const SizedBox(height: 20),
          const Text(
            "Past Bookings",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(children: [
            for (var booking in pastBookings) BookingInfo(booking: booking)
          ]),
          ElevatedButton(
            onPressed: removeOldBookings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
            ),
            child: const Text(
              'Delete History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ]),
      )
          : Center(

        child: ElevatedButton(
          onPressed: () {
            onTap(0);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
          ),
          child: const Text(
            'Book your first Spot Now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
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
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onTap,
      ),
    );
  }

  Future<void> removeOldBookings() async {
    print("removing!");
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final bookingListRef = userDocRef.collection('bookingList');

    final now = DateTime.now();

    await bookingListRef.get().then((snapshot) {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        final start = doc['start'].toDate();
        if (start.isBefore(now)) {
          batch.delete(doc.reference);
        }
      }
      return batch.commit();
    });
    Globals.getBookingHistory();
  }
}
