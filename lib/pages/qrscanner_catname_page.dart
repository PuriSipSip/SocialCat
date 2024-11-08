import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrscannerCatnamePage extends StatefulWidget {
  const QrscannerCatnamePage({super.key});

  @override
  QrscannerCatnamePageState createState() => QrscannerCatnamePageState();
}

class QrscannerCatnamePageState extends State<QrscannerCatnamePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'QR Code Scanner',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Place Scan QR code in the area",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Scanning will be started automatically",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    QRView(
                      overlay: QrScannerOverlayShape(
                        borderColor: Colors.blue,
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                      ),
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "For SocialCat Application",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      if (result != null) {
        // ดึงชื่อแมวจาก Firestore ตาม catId
        String catId = result!.code!;
        final catDoc = await FirebaseFirestore.instance
            .collection('Cats')
            .doc(catId)
            .get();

        if (catDoc.exists) {
          // หยุดกล้องเมื่อพบข้อมูล
          controller.stopCamera();
          String catName = catDoc['catname'];

          // ส่งค่า catname กลับไปที่หน้า addpost_page.dart
          Navigator.pop(context, catName);
          // แสดงข้อความ Toast ว่าเจอชื่อแมว
          Fluttertoast.showToast(
            msg: 'นี่คือน้อง $catName เหมียว 🐱',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.lightBlueAccent,
            textColor: Colors.white,
          );
        } else {
          // แสดงข้อความเตือนหาก QR ไม่พบข้อมูล
          Fluttertoast.showToast(
            msg: 'ไม่มีข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey.shade300,
            textColor: Colors.black87,
          );
          // ให้กล้องทำงานต่อเมื่อไม่พบข้อมูล
          controller.resumeCamera();
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
