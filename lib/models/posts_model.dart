import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/comments_model.dart';

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
  final List<String> likesBy;
  final List<CommentsModel> comments;

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
    required this.likesBy,
    required this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoURL': photoURL,
      'imageURL': imageURL,
      'description': description,
      'catname': catname,
      'location': location,
      'timestamp': timestamp,
      'likesBy': likesBy,
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }

  factory PostsModel.fromMap(Map<String, dynamic> data) {
    return PostsModel(
      id: data['id'] ?? 'Unknown id',
      email: data['email'] ?? 'Unknown email',
      username: data['username'] ?? 'Unknown user',
      photoURL: data['photoURL'] ?? '',
      imageURL: data['imageURL'] ?? '',
      description: data['description'] ?? 'No description',
      catname: data['catname'] ?? 'Unknown cat',
      location: data['location'] as GeoPoint, // แปลงเป็น GeoPoint
      timestamp: data['timestamp'] as Timestamp, // แปลงเป็น Timestamp
      likesBy: List<String>.from(data['likesBy'] ?? []),
      comments: List<CommentsModel>.from(
          data['comments']?.map((comment) => CommentsModel.fromMap(comment)) ??
              []),
    );
  }
}
