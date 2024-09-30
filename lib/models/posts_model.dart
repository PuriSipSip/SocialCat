import 'package:cloud_firestore/cloud_firestore.dart';

class PostsModel {
  final String id;
  final String email;
  final String username;
  final String photoURL;
  final String imageURL;
  final String description;
  final String catname;
  final GeoPoint location;
  final Timestamp timestamp;
  final int likeCount;
  final List<String> likesBy;
  final List<String> comments;

  PostsModel({
    required this.id,
    required this.email,
    required this.username,
    required this.photoURL,
    required this.imageURL,
    required this.description,
    required this.catname,
    required this.location,
    required this.timestamp,
    required this.likeCount,
    required this.likesBy,
    required this.comments,
  });

  factory PostsModel.fromMap(Map<String, dynamic> data) {
    return PostsModel(
      id: data['id'],
      email: data['email'] ?? 'Unknown email',
      username: data['username'] ?? 'Unknown user',
      photoURL: data['photoURL'] ?? '',
      imageURL: data['imageURL'] ?? '',
      description: data['description'] ?? 'No description',
      catname: data['catname'] ?? 'Unknown cat',
      location: data['location'] as GeoPoint, // แปลงเป็น GeoPoint
      timestamp: data['timestamp'] as Timestamp, // แปลงเป็น Timestamp
      likeCount: data['likeCount'] ?? 0, // ค่าเริ่มต้น 0
      likesBy: List<String>.from(data['likesBy'] ?? []),
      comments: List<String>.from(data['comments'] ?? []),
    );
  }
}
