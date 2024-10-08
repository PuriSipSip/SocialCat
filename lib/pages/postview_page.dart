import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_comment.dart';
import 'package:flutter_application_1/models/posts_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/services/post_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostViewPage extends StatefulWidget {
  final PostsModel post;

  const PostViewPage({super.key, required this.post});

  @override
  _PostViewPageState createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  final PostService _postService = PostService();

  late PostsModel post;

  @override
  void initState() {
    super.initState();
    post = widget.post; // กำหนดค่าเริ่มต้นของ post
  }

  @override
  Widget build(BuildContext context) {
    // current logged in user
    final user = FirebaseAuth.instance.currentUser;

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
                // Avatar, username
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.more_horiz, color: Colors.grey[500]),
                      onPressed: () {},
                    ),
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

                // catname, iconlike, comment
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        post.catname,
                        style: const TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              post.likesBy.contains(
                                      user?.displayName ?? user?.email)
                                  ? Icons.favorite_rounded // ถ้ากด like
                                  : Icons
                                      .favorite_border_rounded, // ถ้ายังไม่กด
                              color: post.likesBy.contains(
                                      user?.displayName ?? user?.email)
                                  ? Colors.red // สีแดงถ้ากด like
                                  : Colors.black, // สีดำถ้ายังไม่กด
                            ),
                            onPressed: () async {
                              // Function like post
                              await _postService.likePost(post.id);
                              // Refresh the post data
                              final updatedPost =
                                  await _postService.getPostById(post.id);
                              // Update state with the new post data
                              setState(() {
                                if (updatedPost != null) {
                                  post =
                                      updatedPost; // Update post the latest data
                                }
                              });
                            },
                          ),
                          const SizedBox(
                            width: 0.5,
                          ),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.comment),
                            iconSize: 22,
                            color: Colors.black,
                            onPressed: () {
                              // Function comment
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
                    const Icon(Icons.favorite_rounded,
                        color: Colors.red, size: 16),
                    Text(
                      '${post.likesBy.length} likes',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const Divider(),

                // username, description
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${post.username}    ', // Username
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.lightBlue,
                          ),
                        ),
                        TextSpan(
                          text: post.description, // Description
                          style: TextStyle(
                            fontSize: 16,
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
        ),
        bottomSheet: CommentComponent(postId: post.id));
  }
}
