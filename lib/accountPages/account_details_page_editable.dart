import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/accountPages/account_details_page.dart';

class AccountDetailsPageEditable extends StatefulWidget {
  const AccountDetailsPageEditable({Key? key}) : super(key: key);

  @override
  AccountDetailsPageEditableState createState() =>
      AccountDetailsPageEditableState();
}

class AccountDetailsPageEditableState
    extends State<AccountDetailsPageEditable> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot>? userDataFuture;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var currentUser = _auth.currentUser;
    if (currentUser != null) {
      userDataFuture =
          _firestore.collection('users').doc(currentUser.uid).get();
    }
  }

  Widget buildEditableField(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: controller.text.isEmpty ? 'Add' : controller.text,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          firstNameController.text = data['firstName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          phoneNumberController.text = data['phoneNumber'] ?? '';
          licensePlateController.text = data['licensePlate'] ?? '';

          return Scaffold(
            appBar: AppBar(
              title: const Text('Account Details'),
              backgroundColor: Colors.pink,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                        radius: 60,
                        // backgroundImage: NetworkImage(user?.photoURL ?? ''), ---------- TODO falls jemand sich auskennt...
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Personal Information:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildEditableField('First Name: ', firstNameController),
                  buildEditableField('Last Name: ', lastNameController),
                  buildEditableField('Phone Number: ', phoneNumberController),
                  buildEditableField('License Plate: ', licensePlateController),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      var currentUser = _auth.currentUser;
                      if (currentUser != null) {
                        if (kDebugMode) {
                          print("USER IS LOGGED IN - HE ALLOWED TO CHANGE");
                        }
                        await _firestore
                            .collection('users')
                            .doc(currentUser.uid)
                            .set({
                          'firstName': firstNameController.text,
                          'lastName': lastNameController.text,
                          // speichern Sie das Datum als String
                          'phoneNumber': phoneNumberController.text,
                          'licensePlate': licensePlateController.text,
                          // ... other fields ...
                        }, SetOptions(merge: true));
                      }
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AccountDetailsPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.pink,
                      // Set the color of the text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Return an error message if snapshot has no data
          return const Center(child: Text('Failed to load data!'));
        }
      },
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    licensePlateController.dispose();
    super.dispose();
  }
}
