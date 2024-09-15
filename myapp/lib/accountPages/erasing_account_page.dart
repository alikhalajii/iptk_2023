import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/homePages/entering_page.dart';

class ErasingAccount extends StatefulWidget {
  const ErasingAccount({Key? key}) : super(key: key);

  @override
  State<ErasingAccount> createState() => _ErasingAccountState();
}

class _ErasingAccountState extends State<ErasingAccount> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  String? error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _deleteAccount() async {
    try {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/entering');
      }
      await Future.delayed(const Duration(seconds: 1));
      User user = FirebaseAuth.instance.currentUser!;
      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: _passwordController.text);
      await user.reauthenticateWithCredential(credential);
      FirebaseFirestore.instance
          .collection('parkingSpots')
          .where('ownerId', isEqualTo: user.uid)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('parkingSpots')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookingList')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      FirebaseFirestore.instance
          .collection('chats')
          .where('senderID', isEqualTo: user.uid)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      FirebaseFirestore.instance
          .collection('chats')
          .where('receiverID', isEqualTo: user.uid)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: Colors.pink, // Set your preferred color
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.deepPurple),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                obscureText: true,
              ),
              Text(
                error ?? '',
                style: const TextStyle(color: Colors.red),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _deleteAccount();
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const EnteringPage()), // Navigate to HomePage
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete Account')),
            ],
          ),
        ),
      ),
    );
  }
}
