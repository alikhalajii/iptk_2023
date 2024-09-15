import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bookingProcessPages/booking_view.dart';
import '../reviewPages/reviews_overview.dart';
import 'globals.dart';
import 'location_data.dart';

class ParkingListTile extends StatefulWidget {
  const ParkingListTile(this.location, {super.key});

  final CustomLocationData location;

  @override
  State<ParkingListTile> createState() => _ParkingListTileState();
}

class _ParkingListTileState extends State<ParkingListTile> {
  bool imageTapped = false;

  resizeImage() {
    setState(() {
      imageTapped = !imageTapped;
    });
  }

  @override
  Widget build(BuildContext context) {
    // wrap your widget with RepaintBoundary and
    // pass your global key to RepaintBoundary
    return Stack(
      children: [
        GestureDetector(
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.location.price.toStringAsFixed(2)} €/h',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FilledButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        onPressed: () {
                          Globals.setSelectedLocation(widget.location);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ReviewsOverview()),
                          );
                        },
                        child: Text(
                          '${widget.location.reviewScore} ★',
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
                        resizeImage();
                        log("tapped");
                      },
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Image.network(
                              widget.location.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.location.name,
                        style: const TextStyle(
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
                          widget.location.description,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Covered',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: widget.location.covered
                                        ? Colors.grey.shade700
                                        : Colors.black12,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.roofing,
                                color: widget.location.covered
                                    ? Colors.grey.shade700
                                    : Colors.black12,
                              ),
                              const SizedBox(width: 30),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Charging Station',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: widget.location.chargingStation
                                        ? Colors.grey.shade700
                                        : Colors.black12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.ev_station,
                                color: widget.location.chargingStation
                                    ? Colors.grey.shade700
                                    : Colors.black12,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Video Surveillance',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: widget.location.videoSurveillance
                                        ? Colors.grey.shade700
                                        : Colors.black12,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.videocam,
                                color: widget.location.videoSurveillance
                                    ? Colors.grey.shade700
                                    : Colors.black12,
                              ),
                              const SizedBox(width: 30),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Handicapped Access',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: widget.location.handicappedAccess
                                        ? Colors.grey.shade700
                                        : Colors.black12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.accessible,
                                color: widget.location.handicappedAccess
                                    ? Colors.grey.shade700
                                    : Colors.black12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.pink),
                      ),
                      child: const Text('Book now'),
                      onPressed: () async {
                        var user = FirebaseAuth.instance.currentUser!;
                        final parkingspot = await FirebaseFirestore.instance
                            .collection('parkingSpots')
                            .doc(widget.location.id)
                            .get();
                        String ownerID = parkingspot.data()!['ownerId'];
                        if (mounted) {
                          if (ownerID != user.uid) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BookingView()),
                            );
                          } else {
                            Fluttertoast.showToast(
                                msg: "You can not book your own parkingspot!",
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
                              MaterialStateProperty.all<Color>(Colors.pink),
                        ),
                        child: const Text('Navigate'),
                        onPressed: () => {
                              _launchMaps(widget.location.latitude,
                                  widget.location.longitude)
                            }),
                  ],
                ),
              ],
            ),
          ),
        ),
        AnimatedPositioned(
            top: MediaQuery.of(context).size.width * 0.03125,
            left: MediaQuery.of(context).size.width * 0.03125,
            height: imageTapped ? MediaQuery.of(context).size.width * 0.75 : 0,
            width: imageTapped ? MediaQuery.of(context).size.width * 0.75 : 0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => resizeImage(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    widget.location.image,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.width * 0.75,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ))
      ],
    );
  }

  // Function to launch Google Maps with latitude and longitude
  Future<void> _launchMaps(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
