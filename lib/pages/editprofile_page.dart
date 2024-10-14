import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  String? _currentPhotoURL;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // โหลดข้อมูลผู้ใช้จาก Firestore
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _usernameController.text = userData['username'] ?? '';
          _bioController.text = userData['bio'] ?? '';
          _currentPhotoURL = userData['photoURL'];
        });
      }
    } catch (e) {
      _showErrorSnackBar('เกิดข้อผิดพลาดในการโหลดข้อมูลผู้ใช้: $e');
    }
    setState(() => _isLoading = false);
  }

  // เลือกรูปภาพจากแกลเลอรี่
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // อัพเดทโปรไฟล์ผู้ใช้
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String? imageUrl = await _uploadProfileImage(user);
          await _updateUserData(user, imageUrl);
          if (imageUrl != null) {
            await _updateUserPosts(user, imageUrl);
          }
          _showSuccessSnackBar('อัพเดทโปรไฟล์สำเร็จ');
          Navigator.pop(context);
        }
      } catch (e) {
        _showErrorSnackBar('เกิดข้อผิดพลาดในการอัพเดทโปรไฟล์: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  // อัพโหลดรูปภาพโปรไฟล์ไปยัง Firebase Storage
  Future<String?> _uploadProfileImage(User user) async {
    if (_image != null) {
      String fileName = 'profile_${user.uid}.jpg';
      Reference ref =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await ref.putFile(_image!);
      return await ref.getDownloadURL();
    }
    return null;
  }

  // อัพเดทข้อมูลผู้ใช้ใน Firestore
  Future<void> _updateUserData(User user, String? imageUrl) async {
    Map<String, dynamic> updateData = {
      'username': _usernameController.text,
      'bio': _bioController.text,
    };
    if (imageUrl != null) {
      updateData['photoURL'] = imageUrl;
    }
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .update(updateData);
  }

  // อัพเดท photoURL ในโพสต์ทั้งหมดของผู้ใช้
  Future<void> _updateUserPosts(User user, String imageUrl) async {
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .where('email', isEqualTo: user.email)
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in postsSnapshot.docs) {
      batch.update(doc.reference, {'photoURL': imageUrl});
    }
    await batch.commit();
  }

  // แสดง SnackBar แจ้งเตือนข้อผิดพลาด
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // แสดง SnackBar แจ้งเตือนสำเร็จ
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileImage(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUsernameField(),
                          SizedBox(height: 16),
                          _buildBioField(),
                          SizedBox(height: 24),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // สร้างส่วนหัวของโปรไฟล์
  Widget _buildProfileImage() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _image != null
                ? FileImage(_image!)
                : (_currentPhotoURL != null
                    ? NetworkImage(_currentPhotoURL!)
                    : null) as ImageProvider?,
            backgroundColor: Colors.grey[200],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // สร้าง Widget สำหรับแสดงและเลือกรูปโปรไฟล์
  Widget _buildselectProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _image != null
                ? FileImage(_image!)
                : (_currentPhotoURL != null
                    ? NetworkImage(_currentPhotoURL!)
                    : null) as ImageProvider?,
            backgroundColor: Colors.grey[300],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // สร้าง Widget สำหรับกรอกชื่อผู้ใช้
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณากรอกชื่อผู้ใช้';
        }
        return null;
      },
    );
  }

  // สร้าง Widget สำหรับกรอกประวัติย่อ
  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      decoration: InputDecoration(
        labelText: 'Bio',
        prefixIcon: const Icon(Icons.edit),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: 1,
    );
  }

  // สร้างปุ่มบันทึกการเปลี่ยนแปลง
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Save Changes',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
