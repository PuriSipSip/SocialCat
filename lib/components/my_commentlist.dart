import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  final String
      postId; // รับ postId เพื่อดึงข้อมูลความคิดเห็นของโพสต์ที่เฉพาะเจาะจง

  const CommentList({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading comments.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No comments yet.'));
        }

        final comments = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true, // ปรับขนาดของ ListView ให้อิงตามจำนวนความคิดเห็น
          physics:
              const NeverScrollableScrollPhysics(), // ปิดการ scroll ของ ListView
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final commentData = comments[index].data() as Map<String, dynamic>;
            final username = commentData['username'] ?? 'Anonymous';
            final comment = commentData['comment'] ?? '';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$username    ', // Username
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.lightBlue,
                      ),
                    ),
                    TextSpan(
                      text: comment, // Comment
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
