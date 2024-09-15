import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class Service {
  final CollectionReference bookingsCollection;
  final CollectionReference usersCollection;

  Service()
      : bookingsCollection = FirebaseFirestore.instance.collection('bookings'),
        usersCollection = FirebaseFirestore.instance.collection('users');

 /* void listenToBookings() {
    print("Service - listen! -------------------- ");
    // Get the users collection
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    // Get a stream of all the users
    usersCollection.snapshots().listen((usersSnapshot) {
      print("Found ${usersSnapshot.docs.length} users");
      usersSnapshot.docs.forEach((user) {
        print("Checking bookingsList for user ${user.id}");
        // For each user, listen to the bookingsList subcollection
        user.reference.collection('bookingList').snapshots().listen((bookingsSnapshot) {
          print("Found ${bookingsSnapshot.docs.length} bookings for user ${user.id}");
          // Skip the initial snapshot.
          if(bookingsSnapshot.metadata.hasPendingWrites) return;
          bookingsSnapshot.docChanges.forEach((change) {
            print("searching!");
            // Check if the change type is 'added', indicating a new document
            if (change.type == DocumentChangeType.added) {
              print("New booking in bookingsList!");
              final booking = change.doc;
              // Get the ownerId
              String ownerId = booking.get('ownerId');
              // Fetch the user with this ownerId
              getUserOneSignalId(ownerId, "owner");
            }
          });
        });
      });
    });
  }
*/

  void listenToBookings() {
    print("Service - listen! -------------------- ");
    // Get the users collection
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    // Get a stream of all the users
    usersCollection.snapshots().listen((usersSnapshot) {
      print("Found ${usersSnapshot.docs.length} users");
      for (var user in usersSnapshot.docs) {
        print("Checking bookingsList for user ${user.id}");
        // For each user, listen to the bookingsList subcollection
        user.reference.collection('bookingList').snapshots().listen((bookingsSnapshot) {
          print("Found ${bookingsSnapshot.docs.length} bookings for user ${user.id}");
          for (var change in bookingsSnapshot.docChanges) {
            print("searching!");
            // Check if the change type is 'added', indicating a new document
            if (change.type == DocumentChangeType.added) {
              print("New booking in bookingsList!");
              final booking = change.doc;
              // Get the ownerId
              String ownerId = booking.get('ownerId');
              // Get the notified flag
              bool notified = booking.get('notified');
              // Fetch the user with this ownerId only if the user has not been notified yet
              if (!notified) {
                getUserOneSignalId(ownerId, "owner");
                // update the document to set notified to true
                booking.reference.update({'notified': true});
              }
            }
          }
        });
      }
    });
  }


  Future<void> getUserOneSignalId(String userId, String notificationType) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists && notificationType=="owner") {
      String oneSignal = userSnapshot.get('oneSignal');
      print("The User: $userId has the oneSignalId: $oneSignal");
      sendNewBookingNotification(oneSignal);
    }
  }

  void sendNewBookingNotification(String oneSignalUserId) async {
    print("Send notification to: $oneSignalUserId");
    var notification = OSCreateNotification(
        playerIds: [oneSignalUserId],
        content: "Tap to see more",
        heading: "Your spot just got booked!",
        additionalData: {
          "page": "/history",
        },
        buttons: [
          OSActionButton(text: "View", id: "id1"),
          OSActionButton(text: "Dismiss", id: "id2")
        ]);
    var response = await OneSignal.shared.postNotification(notification);
    print("Sent notification with response: $response");
  }

  /*
  void sendOneSignalNotification(DocumentSnapshot booking) async {
    print("Service - Send! -------------------- ");
    final ownerId = booking['ownerId'];
    if (ownerId == null) {
      print('No ownerId field in document!');
      return;
    }// Fetch the ownerId from the booking
    final userDoc = await usersCollection.doc(ownerId).get();
    final userToken = userDoc['token'];  // Fetch the token

    var notification = OSCreateNotification(
      playerIds: [userToken],
      heading: "Booking Updated",
      content: "Your booking has been updated.",
    );

    var response = await OneSignal.shared.postNotification(notification);
    print("OneSignal response: $response");
  }
  */

  void sendNewMessageNotification(String oneSignalUserId) async {
    print("Send new message notification to: $oneSignalUserId");
    var notification = OSCreateNotification(
        playerIds: [oneSignalUserId],
        content: "Tap to see more",
        heading: "You've received a new message!",
        additionalData: {
          "page": "/chats_page",
        },
        buttons: [
          OSActionButton(text: "View", id: "id1"),
          OSActionButton(text: "Dismiss", id: "id2")
        ]);
    var response = await OneSignal.shared.postNotification(notification);
    print("Sent new message notification with response: $response");
  }

}

