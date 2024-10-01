import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String imagePath;

  const ImagePreview({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        height: 250,
        width: double.infinity,
      ),
    );
  }
}
