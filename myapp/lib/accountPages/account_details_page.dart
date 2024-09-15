import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/accountPages/erasing_account_page.dart';
import 'package:myapp/homePages/entering_page.dart';
import 'package:myapp/accountPages/surveyPages/survey_page.dart';
import 'package:myapp/accountPages/account_details_page_editable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // User is imported from Firebase
    User? user = FirebaseAuth.instance.currentUser;
    // Variables to save Information on (if available)
    String? displayName = 'loading';
    int reviewsCount = 0;
    int spotsCount = 0;

    StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) return const Text('Something went wrong');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return Text(
          displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );

    Widget buildInformationFields(String label, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            child: Text(
              value.isEmpty ? 'Empty' : value,
              style: TextStyle(
                fontSize: 16,
                color: value.isEmpty ? Colors.black12 : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Account Details'),
          backgroundColor: Colors.pink,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      // Display the user profile picture here
                      backgroundColor: Colors.pink,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Something went wrong');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            Map<String, dynamic> data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            String firstName = data['firstName'] ?? '';
                            String lastName = data['lastName'] ?? '';

                            return Text(
                              '$firstName $lastName',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow),
                            const SizedBox(width: 4),
                            Text(
                              '$reviewsCount Reviews',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Row(children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 4),
                          Text(
                            '$spotsCount Spots',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Personal Information:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AccountDetailsPageEditable()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            Colors.pink, // Set the color of the text
                        foregroundColor: Colors.white, // Set the text color
                      ),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    String firstName = data['firstName'] ?? '';
                    String lastName = data['lastName'] ?? '';
                    String phoneNumber = data['phoneNumber'] ?? '';
                    String licensePlate = data['licensePlate'] ?? '';

                    return Column(
                      children: [
                        buildInformationFields('First Name: ', firstName),
                        const SizedBox(height: 15),
                        buildInformationFields('Last Name: ', lastName),
                        const SizedBox(height: 15),
                        buildInformationFields('Email: ', user?.email ?? ''),
                        const SizedBox(height: 15),
                        buildInformationFields('Phone Number: ', phoneNumber),
                        const SizedBox(height: 15),
                        buildInformationFields('License Plate: ', licensePlate),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Something went wrong');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            if (snapshot.hasData) {
                              Map<String, dynamic> data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              String firstName = data['firstName'] ?? '';
                              String lastName = data['lastName'] ?? '';
                              String userName = '$firstName $lastName';

                              return ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SurveyPage(userName: userName)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                                icon: const Icon(Icons.assignment),
                                label: const Text(
                                  'Start Survey',
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            } else {
                              return Container(); // Empty container in case snapshot doesn't contain data
                            }
                          }),
                    ),
                  ],
                ),
                // Start Survey Bottom
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance
                        .signOut(); // Sign out and then send to entering Page
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EnteringPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ), // Sign out Bottom
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ErasingAccount()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
