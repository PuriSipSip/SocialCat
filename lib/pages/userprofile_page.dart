import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/pages/editprofile_page.dart';
import 'package:flutter_application_1/auth/auth_page.dart';
import 'package:flutter_application_1/pages/postview_page.dart';
import 'package:flutter_application_1/models/posts_model.dart';

class UserprofilePage extends StatefulWidget {
  UserprofilePage({Key? key}) : super(key: key);

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

    return {
      'user': userDoc.data() as Map<String, dynamic>,
      'posts': postsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList(),
    };
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AuthPage()),
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
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('ไม่มีข้อมูล'));
          }

          Map<String, dynamic> userData = snapshot.data!['user'];
          List<Map<String, dynamic>> userPosts = snapshot.data!['posts'];

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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'โพสต์ของฉัน',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
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
      expandedHeight: 300.0,
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
            icon: Icon(Icons.logout, color: Colors.white),
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
          colors: [Colors.blue.shade700, Colors.blue.shade500],
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
              backgroundImage: CachedNetworkImageProvider(userData['photoURL'] ?? ''),
            ),
            SizedBox(height: 16),
            Text(
              userData['username'] ?? 'ผู้ใช้',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              userData['email'] ?? 'ไม่มีอีเมล',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              userData['bio'] ?? 'ไม่มีประวัติ',
              style: TextStyle(fontSize: 16, color: Colors.white70),
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
      padding: EdgeInsets.all(16.0),
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
              icon: Icon(Icons.edit, color: Colors.black),
              label: Text('แก้ไขโปรไฟล์'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                
              },
              icon: Icon(Icons.message, color: Colors.white),
              label: Text('ติดต่อ'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12),
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
      padding: EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
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
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: posts[index]['imageURL'] ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error, color: Colors.red),
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
