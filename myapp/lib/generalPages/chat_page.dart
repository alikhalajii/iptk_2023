import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/globals.dart';
import 'package:myapp/service.dart';

class ChatPage extends StatefulWidget {
  final String receiverID;
  final String senderID;

  const ChatPage({
    Key? key,
    required this.receiverID,
    required this.senderID,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  String chatID = '';
  late String displayName = '';
  late String profilePictureURL =
      'https://cdn.pixabay.com/photo/2017/06/13/12/54/profile-2398783_960_720.png';
  var messages = [];

  Future<void> fetchDisplayName() async {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    String otherUserID = widget.receiverID;
    if (widget.receiverID == currentUserID) otherUserID = widget.senderID;

    final otherUserSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserID)
        .get();

    final otherUserData = otherUserSnapshot.data();
    final firstName = otherUserData?['firstName'] as String?;
    setState(() {
      displayName = firstName ?? 'Chat';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (displayName == '') {
      fetchDisplayName();
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              // ignore: unnecessary_null_comparison
              backgroundImage: profilePictureURL != null
                  ? NetworkImage(profilePictureURL)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(displayName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('senderID', isEqualTo: widget.senderID)
                  .where('receiverID', isEqualTo: widget.receiverID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  if (kDebugMode) {
                    print('No DATA EXITING!');
                  }
                  return const Center(child: CircularProgressIndicator());
                }
                messages = snapshot.data!.docs[0]['messages'];
                chatID = snapshot.data!.docs[0].id;

                messages.sort((a, b) {
                  final aData = a as Map<String, dynamic>;
                  final bData = b as Map<String, dynamic>;

                  final aTimestamp =
                      aData['time'] as Timestamp? ?? Timestamp.now();
                  final bTimestamp =
                      bData['time'] as Timestamp? ?? Timestamp.now();

                  return bTimestamp.compareTo(aTimestamp);
                });

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index] as Map<String, dynamic>;
                    final senderID = messageData['sender'] as String? ?? '';
                    log(senderID);
                    final messageContent =
                        messageData['content'] as String? ?? '';
                    final isMe = senderID == widget.senderID;
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc((senderID == 'system')
                              ? Globals.userId
                              : senderID)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return senderID != "system"
                            ? Align(
                                alignment: isMe
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Container(
                                  margin: const EdgeInsets.all(5.0),
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color:
                                        isMe ? Colors.pink : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Text(
                                    messageContent,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: const EdgeInsets.all(5.0),
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          messageContent,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Write your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      messages.add({
                        'sender': Globals.userId,
                        'content': _messageController.text,
                        'time': Timestamp.now(),
                      });
                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatID)
                          .update({'messages': messages});
                      _messageController.clear();
                    }

                    /// importing service.dart - call send newMessageNotification()
                    DocumentSnapshot receiverSnapshot = await FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(widget.receiverID)
                        .get();
                    String? oneSignalUserId = receiverSnapshot.get('oneSignal');
                    if (oneSignalUserId != null) {
                      Service().sendNewMessageNotification(oneSignalUserId);
                    }
                    //
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
