import 'package:cloud_firestore/cloud_firestore.dart';

class PostsModel {
  final String id;
  final String email; // ใช้ email ในการอ้างถึงข้อมูลผู้ใช้ of the poster
  final String imageURL;
  final String description;
  final String catname;
  final GeoPoint location;
  final Timestamp timestamp;
  final int likeCount; // like count of this post
  final List<String> likesBy; // like of user IDs who liked this post

  PostsModel({
    required this.id,
    required this.email, // ใช้ email ในการอ้างถึงข้อมูลผู้ใช้
    required this.imageURL,
    required this.description,
    required this.catname,
    required this.location,
    required this.timestamp,
    required this.likeCount,
    required this.likesBy,
  });

  // Convert a Firestore document to a PostsModel object (to use in the app)
  factory PostsModel.fromDocument(DocumentSnapshot doc) {
    return PostsModel(
      id: doc.id,
      email: doc['email'],
      imageURL: doc['imageURL'],
      description: doc['description'],
      catname: doc['catname'],
      location: doc['location'],
      timestamp: doc['timestamp'],
      likeCount: doc['likeCount'],
      likesBy: List<String>.from(doc['likesBy'] ?? []),
    );
  }

  // ฟังก์ชันแปลงข้อมูลเป็น Map เพื่อบันทึกลง Firestore
  // Convert a Post object to a map (to store in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'imageURL': imageURL,
      'description': description,
      'catname': catname,
      'location': location,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'likesBy': likesBy,
    };
  }
}

// Firestore Collection for storing Posts data
// Collection: Posts
// Fields: imageURL, description, catname, location, comments, likes
// User can comment and like posts
