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
  String? _originalUsername; // เก็บ username เดิมเพื่อตรวจสอบการเปลี่ยนแปลง

  @override
  void initState() {
    super.initState();
    _loadUserData(); // โหลดข้อมูลผู้ใช้เมื่อเริ่มต้นหน้า
  }

  // โหลดข้อมูลผู้ใช้จาก Firestore
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ดึงข้อมูลผู้ใช้จาก collection Users โดยใช้ email เป็น key
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        
        // กำหนดค่าให้กับ controller และตัวแปรต่างๆ
        setState(() {
          _usernameController.text = userData['username'] ?? '';
          _originalUsername = userData['username']; 
          _bioController.text = userData['bio'] ?? '';
          _currentPhotoURL = userData['photoURL'];
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading user data: $e');
    }
    setState(() => _isLoading = false);
  }

  // อัพโหลดรูปภาพโปรไฟล์ไปยัง Firebase Storage
  Future<String?> _uploadProfileImage(User user) async {
    if (_image != null) {
      // สร้างชื่อไฟล์จาก uid ของผู้ใช้
      String fileName = 'profile_${user.uid}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await ref.putFile(_image!);
      return await ref.getDownloadURL();
    }
    return null;
  }

  // อัพเดทข้อมูลผู้ใช้ใน Firestore
  Future<void> _updateUserData(User user, String? imageUrl) async {
    // สร้าง Map เก็บข้อมูลที่จะอัพเดท
    Map<String, dynamic> updateData = {
      'username': _usernameController.text,
      'bio': _bioController.text,
    };
    if (imageUrl != null) {
      updateData['photoURL'] = imageUrl;
    }
    
    // อัพเดทข้อมูลใน collection Users
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .update(updateData);

    // ถ้ามีการเปลี่ยนแปลง username ให้อัพเดทข้อมูลในโพสต์ด้วย
    if (_originalUsername != _usernameController.text) {
      await _updateUserPosts(user, imageUrl);
    }
  }

  // อัพเดท username และ photoURL ในโพสต์ทั้งหมดของผู้ใช้
  Future<void> _updateUserPosts(User user, String? imageUrl) async {
    // ดึงโพสต์ทั้งหมดของผู้ใช้
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .where('email', isEqualTo: user.email)
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    
    for (var doc in postsSnapshot.docs) {
      Map<String, dynamic> updateData = {
        'username': _usernameController.text,
      };
      if (imageUrl != null) {
        updateData['photoURL'] = imageUrl;
      }
      batch.update(doc.reference, updateData);
    }
    
    await batch.commit();
  }

  // อัพเดทโปรไฟล์ทั้งหมด
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String? imageUrl = await _uploadProfileImage(user);
          await _updateUserData(user, imageUrl);
          _showSuccessSnackBar('อัพเดทโปรไฟล์สำเร็จ');
          Navigator.pop(context);
        }
      } catch (e) {
        _showErrorSnackBar('เกิดข้อผิดพลาดในการอัพเดทโปรไฟล์: $e');
      }
      setState(() => _isLoading = false);
    }
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
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.lightBlue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImage(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => 
                              value?.isEmpty ?? true ? 'Please enter a username' : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _bioController,
                            decoration: InputDecoration(
                              labelText: 'Bio',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            child: Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

    // สร้าง Widget สำหรับแสดงและเลือกรูปโปรไฟล์
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

  // เลือกรูปภาพจากแกลลอรี่
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }
}
