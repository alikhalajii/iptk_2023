import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/globals.dart';
import 'core/booking_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'model/booking_service.dart';
import 'model/enums.dart';
import 'package:myapp/service.dart';

void main() {
  initializeDateFormatting('en_US').then((_) => runApp(const BookingView()));
}

class BookingView extends StatefulWidget {
  const BookingView({Key? key}) : super(key: key);

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final now = DateTime.now();
  late BookingService mockBookingService;
  late String ownerOneSignalId;
  late String ownerId;

  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    mockBookingService = BookingService(
        serviceName: 'Mock Service',
        serviceDuration: 60,
        bookingEnd: DateTime(now.year, now.month, now.day, 23, 59),
        bookingStart: DateTime(now.year, now.month, now.day, 0, 0));
  }

  Stream<dynamic>? getBookingStreamMock(
      {required DateTime end, required DateTime start}) {
    return Stream.value([]);
  }

  Future<dynamic> uploadBooking({required BookingService newBooking}) async {
    await Future.delayed(const Duration(seconds: 1));
    converted.add(DateTimeRange(
        start: newBooking.bookingStart, end: newBooking.bookingEnd));

    // get user details and OneSignal ID of the booker
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    var a = await userRef.get();
    String bookerOneSignalId = a['oneSignal']; // Get booker's OneSignal ID

    // add booking to the spot
    String bookerName = a['firstName'] + ' ' + a['lastName'];
    await addBookingToSpot(newBooking, bookerName, userId);

    // get owner details and OneSignal ID
    String ownerId = await getOwnerId();
    String receiverId = ownerId;
    ownerOneSignalId = await getOwnerOneSignalId(receiverId);

    // add booking to user
    await addBookingToUser(
        newBooking, bookerOneSignalId, ownerOneSignalId, receiverId);

    bookingSuccessfulNotification();

    // handle chat related updates
    await handleChatUpdates(receiverId, newBooking);

    Globals.getBookingHistory();
  }

  void bookingSuccessfulNotification() async {
    Fluttertoast.showToast(
        msg: "Booking Successful",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    print("booking_view is saying: ${ownerOneSignalId}getting a notification!");
    Service().sendNewBookingNotification(ownerOneSignalId);
  }

  List<DateTimeRange> converted = [];

  List<DateTimeRange> convertToDateTime(
      List<bool> availability, int dayOffset) {
    var ongoingBooking = false;
    int duration = 0;
    List<DateTimeRange> range = [];
    DateTime start = DateTime.now();
    for (int i = 0; i < availability.length; i++) {
      if (!availability[i] && !ongoingBooking) {
        start = DateTime(now.year, now.month, now.day + dayOffset, i, 0);
        ongoingBooking = true;
        duration += 1;
      } else if (availability[i] && ongoingBooking) {
        DateTime end = start.add(Duration(hours: duration));
        range.add(DateTimeRange(start: start, end: end));
        ongoingBooking = false;
        duration = 0;
      } else if (ongoingBooking) {
        duration += 1;
      }
    }
    return range;
  }

  Future<List<DateTimeRange>> convertStreamResultMock(
      {required dynamic streamResult}) async {
    List<DateTimeRange> dateTimeList = await FirebaseFirestore.instance
        .collection('parkingSpots')
        .doc(Globals.selectedLocation.id)
        .collection('bookingList')
        .get()
        .then((querySnapshot) {
      return querySnapshot.docs.map((documentSnapshot) {
        final start = documentSnapshot['start'].toDate();
        final end = documentSnapshot['end'].toDate();
        log(start.hour.toString());
        log(end.hour.toString());
        return DateTimeRange(start: start, end: end);
      }).toList();
    });
    return dateTimeList;
  }

  List<DateTimeRange> generatePauseSlots() {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose date and time'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: BookingCalendar(
          bookingService: mockBookingService,
          convertStreamResultToDateTimeRanges: convertStreamResultMock,
          getBookingStream: getBookingStreamMock,
          uploadBooking: uploadBooking,
          bookedSlotColor: Colors.grey,
          pauseSlots: generatePauseSlots(),
          pauseSlotText: 'Unavailable',
          hideBreakTime: false,
          loadingWidget: const Text('Fetching data...'),
          uploadingWidget: const CircularProgressIndicator(),
          locale: 'en_US',
          lastDay: DateTime(now.year, now.month, now.day + 6),
          startingDayOfWeek: StartingDayOfWeek.tuesday,
          wholeDayIsBookedWidget:
              const Text('Sorry, for this day everything is booked'),
        ),
      ),
    );
  }

  Future<Future<DocumentReference<Map<String, dynamic>>>> addBookingToSpot(
      BookingService newBooking, String bookerName, String userId) async {
    print("adding Booking to Spot");
    return FirebaseFirestore.instance
        .collection('parkingSpots')
        .doc(Globals.selectedLocation.id)
        .collection('bookingList')
        .add({
      'author': bookerName,
      'start': newBooking.bookingStart,
      'end': newBooking.bookingEnd,
    });
  }

  Future<String> getOwnerId() async {
    print("getting Owner ID");
    return await FirebaseFirestore.instance
        .collection('parkingSpots')
        .doc(Globals.selectedLocation.id)
        .get()
        .then((value) => value['ownerId']); // ID of owner
  }

  Future<String> getOwnerOneSignalId(String ownerId) async {
    print("Getting Owner One Signal");
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(ownerId)
        .get()
        .then((value) => value['oneSignal']); // OneSignal ID of owner
  }

  Future<Future<DocumentReference<Map<String, dynamic>>>> addBookingToUser(
      BookingService newBooking,
      String bookerOneSignalId,
      String ownerOneSignalId,
      String ownerId) async {
    print("adding Bokking to User");
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookingList')
        .add({
      'longitude': Globals.selectedLocation.longitude,
      'latitude': Globals.selectedLocation.latitude,
      'start': newBooking.bookingStart,
      'end': newBooking.bookingEnd,
      'price': Globals.selectedLocation.price *
          (newBooking.bookingEnd.difference(newBooking.bookingStart).inHours),
      'name': Globals.selectedLocation.name,
      'image': Globals.selectedLocation.image,
      'bookerOneSignal': bookerOneSignalId,
      'ownerOneSignal': ownerOneSignalId,
      'ownerId': ownerId,
      'bookerId': userId,
    });
  }

  Future<void> handleChatUpdates(
      String receiverId, BookingService newBooking) async {
    print("Creating Chat between both!");
    bool chatAlreadyExists = false;
    await FirebaseFirestore.instance
        .collection('chats')
        .where('receiverID', isEqualTo: receiverId)
        .where('senderID', isEqualTo: userId)
        .get()
        .then((value) => chatAlreadyExists = value.docs.isNotEmpty);
    if(!chatAlreadyExists){
      await FirebaseFirestore.instance
          .collection('chats')
          .where('receiverID', isEqualTo: userId)
          .where('senderID', isEqualTo: receiverId)
          .get()
          .then((value) => chatAlreadyExists = value.docs.isNotEmpty);
    }
    if (!chatAlreadyExists) {
      FirebaseFirestore.instance.collection('chats').add({
        'messages': [
          {
            'content':
                'A place has been booked at ${Globals.selectedLocation.name} at ${newBooking.bookingStart.month}.${newBooking.bookingStart.day}., ${DateFormat.jm().format(newBooking.bookingStart)}-${DateFormat.jm().format(newBooking.bookingEnd)}, . Start your conversation now!',
            'sender': 'system',
            'time': DateTime.now(),
          }
        ],
        'receiverID': receiverId,
        'senderID': userId,
      });
    } else {
      FirebaseFirestore.instance
          .collection('chats')
          .where('receiverID', isEqualTo: receiverId)
          .where('senderID', isEqualTo: userId)
          .get()
          .then((value) => value.docs.first.reference.update({
                'messages': FieldValue.arrayUnion([
                  {
                    'content':
                        'A place has been booked at ${Globals.selectedLocation.name} at ${newBooking.bookingStart.month}.${newBooking.bookingStart.day}., ${DateFormat.jm().format(newBooking.bookingStart)}-${DateFormat.jm().format(newBooking.bookingEnd)}, . Start your conversation now!',
                    'sender': 'system',
                    'time': DateTime.now(),
                  }
                ])
              }));
      FirebaseFirestore.instance
          .collection('chats')
          .where('receiverID', isEqualTo: userId)
          .where('senderID', isEqualTo: receiverId)
          .get()
          .then((value) => value.docs.first.reference.update({
                'messages': FieldValue.arrayUnion([
                  {
                    'content':
                        'A place has been booked at ${Globals.selectedLocation.name} at ${newBooking.bookingStart.month}.${newBooking.bookingStart.day}., ${DateFormat.jm().format(newBooking.bookingStart)}-${DateFormat.jm().format(newBooking.bookingEnd)}, . Start your conversation now!',
                    'sender': 'system',
                    'time': DateTime.now(),
                  }
                ])
              })
      );
    }
  }
}
