import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/posts_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostViewPage extends StatelessWidget {
  final PostsModel post;

  const PostViewPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          post.catname,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400, // กำหนดความกว้างของภาพ
              height: 300, // กำหนดความสูงของภาพ
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: post.imageURL,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, size: 50),
                  fit: BoxFit.cover, // ปรับให้รูปภาพเต็มขนาดของ Container
                ),
              ),
            ),

            // description
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    post.description,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
