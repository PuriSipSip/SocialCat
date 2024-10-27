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
  String? _originalUsername; // Store original username to check if it changed

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firestore
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
          _originalUsername = userData['username']; // Store original username
          _bioController.text = userData['bio'] ?? '';
          _currentPhotoURL = userData['photoURL'];
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading user data: $e');
    }
    setState(() => _isLoading = false);
  }

  // Upload profile image to Firebase Storage
  Future<String?> _uploadProfileImage(User user) async {
    if (_image != null) {
      String fileName = 'profile_${user.uid}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await ref.putFile(_image!);
      return await ref.getDownloadURL();
    }
    return null;
  }

  // Update user data in Firestore
  Future<void> _updateUserData(User user, String? imageUrl) async {
    Map<String, dynamic> updateData = {
      'username': _usernameController.text,
      'bio': _bioController.text,
    };
    if (imageUrl != null) {
      updateData['photoURL'] = imageUrl;
    }
    
    // Update user document
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .update(updateData);

    // Only update posts if username changed
    if (_originalUsername != _usernameController.text) {
      await _updateUserPosts(user, imageUrl);
    }
  }

  // Update username and photo URL in all user's posts
  Future<void> _updateUserPosts(User user, String? imageUrl) async {
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

  // Update profile with all changes
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String? imageUrl = await _uploadProfileImage(user);
          await _updateUserData(user, imageUrl);
          _showSuccessSnackBar('Profile updated successfully');
          Navigator.pop(context);
        }
      } catch (e) {
        _showErrorSnackBar('Error updating profile: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // UI implementation remains the same...
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
