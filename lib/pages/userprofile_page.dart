import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserprofilePage extends StatelessWidget {
  UserprofilePage({Key? key}) : super(key: key);

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _getUserData() async {
    if (currentUser == null) {
      throw Exception('No user logged in');
    }
    
    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(currentUser!.email).get();
    QuerySnapshot postsSnapshot = await _firestore.collection('Posts')
        .where('username', isEqualTo: userDoc['username'])
        .get();

    return {
      'user': userDoc.data() as Map<String, dynamic>,
      'posts': postsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList(),
    };
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          Map<String, dynamic> userData = snapshot.data!['user'];
          List<Map<String, dynamic>> userPosts = snapshot.data!['posts'];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(userData),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileActions(),
                    SizedBox(height: 10),
                    Text('Posts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              _buildPostsGrid(userPosts),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue.shade700, Colors.blue.shade500],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: CachedNetworkImageProvider(userData['photoURL'] ?? ''),
        ),
        SizedBox(height: 10),
        Text(
          userData['username'] ?? 'User',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 5),
        Text(
          userData['email'] ?? 'No email available',  // เปลี่ยนจาก bio เป็น email
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    ),
  );
}

  Widget _buildProfileActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement edit profile functionality
              },
              child: Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.grey[300],
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement contact functionality
              },
              child: Text('Contact'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(List<Map<String, dynamic>> posts) {
    return SliverPadding(
      padding: EdgeInsets.all(10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: posts[index]['imageURL'] ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[300]),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            );
          },
          childCount: posts.length,
        ),
      ),
    );
  }
}

