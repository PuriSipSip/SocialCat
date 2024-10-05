import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_imagepreview.dart';
import 'package:flutter_application_1/components/my_postbutton.dart';
import 'package:flutter_application_1/components/my_textinputfield.dart';
import 'package:flutter_application_1/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/posts_model.dart';
import 'package:flutter_application_1/services/post_service.dart';

class AddpostPage extends StatefulWidget {
  final XFile image;
  const AddpostPage({super.key, required this.image});

  @override
  _AddpostPageState createState() => _AddpostPageState();
}

class _AddpostPageState extends State<AddpostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _catNameController = TextEditingController();
  GeoPoint? _currentLocation;
  bool _isLoading = false;
  String? _currentAddress;

  // import location service
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // ฟังก์ชัน _requestLocationPermission
  Future<void> _requestLocationPermission() async {
    await _locationService.requestLocationPermission();
    _getCurrentLocation();
  }

  // ฟังก์ชันดึงตำแหน่งปัจจุบัน
  Future<void> _getCurrentLocation() async {
    _currentLocation = await _locationService.getCurrentLocation();
    if (_currentLocation != null) {
      _getCurrentAddress(
          _currentLocation!.latitude, _currentLocation!.longitude);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get location')),
      );
    }
  }

  // ฟังก์ชันแสดงแปลงพิกัดเป็นชื่อสถานที่
  Future<void> _getCurrentAddress(double latitude, double longitude) async {
    String? address =
        await _locationService.getCurrentAddress(latitude, longitude);
    setState(() {
      _currentAddress = address;
    });
  }

  // ฟังก์ชันสร้างโพสต์
  Future<void> _createPost() async {
    if (_currentLocation == null) {
      print('Location not available');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // สร้าง PostsModel object
    PostsModel post = PostsModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: '', // email of Poster
      username: '', // username of Poster
      photoURL: '', // photoURL of Poster
      imageURL: widget.image.path,
      description: _descriptionController.text,
      catname: _catNameController.text,
      location: _currentLocation!,
      timestamp: Timestamp.now(),
      likesBy: [],
      comments: [],
    );

    // เรียกใช้ service เพื่อสร้างโพสต์
    PostService postService = PostService();
    await postService.createPost(post);

    setState(() {
      _isLoading = false;
    });

    // กลับไปยังหน้า Home หรือแสดงข้อความยืนยัน
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.lightBlue),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImagePreview(imagePath: widget.image.path),

            const SizedBox(height: 16),

            TextInputField(
              controller: _descriptionController,
              labelText: 'Description',
            ),
            TextInputField(
              controller: _catNameController,
              labelText: 'Cat Name',
            ),

            const SizedBox(height: 16),

            // เมื่อได้รับพิกัดแล้ว เรียกฟังก์ชันเพื่อแปลงเป็นชื่อสถานที่
            if (_currentAddress != null)
              Text(
                'Location: $_currentAddress (${_currentLocation?.latitude}, ${_currentLocation?.longitude})',
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 16),
            PostButton(
              isLoading: _isLoading,
              onPressed: _createPost,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _catNameController.dispose();
    super.dispose();
  }
}
