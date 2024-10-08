import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/post_service.dart';

class CommentComponent extends StatefulWidget {
  final String postId; // รับ postId เพื่อเพิ่มความคิดเห็นในโพสต์ที่เฉพาะเจาะจง

  const CommentComponent({super.key, required this.postId});

  @override
  _CommentComponentState createState() => _CommentComponentState();
}

class _CommentComponentState extends State<CommentComponent> {
  final TextEditingController _commentController = TextEditingController();
  final PostService _postService = PostService();

  void _submitComment() async {
    String comment = _commentController.text.trim();

    if (comment.isNotEmpty) {
      await _postService.addComment(widget.postId, comment);
      _commentController.clear(); // เคลียร์ฟิลด์กรอกข้อความหลังจากส่ง
      FocusScope.of(context).unfocus(); // ปิดคีย์บอร์ดหลังจากส่งข้อความสำเร็จ
    } else {
      // แสดงข้อความเตือนหากฟิลด์ว่าง
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'แบ่งปันความคิดเห็นด้วยกัน..',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.pets_outlined),
            color: Colors.black,
            onPressed: _submitComment, // เรียกใช้ฟังก์ชันเมื่อกดปุ่มส่ง
          ),
        ],
      ),
    );
  }
}
