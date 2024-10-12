import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_navigationscreen.dart';
import 'package:flutter_application_1/services/post_service.dart';

// สร้างฟังก์ชัน confirmDelete สําหรับแสดง dialog ยืนยันการลบโพสต์
void confirmDelete(BuildContext context, String postId) {
  final PostService postService = PostService();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Post'),
      content: const Text('Are you sure you want to delete this post?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onPressed: () async {
            // เรียกใช้ service เพื่อลบโพสต์
            bool success = await postService.deletePost(postId);

            if (success) {
              // ปิด dialog
              Navigator.of(context).pop(); // ปิด dialog

              // กลับไปที่หน้า NavigationScreen โดยปิดหน้าทั้งหมดจนถึง HomePage
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const NavigationScreen()));
            } else {
              // แสดงข้อความแจ้งเตือนกรณีลบไม่สำเร็จ
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to delete post')),
              );
            }
          },
        ),
        TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.grey[500]),
          onPressed: () {
            Navigator.of(context).pop(); // ปิด dialog
          },
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
