import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/components/my_image_picker.dart';
import 'package:flutter_application_1/pages/postview_page.dart';
import 'package:flutter_application_1/models/posts_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // ตรวจสอบให้แน่ใจว่าคุณนำเข้า PostsModel

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // current logged in user
  final user = FirebaseAuth.instance.currentUser!;

  // sign user out method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'POST',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: 2),
              ),
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final snap = snapshot.data!.docs[index];
                    final String imageURL = snap[
                        'imageURL']; // เปลี่ยนให้ตรงกับชื่อฟิลด์ใน Firestore

                    return GestureDetector(
                      onTap: () {
                        // ตรวจสอบว่ามีข้อมูลใน snap หรือไม่
                        final snapData = snap.data() as Map<String, dynamic>?;
                        if (snapData != null) {
                          final post = PostsModel.fromMap(snapData);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostViewPage(post: post),
                            ),
                          );
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0), // ขอบ
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageURL,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
                gridDelegate: SliverQuiltedGridDelegate(
                  crossAxisSpacing: 3,
                  crossAxisCount: 3,
                  mainAxisSpacing: 3,
                  pattern: const [
                    QuiltedGridTile(2, 2),
                    QuiltedGridTile(1, 1),
                    QuiltedGridTile(1, 1),
                    QuiltedGridTile(1, 1),
                    QuiltedGridTile(1, 1),
                    QuiltedGridTile(1, 1),
                    QuiltedGridTile(1, 1),
                    QuiltedGridTile(2, 2),
                    QuiltedGridTile(1, 1),
                    QuiltedGridTile(1, 1),
                    QuiltedGridTile(1, 1),
                    QuiltedGridTile(1, 1),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showImagePickerBottomSheet(context),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(
          Icons.add_a_photo_rounded,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
