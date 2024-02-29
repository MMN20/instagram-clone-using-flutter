import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_instagram_clone/models/post.dart';
import 'package:my_instagram_clone/models/user.dart';
import 'package:my_instagram_clone/widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key, required this.post});
  final Post post;
  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(widget.post.profilePicUrl),
                backgroundColor: Colors.grey,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      width: 0.1,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                Comment comment = Comment(
                    uid: MyUser.currentUser!.uid,
                    text: _commentController.text,
                    profilePicUrl: MyUser.currentUser!.profilePicUrl,
                    pubDate: DateTime.now().toString(),
                    likes: 0,
                    postId: widget.post.postId);
                await comment.addComment(widget.post.postId);
              },
              icon: const Icon(
                Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text(
          'Comments',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage(MyUser.currentUser!.profilePicUrl),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: MyUser.currentUser!.username,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${widget.post.description}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 55),
            child: Text(
              DateFormat.yMMMd().format(DateTime.parse(widget.post.pubDate)),
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const Divider(
            color: Color.fromARGB(255, 51, 50, 50),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.post.postId)
                .collection('comments')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                children: snapshot.data!.docs
                    .map(
                      (e) => CommentCard(
                        comment: Comment(
                            uid: e['uid'],
                            commentId: e['commentId'],
                            text: e['text'],
                            profilePicUrl: e['profilePicUrl'],
                            pubDate: e['pubDate'],
                            likes: e['likes'].length,
                            postId: widget.post.postId),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
