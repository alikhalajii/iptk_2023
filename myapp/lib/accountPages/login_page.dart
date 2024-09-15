// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/globals.dart';

final _firebase = FirebaseAuth.instance;
var _enteredEmail = '';
var _enteredPassword = '';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    try {
      await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);
      if (mounted) {
        await Globals.convertFutureToList();
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Login failed'),
        ),
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Log In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  decoration: const InputDecoration(
                    label: Text('E-mail address'),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  initialValue: "",
                  onSaved: (value) {
                    _enteredEmail = value!;
                  }),
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Password'),
                ),
                obscureText: true,
                initialValue: "",
                onSaved: (value) {
                  _enteredPassword = value!;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
