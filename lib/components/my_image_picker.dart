import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_qrscanner.dart';
import 'package:flutter_application_1/pages/addcat_page.dart';
import 'package:flutter_application_1/pages/addpost_page.dart';
import 'package:flutter_application_1/pages/edit_deleate_cat_page.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showImagePickerBottomSheet(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  XFile? image;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isAdmin = currentUser?.email == 'admin@socialcat.com' ? true : false;

  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () async {
              image = await picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                Navigator.pop(context); // ปิด bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddpostPage(image: image!),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                Navigator.pop(context); // ปิด bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddpostPage(image: image!),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner_rounded),
            title: const Text('Scan QR Code'),
            onTap: () async {
              Navigator.pop(context); // ปิด bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScanner(),
                ),
              );
            },
          ),
          // แสดง ListTile เฉพาะเมื่อเมื่อใช้อีเมลเป็น admin
          isAdmin
              ? ListTile(
                  leading: const Icon(Icons.admin_panel_settings,
                      color: Colors.blue),
                  title: const Text('Admin เพิ่มข้อมูลแมว',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () async {
                    image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      Navigator.pop(context); // ปิด bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCatPage(image: image!),
                        ),
                      );
                    }
                  },
                )
              : Container(),
          isAdmin
              ? ListTile(
                  leading: const Icon(Icons.admin_panel_settings,
                      color: Colors.blue),
                  title: const Text('Admin แก้ไขหรือลบข้อมูลแมว',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () async {
                    Navigator.pop(context); // ปิด bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditAndDeleteCatPage(),
                      ),
                    );
                  },
                )
              : Container(),
        ],
      );
    },
  );
}
