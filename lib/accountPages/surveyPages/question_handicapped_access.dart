import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/accountPages/surveyPages/question_video_surveillance.dart';

class QuestionHandicappedAccess extends StatefulWidget {
  const QuestionHandicappedAccess({Key? key}) : super(key: key);

  @override
  State<QuestionHandicappedAccess> createState() =>
      _QuestionHandicappedAccessState();
}

class _QuestionHandicappedAccessState extends State<QuestionHandicappedAccess> {
  String? dropdownValue;

  // Getting Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Survey'),
      ),
      body: Container(
        color: Colors.white,
        padding:
            const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '3. Do you require handicapped-accessible parking spots?',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, bottom: 20, top: 20),
              child: Image.asset('assets/handicapped_access_low.jpg'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var currentUser = _auth.currentUser;
                    if (currentUser != null) {
                      await _firestore
                          .collection('users')
                          .doc(currentUser.uid)
                          .set({
                        'handicappedNecessary': true,
                      }, SetOptions(merge: true));
                    }
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const QuestionVideoSurveillance()),
                      );
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
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    var currentUser = _auth.currentUser;
                    if (currentUser != null) {
                      await _firestore
                          .collection('users')
                          .doc(currentUser.uid)
                          .set({
                        'handicappedNecessary': false,
                      }, SetOptions(merge: true));
                    }
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const QuestionVideoSurveillance()),
                      );
                    }
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
                    style: TextStyle(fontSize: 30, color: Colors.white),
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
