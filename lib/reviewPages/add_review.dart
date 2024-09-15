import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/globals.dart';

class AddReviewPage extends StatefulWidget {
  const AddReviewPage({Key? key}) : super(key: key);

  @override
  State<AddReviewPage> createState() => AddReviewPageState();
}

class AddReviewPageState extends State<AddReviewPage> {
  int score = 0;
  String text = '';
  String? author;
  String parkingspotID = Globals.selectedLocation.id;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _textFieldController = TextEditingController();

  // Function to upload the review to the database
  Future<void> uploadReview() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    var a = await userRef.get();

    author = a['firstName'] + ' ' + a['lastName'][0] + '.';

    final parkingSpotRef = FirebaseFirestore.instance
        .collection('parkingSpots')
        .doc(parkingspotID);

    var data = await parkingSpotRef.get();
    var reviewList = data['reviewList'];
    var toRemove = [];

    reviewList.forEach((review) {
      if (review['userId'].toString() == userId.toString()) {
        toRemove.add(review);
      }
    });
    reviewList.removeWhere((e) => toRemove.contains(e));

    reviewList.add(
        {'score': score, 'author': author, 'text': text, 'userId': userId});

    await parkingSpotRef.update({'reviewList': reviewList});

    log('Author: $author');
    log('ParkingID: $parkingspotID');
  }

  // Function to change the score of the review
  void _changeScore(int newScore) {
    setState(() {
      score = newScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Write Review'),
          backgroundColor: Colors.pink,
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: (score >= 1) ? Colors.yellow : Colors.grey,
                      size: 50,
                    ),
                    onPressed: () {
                      _changeScore(1);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: (score >= 2) ? Colors.yellow : Colors.grey,
                      size: 50,
                    ),
                    onPressed: () {
                      _changeScore(2);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: (score >= 3) ? Colors.yellow : Colors.grey,
                      size: 50,
                    ),
                    onPressed: () {
                      _changeScore(3);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: (score >= 4) ? Colors.yellow : Colors.grey,
                      size: 50,
                    ),
                    onPressed: () {
                      _changeScore(4);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: (score >= 5) ? Colors.yellow : Colors.grey,
                      size: 50,
                    ),
                    onPressed: () {
                      _changeScore(5);
                    },
                  ),
                ]),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 200,
                  child: TextField(
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    controller: _textFieldController,
                    decoration: const InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: 'Review',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    text = _textFieldController.text;
                    await uploadReview();
                    await Globals.convertFutureToList();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ));
  }
}
