import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsModel {
  final String comment;
  final String username;
  final Timestamp timestamp;

  CommentsModel({
    required this.comment,
    required this.username,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'comment': comment,
      'username': username,
      'timestamp': timestamp,
    };
  }

  factory CommentsModel.fromMap(Map<String, dynamic> data) {
    return CommentsModel(
      comment: data['comment'],
      username: data['username'],
      timestamp: data['timestamp'],
    );
  }
}
