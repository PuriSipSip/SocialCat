import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  final String catId; // รับ catId เป็น parameter

  const QRCodePage(
      {super.key, required this.catId}); // Constructor สำหรับรับค่า catId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code   $catId'),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: QrImageView(
          data: catId, // ใช้ catId ในการสร้าง QR code
          version: QrVersions.auto,
          size: 300.0, // ขนาดของ QR code
        ),
      ),
    );
  }
}
