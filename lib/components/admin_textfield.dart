import 'package:flutter/material.dart';

// TextField สําหรับเพิ่มข้อมูลแมวในระบบ ไม่ได้ใช้
class AdminTextField extends StatelessWidget {
  final String labelText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  const AdminTextField({
    super.key,
    required this.labelText,
    required this.prefixIcon,
    required this.controller,
    this.minLines = 1, // ค่าเริ่มต้นคือ 1 บรรทัด
    this.maxLines = 1, // ค่าเริ่มต้นคือ 1 บรรทัด
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            prefixIcon,
            size: 22,
          ),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      minLines: minLines,
      maxLines: maxLines,
    );
  }
}
