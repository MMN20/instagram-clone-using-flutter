import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_instagram_clone/models/post.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({super.key, required this.comment});
  final Comment comment;
  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool didILikeThisComment = false;

  @override
  void initState() {
    super.initState();
    setLikedThisComment();
  }

  void setLikedThisComment() async {
    didILikeThisComment = await widget.comment.didILikeThisComment();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (c) => SimpleDialog(
                  children: [
                    SimpleDialogOption(
                      child: const Text('Delete'),
                      onPressed: () async {
                        Navigator.pop(context);
                        await Comment.deleteComment(
                            widget.comment.postId, widget.comment.commentId);
                      },
                    )
                  ],
                ));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.comment.profilePicUrl),
        ),
        title: Text(widget.comment.text),
        subtitle: Row(
          children: [
            Text(
              DateFormat.yMMMd().format(
                DateTime.parse(widget.comment.pubDate),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              '${widget.comment.likes} likes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: IconButton(
            onPressed: () async {
              didILikeThisComment = await widget.comment.likeUnlikeAComment();
              setState(() {});
            },
            icon: didILikeThisComment
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 15,
                  )
                : const Icon(
                    Icons.favorite_border,
                    size: 15,
                  )),
      ),
    );
  }
}
