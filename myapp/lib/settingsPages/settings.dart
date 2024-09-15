import 'package:flutter/material.dart';

import 'package:myapp/homePages/entering_page.dart';
import 'package:myapp/settingsPages/my_parking_spots.dart';
import 'package:myapp/accountPages/account_details_page.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key, required this.onTap, required this.selectedIndex})
      : super(key: key);
  final Function(int) onTap;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Account'),
      ),
      body: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildButton(
                Icons.manage_accounts_rounded,
                context,
                'Account Details',
                Icons.arrow_forward_ios,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountDetailsPage()),
                  );
                },
              ),
              _buildButton(
                Icons.local_parking,
                context,
                'My Parking Spots',
                Icons.arrow_forward_ios,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyParkingSpotsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'For you',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_rounded),
            label: 'Account',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onTap,
      ),
    );
  }

  // Helper method to build buttons
  Widget _buildButton(IconData iconbeforeText, BuildContext context,
      String label, IconData iconAfterText, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onPressed: () {
          if (label == 'Logout') {
            // Perform logout functionality
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const EnteringPage()),
              (Route<dynamic> route) => false,
            );
          } else {
            onPressed();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(iconbeforeText, size: 28),
                  const SizedBox(width: 16.0),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(iconAfterText, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
