import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_instagram_clone/models/post.dart';
import 'package:my_instagram_clone/models/user.dart';
import 'package:my_instagram_clone/screens/comments_screen.dart';
import 'package:my_instagram_clone/screens/profile_screen.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});
  final Post post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeThisPost = false;
  @override
  void initState() {
    super.initState();
    setLikedThisPost();
  }

  void setLikedThisPost() async {
    bool result = await widget.post.isCurrentUserLikesThisPost();
    if (result != isLikeThisPost) {
      isLikeThisPost = result;
      setState(() {});
    }
  }

  void likeUnLike() async {
    isLikeThisPost = await widget.post.likeUnlike();
    setState(() {});
  }

  void onProfileTap() async {
    MyUser? user = await MyUser.findUserByID(widget.post.uid);

    Navigator.push(
        context, MaterialPageRoute(builder: (c) => ProfileScreen(user: user!)));
  }

  void openCommentsScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => CommentsScreen(
                  post: widget.post,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 5),
          child: Row(
            children: [
              InkWell(
                onTap: onProfileTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.post.profilePicUrl,
                      ),
                      backgroundColor: Colors.grey,
                      radius: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (c) => SimpleDialog(
                            children: [
                              SimpleDialogOption(
                                child: const Text('Delete'),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  if (MyUser.currentUser!.uid ==
                                      widget.post.uid) {
                                    await Post.deletePost(widget.post.postId);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'You are not the publisher of this post!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              )
                            ],
                          ));
                },
                icon: const Icon(
                  Icons.more_vert,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onDoubleTap: () {
            likeUnLike();
          },
          child: Image.network(
            widget.post.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 500,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: likeUnLike,
              icon: isLikeThisPost
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : const Icon(Icons.favorite_border),
            ),
            IconButton(
              onPressed: openCommentsScreen,
              icon: const Icon(
                Icons.comment_outlined,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.send,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.bookmark_border,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.post.likes.length} likes',
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              Text(
                widget.post.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                widget.post.description,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              InkWell(
                onTap: openCommentsScreen,
                child: Text(
                  'View all ${widget.post.comments} comments',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                DateFormat.yMMMd().format(
                  DateTime.parse(
                    widget.post.pubDate,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
