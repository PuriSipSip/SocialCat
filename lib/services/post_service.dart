import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // import Firebase Storage
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/posts_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Firebase Storage instance
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('Posts');

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
          'id': post.id,
          'email': email, // Use email instead of ID
          'username': username, // Use username instead of email
          'photoURL': photoURL, // Use photoURL
          'imageURL': imageUrl, // Use the URL from Firebase Storage
          'description': post.description,
          'catname': post.catname,
          'location': post.location, // Use location GeoPoint
          'timestamp': post.timestamp,
          'likesBy': post.likesBy,
        });

        // แสดงข้อความ Toast ว่าเพิ่มสำเร็จ
        Fluttertoast.showToast(
          msg:
              'โพสต์ถูกเพิ่มแล้ว 😽 \n อย่าลืมเข้าไปแสดงความคิดเห็นด้วยละเหมียว 🐱',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.lightBlueAccent,
          textColor: Colors.white,
        );
      } else {
        print('No user is logged in');
      }
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  // addComment to collection Posts
  Future<void> addComment(String postId, String comment) async {
    try {
      // ดึงข้อมูลผู้ใช้ที่แสดงความคิดเห็น
      User? currentUser = _auth.currentUser;
      String email = currentUser?.email ?? 'Anonymous';

      // ดึง username จากคอลเล็กชัน Users โดยใช้ email
      DocumentSnapshot userSnapshot = await _firestore
          .collection('Users')
          .doc(email) // ใช้ email เป็น docId ถ้าคุณเก็บข้อมูลแบบนี้
          .get();

      String username =
          userSnapshot.exists ? userSnapshot['username'] : 'Anonymous';

      // เพิ่มความคิดเห็นในคอลเล็กชันย่อย
      await _firestore
          .collection('Posts')
          .doc(postId)
          .collection('comments')
          .add({
        'commentId': DateTime.now()
            .millisecondsSinceEpoch
            .toString(), // เก็บ commentId ไว้
        'username': username,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<void> likePost(String postId) async {
    final user = _auth.currentUser; // รับข้อมูลผู้ใช้ที่เข้าสู่ระบบ
    if (user == null) return; // ตรวจสอบว่าผู้ใช้ล็อกอินอยู่หรือไม่

    String email = user.email ?? "Unknown"; // รับอีเมลของผู้ใช้

    DocumentReference postRef = _postsCollection.doc(postId);

    // เริ่มทำการเรียกข้อมูลโพสต์
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      Map<String, dynamic>? postData =
          postSnapshot.data() as Map<String, dynamic>?;

      if (postData != null) {
        List<String> likesBy = List<String>.from(postData['likesBy'] ?? []);

        if (likesBy.contains(email)) {
          likesBy.remove(email); // ลบอีเมลถ้าผู้ใช้กดไลค์แล้ว
        } else {
          likesBy.add(email); // เพิ่มอีเมลถ้าผู้ใช้กดยังไม่ไลค์
        }

        // Update the Firestore document
        transaction.update(postRef, {'likesBy': likesBy});
      } else {
        throw Exception("Post data is null!");
      }
    });
  }

  Future<PostsModel?> getPostById(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await _postsCollection.doc(postId).get();
      if (postSnapshot.exists) {
        Map<String, dynamic>? postData =
            postSnapshot.data() as Map<String, dynamic>?;
        // สร้างและคืนค่า PostsModel จากข้อมูลที่ดึงมา
        return PostsModel.fromMap(postData!);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // funtion Deleate Post
  // deletePost -> check email -> confirmdelete -> delete -> show toast -> go to HomePage
  Future<bool> deletePost(String postId, String imageURL) async {
    try {
      await _postsCollection.doc(postId).delete();
      // Delate sub-collection comments of post
      await _firestore
          .collection('Posts')
          .doc(postId)
          .collection('comments')
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
      await FirebaseStorage.instance.refFromURL(imageURL).delete();
      // แสดงข้อความ Toast ว่าลบสำเร็จ
      Fluttertoast.showToast(
        msg: 'โพสต์โดนลบแล้ว 🙀 \nอย่าลืมกลับมาลงรูปภาพอีกนะเหมียว 😽',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return true;
    } catch (e) {
      // แสดงข้อความ Toast กรณีลบไม่สำเร็จ
      Fluttertoast.showToast(
        msg: 'Failed to delete post: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return false;
    }
  }
}
