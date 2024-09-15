// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:myapp/bookingProcessPages/paypalPayment.dart';

class PayingPage extends StatelessWidget {
  final DateTime bookingStart;
  final DateTime bookingEnd;
  final double totalPrice;
  final String userId; // Logged-in user ID
  final String spotOwnerUserId; // Parking spot owner user ID
  final int bookingHourStart;
  final int bookingHourEnd;

  factory PayingPage({
    Key? key,
    required DateTime bookingStart,
    required DateTime bookingEnd,
    required double totalPrice,
    required String userId,
    required String spotOwnerUserId,
    required int bookingHourStart,
    required int bookingHourEnd,
  }) {
    return PayingPage._internal(
      bookingStart: bookingStart,
      bookingEnd: bookingEnd,
      totalPrice: totalPrice,
      userId: userId,
      spotOwnerUserId: spotOwnerUserId,
      key: key,
      bookingHourEnd: bookingHourEnd,
      bookingHourStart: bookingHourStart,
    );
  }

  const PayingPage._internal({
    Key? key,
    required this.bookingStart,
    required this.bookingEnd,
    required this.totalPrice,
    required this.userId,
    required this.spotOwnerUserId,
    required this.bookingHourStart,
    required this.bookingHourEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Start:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${bookingStart.day}/${bookingStart.month}/${bookingStart.year} $bookingHourStart:00',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Booking End:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${bookingStart.day}/${bookingStart.month}/${bookingStart.year} ${bookingHourEnd + 1}:00',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${totalPrice.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(100, 231, 30, 98),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PayPalPagmentPage(
                              title: 'Paypal', value: totalPrice)));
                },
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
