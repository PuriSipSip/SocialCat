import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/posts_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostViewPage extends StatelessWidget {
  final PostsModel post;

  const PostViewPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar , username
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(post.photoURL),
                      backgroundColor: Colors.grey[300],
                      radius: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      post.username,
                      style: const TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                        icon: Icon(Icons.more_horiz, color: Colors.grey[500]),
                        onPressed: () {})
                  ],
                ),

                const Divider(color: Colors.white),

                // imageURL
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: post.imageURL,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        size: 50,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // catname , iconlike , comment
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        post.catname,
                        style: const TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {
                              // funtion likepost
                            },
                          ),
                          const SizedBox(
                            width: 0.5,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline),
                            onPressed: () {
                              // funtion comment
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      timeago.format(post.timestamp.toDate()),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                    Text(
                      '${post.likesBy.length} likes',
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
                const Divider(),

                // username , description
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${post.username}    ', // Username
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.lightBlue,
                          ),
                        ),
                        TextSpan(
                          text: post.description, // Description
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
