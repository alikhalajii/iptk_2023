import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationData {
  final String id;
  final Timestamp timestamp;
  final String message;
  final String title;
  final String body;

  NotificationData({
    required this.id,
    required this.timestamp,
    required this.message,
    required this.title,
    required this.body,
  });

  factory NotificationData.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return NotificationData(
      id: data['id'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      message: data['message'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
    );
  }
}
