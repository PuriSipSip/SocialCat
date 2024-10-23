import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_navigationscreen.dart';
import 'package:flutter_application_1/services/post_service.dart';

// สร้างฟังก์ชัน confirmDelete สําหรับแสดง dialog ยืนยันการลบโพสต์
void confirmDelete(BuildContext context, String postId, String imageURL) {
  final PostService postService = PostService();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('จะลบแน่ใจใช่มั้ยเหมียว',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
      content: const Text(
          'ข้อมูลโพสต์จะถูกลบไม่สามารถกู้คืนได้ คิดให้ดีนะเหมียว 🐈‍',
          style: TextStyle(fontSize: 14, color: Colors.black54)),
      actions: <Widget>[
        TextButton(
          child: const Text('ลบเลย',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          onPressed: () async {
            // เรียกใช้ service เพื่อลบโพสต์
            bool success = await postService.deletePost(postId, imageURL);

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
            'ไม่ละ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
