import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // import Firebase Storage
import 'package:flutter_application_1/models/posts_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Firebase Storage instance

  // Add a new post to Firestore
  Future<void> createPost(PostsModel post) async {
    try {
      // Get the currently logged-in user's email
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String email = currentUser.email!;

        // Fetch user details from the Users collection using email
        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(email).get();

        // Cast the data to a Map<String, dynamic>
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        String username = userData?['username'] ?? ''; // Get username
        String photoURL = userData?['photoURL'] ?? ''; // Get photoURL

        // Step 1: Upload the image to Firebase Storage
        File imageFile = File(post.imageURL); // ใช้ path ของรูปภาพจากโพสต์
        String fileName =
            '${post.id}.jpg'; // ตั้งชื่อไฟล์รูปภาพให้เหมือนกับ ID ของโพสต์
        Reference ref = _storage
            .ref()
            .child('imageposts/$fileName'); // อัปโหลดไปที่โฟลเดอร์ imageposts/
        UploadTask uploadTask = ref.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;

        // Step 2: Get the image URL from Firebase Storage
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Step 3: Create the post using the image URL
        await _firestore.collection('Posts').doc(post.id).set({
          'username': username, // Use username instead of email
          'photoURL': photoURL, // Use photoURL
          'imageURL': imageUrl, // Use the URL from Firebase Storage
          'description': post.description,
          'catname': post.catname,
          'location': post.location, // Use location GeoPoint
          'timestamp': post.timestamp,
          'likesBy': post.likesBy,
        });
      } else {
        print('No user is logged in');
      }
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  //  Delete a post from Firestore
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('Posts').doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  // addComment to collection Posts
  Future<void> addComment(String postId, String comment) async {
    try {
      // ดึงข้อมูลผู้ใช้ที่แสดงความคิดเห็นได้ที่นี่
      User? currentUser = _auth.currentUser;
      String username = currentUser?.email ?? 'Anonymous';

      // เพิ่มความคิดเห็นในคอลเล็กชันย่อย
      await _firestore
          .collection('Posts')
          .doc(postId)
          .collection('comments')
          .add({
        'username': username,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }
}
