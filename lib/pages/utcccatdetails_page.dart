// หน้านี้แสดงข้อมูลรายละเอียดเพิ่มเติมของแมวแต่ละตัว
import 'package:flutter/material.dart';

class CatDetailsPage extends StatelessWidget {
  final String catId;

  const CatDetailsPage({super.key, required this.catId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Details'),
      ),
      body: Center(
        child: Text('แสดงข้อมูลเพิ่มเติมของแมว ID: $catId'),
      ),
    );
  }
}
