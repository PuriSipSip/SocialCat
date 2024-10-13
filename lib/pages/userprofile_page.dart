import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/components/my_image_picker.dart';
import 'package:flutter_application_1/pages/editprofile_page.dart';
import 'package:flutter_application_1/auth/auth_page.dart';
import 'package:flutter_application_1/pages/postview_page.dart';
import 'package:flutter_application_1/models/posts_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class UserprofilePage extends StatefulWidget {
  const UserprofilePage({super.key});

  @override
  _UserprofilePageState createState() => _UserprofilePageState();
}

class _UserprofilePageState extends State<UserprofilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ฟังก์ชันดึงข้อมูลผู้ใช้และโพสต์จาก Firestore
  Future<Map<String, dynamic>> _getUserData() async {
    if (currentUser == null) {
      throw Exception('ไม่มีผู้ใช้ที่เข้าสู่ระบบ');
    }

    // ดึงข้อมูลผู้ใช้
  DocumentSnapshot userDoc = await _firestore.collection('Users').doc(currentUser!.email).get();
  
  // ดึงโพสต์ของผู้ใช้
  QuerySnapshot postsSnapshot = await _firestore.collection('Posts')
      .where('email', isEqualTo: currentUser!.email)
      .get();

  // เรียงลำดับข้อมูลหลังจากได้รับมาแล้ว
  List<Map<String, dynamic>> sortedPosts = postsSnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList()
    ..sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

  return {
    'user': userDoc.data() as Map<String, dynamic>,
    'posts': sortedPosts,
  };
}

  // ฟังก์ชันออกจากระบบ
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('ไม่มีข้อมูล'));
          }

          Map<String, dynamic> userData = snapshot.data!['user'];
          List<Map<String, dynamic>> userPosts = snapshot.data!['posts'];
          userPosts.sort((a, b) => //เปรียบเทียบค่าของ timestamp ของโพสต์ทั้งสอง
              (b['timestamp'] as Timestamp).compareTo(a['timestamp']));

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(userData),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileActions(context),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                      ),
                    ],
                  ),
                ),
                _buildPostsGrid(userPosts),
              ],
            ),
          );
        },
      ),
    );
  }

  // สร้าง AppBar ที่มีข้อมูลโปรไฟล์ผู้ใช้
  Widget _buildAppBar(Map<String, dynamic> userData) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildProfileHeader(userData),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(height: MediaQuery.of(context).padding.top),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'ออกจากระบบ',
          ),
        ),
      ],
    );
  }

  // สร้างส่วนหัวของโปรไฟล์ที่แสดงข้อมูลผู้ใช้
  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.lightBlueAccent, Colors.blue.shade400],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  CachedNetworkImageProvider(userData['photoURL'] ?? ''),
            ),
            const SizedBox(height: 16),
            Text(
              userData['username'] ?? 'ผู้ใช้',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              userData['email'] ?? 'ไม่มีอีเมล',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              userData['bio'] ?? 'loves cats!',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // สร้างปุ่มสำหรับการดำเนินการกับโปรไฟล์
  Widget _buildProfileActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
                setState(() {});
              },
              icon: Icon(Icons.edit, color: Colors.grey[700]),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                backgroundColor: Colors.grey[200],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => showImagePickerBottomSheet(context),
              icon: const Icon(Icons.add_outlined, color: Colors.white),
              label: const Text('New Post'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // สร้างกริดแสดงโพสต์ของผู้ใช้
  Widget _buildPostsGrid(List<Map<String, dynamic>> posts) {
    return SliverPadding(
      padding: const EdgeInsets.all(0),
      sliver: SliverGrid(
        gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
            pattern: const [
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
            ]),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                // สร้าง PostsModel จากข้อมูลโพสต์
                PostsModel post = PostsModel.fromMap(posts[index]);
                // นำทางไปยังหน้า PostViewPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostViewPage(post: post),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: posts[index]['imageURL'] ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            );
          },
          childCount: posts.length,
        ),
      ),
    );
  }
}
