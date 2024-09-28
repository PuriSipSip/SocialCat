import 'dart:io';
import 'package:cross_file/cross_file.dart'; // นำเข้าถูกต้อง
import 'package:flutter/material.dart';

class AddpostPage extends StatelessWidget {
  final XFile image;
  const AddpostPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Post',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Center(
        child: Image.file(
          File(image.path), // แสดงรูปภาพที่ผู้ใช้เลือก/ถ่าย
        ),
      ),
    );
  }
}
