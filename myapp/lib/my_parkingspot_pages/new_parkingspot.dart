import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:myapp/mapPages/address_autocomplete.dart';
import 'package:myapp/widgets/image_input.dart';
import 'dart:io';

import '../models/globals.dart';

class NewParkingSpot extends StatefulWidget {
  const NewParkingSpot({super.key});

  @override
  State<NewParkingSpot> createState() {
    return _NewParkingSpotState();
  }
}

class _NewParkingSpotState extends State<NewParkingSpot> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String? _description;
  String? _city;
  String? _address;
  var _price = 0.0;
  File? image;

  bool covered = false;
  bool chargingStation = false;
  bool videoSurveillance = false;
  bool handicappedAccess = false;
  List<dynamic> reviews = [];

  final TextEditingController _textEditingController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser!;

  void _saveItem() async {
    if (_address == null) {
      _address = _textEditingController.text;
      List<String> splitAddress = _address!.split(",");
      _city = splitAddress[2];
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop();

      List<Location> locations = await locationFromAddress(_address!);

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final parkingspotData =
          await FirebaseFirestore.instance.collection('parkingSpots').add({
        'ownerId': user.uid,
        'ownerName': userData.data()!['username'],
        'name': _name,
        'description': _description,
        'price': _price,
        'covered': covered,
        'chargingStation': chargingStation,
        'videoSurveillance': videoSurveillance,
        'handicappedAccess': handicappedAccess,
        'latitude': locations.first.latitude,
        'longitude': locations.first.longitude,
        'image': '',
        'reviewList': reviews,
        'city': _city,
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('parkingspot_images')
          .child('${parkingspotData.id}.jpg');

      await storageRef.putFile(image!);
      final imageURL = await storageRef.getDownloadURL();

      parkingspotData.update({'image': imageURL});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('parkingSpots')
          .add({
        'ownerId': user.uid,
        'ownerName': userData.data()!['username'],
        'name': _name,
        'description': _description,
        'price': _price,
        'covered': covered,
        'chargingStation': chargingStation,
        'videoSurveillance': videoSurveillance,
        'handicappedAccess': handicappedAccess,
        'latitude': locations.first.latitude,
        'longitude': locations.first.longitude,
        'city': _city,
      });

      // Update Parkingspots
      Globals.convertFutureToList();
    }
  }

  // Screen for adding a new parking spot
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new parking spot'),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ImageInput(
                    onPickImage: (takenImage) {
                      image = takenImage;
                    },
                  ),
                  TextFormField(
                      maxLength: 30,
                      decoration: const InputDecoration(
                        label: Text('Name'),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.pink,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length <= 5) {
                          return 'Name must be between 6 and 30 characters.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value!;
                      }),
                  AddressAutocomplete(
                    onAddressSelected: (address) {
                      _address = address;
                      List<String> splitAddress = address.split(",");
                      _city = splitAddress[2];
                    },
                    controller: _textEditingController,
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Price per hour in €',
                          style: TextStyle(
                            fontSize: 15,
                          )),
                      Slider(
                        value: _price,
                        min: 0,
                        max: 5,
                        divisions: 50,
                        label: _price.toStringAsFixed(2),
                        onChanged: (double value) {
                          setState(() {
                            _price = value;
                          });
                        },
                        thumbColor: Colors.pink,
                        activeColor: Colors.pink,
                        inactiveColor: Colors.grey,
                      ),
                      const Divider(
                        height: 10,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 100, child: Text("Covered")),
                            Checkbox(
                              value: covered,
                              onChanged: (bool? value1) {
                                setState(() {
                                  covered = value1!;
                                });
                              },
                            ),
                            const SizedBox(
                                width: 100, child: Text("Charging Station")),
                            Checkbox(
                              value: chargingStation,
                              onChanged: (bool? value2) {
                                setState(() {
                                  chargingStation = value2!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                                width: 100, child: Text("Video surveillance")),
                            Checkbox(
                              value: videoSurveillance,
                              onChanged: (bool? value3) {
                                setState(() {
                                  videoSurveillance = value3!;
                                });
                              },
                            ),
                            const SizedBox(
                                width: 100, child: Text("Handicapped Access")),
                            Checkbox(
                              value: handicappedAccess,
                              onChanged: (bool? value1) {
                                setState(() {
                                  handicappedAccess = value1!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                      maxLength: 300,
                      decoration: const InputDecoration(
                        label: Text('Description'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is missing';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _description = value!;
                      }),
                  ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                    ),
                    child: const Text('Create'),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
