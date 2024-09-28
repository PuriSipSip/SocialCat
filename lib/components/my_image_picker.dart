import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/addpost_page.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showImagePickerBottomSheet(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  XFile? image;

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
        ],
      );
    },
  );
}
