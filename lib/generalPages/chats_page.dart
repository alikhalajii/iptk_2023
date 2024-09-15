import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/generalPages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/globals.dart';

class ChatsPage extends StatefulWidget {
  final String? userID = Globals.userId;
  final Function(int) onTap;
  final int selectedIndex;

  ChatsPage({Key? key, required this.onTap, required this.selectedIndex})
      : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('senderID', isEqualTo: widget.userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final senderChats = snapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('receiverID', isEqualTo: widget.userID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final receiverChats = snapshot.data!.docs;

              final chats = <String, DocumentSnapshot>{};

              for (final message in senderChats) {
                final receiverID = message['receiverID'] as String;
                if (!chats.containsKey(receiverID) ||
                    isLaterMessage(message, chats[receiverID])) {
                  chats[receiverID] = message;
                }
              }

              for (final message in receiverChats) {
                final senderID = message['senderID'] as String;
                if (!chats.containsKey(senderID) ||
                    isLaterMessage(message, chats[senderID])) {
                  chats[senderID] = message;
                }
              }

              if (kDebugMode && chats.isEmpty) {
                if (chats.isEmpty) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onTap(0); // 0 is the index for 'Home' in your BottomNavigationBar
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: const Text(
                        'Book your first Spot to start a Chat!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
              }
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final userID = chats.keys.toList()[index];
                    final message = chats[userID];
                    String firstName =
                        ''; // Move the declaration outside the StreamBuilder
                    log('message: ${message!['messages']}');
                    // Query the 'users' collection to retrieve the user's name
                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return ListTile(
                            leading: const CircleAvatar(),
                            title: Text(userID == 'HH2sq2jC4mYCqiyV8zKFhmtCcoL2'
                                ? 'spaceXchange Admin'
                                : userID), // Display the user's ID or 'spaceXchange Admin'
                            subtitle: Text(message['messages'][0]['content'] ??
                                ''), // Display the last message or an empty string if it's null
                            trailing: Text(getFormattedTimestamp(
                                message['messages'][0]
                                ['time'])), // Display the formatted timestamp
                            onTap: () {
                              if (kDebugMode) {
                                print(
                                    'ChatPage is loading with SenderID: ${widget.userID!} and ReceiverID: $userID');
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    receiverID: userID,
                                    senderID: widget.userID!,
                                  ),
                                ),
                              ).then((value) {
                                // Update the isRead field to true after returning from the chat page
                                //FirebaseFirestore.instance.collection('chats').doc(message?.id).update({'isRead': true});
                              });
                            },
                          );
                        }
                        final user =
                        snapshot.data?.data() as Map<String, dynamic>?;
                        firstName = (user?['firstName']
                        as String); // Assign the retrieved name to the variable

                        return ListTile(
                          leading: const CircleAvatar(),
                          title: Text(firstName),
                          subtitle: Text(
                              (message['messages'].last['content'].length < 50)
                                  ? (message['messages'].last['content'])
                                  : message['messages']
                                  .last['content']
                                  .substring(0, 50) +
                                  '...'),
                          trailing: Text(getFormattedTimestamp(
                              message['messages'][0]['time'])),
                          onTap: () {
                            if (kDebugMode) {
                              print(
                                  'ChatPage is loading with SenderID: ${message['senderID']} and ReceiverID: ${message['receiverID']}');
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  receiverID: message['receiverID'],
                                  senderID: message['senderID'],
                                ),
                              ),
                            ).then((value) {
                            });
                          },
                        );
                      },
                    );
                  },
                );
              },
          );
        },
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
        currentIndex: widget.selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: widget.onTap,
      ),
    );
  }

  String getFormattedTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      final formatter = DateFormat('HH:mm a');
      return formatter.format(dateTime);
    }
    return '';
  }

  bool isLaterMessage(
      DocumentSnapshot newMessage, DocumentSnapshot? existingMessage) {
    final newTimestamp = newMessage['time'] as Timestamp;
    final existingTimestamp = existingMessage?['time'] as Timestamp?;
    return existingTimestamp == null ||
        newTimestamp.compareTo(existingTimestamp) > 0;
  }
}
