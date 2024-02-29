import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram_clone/models/post.dart';
import 'package:my_instagram_clone/widgets/post_card.dart';

class PostsProvider extends ChangeNotifier {
  List<Post> posts = [];

  void setPosts() {
    FirebaseFirestore.instance.collection('posts').snapshots().listen((event) {
      posts = [];
      for (var doc in event.docs) {
        // posts.add(
        //   Post(
        //     description: doc['description'],
        //     uid: doc['uid'],
        //     pubDate: doc['pubDate'].toString(),
        //     comments: doc['comments'],
        //     imageUrl: doc['imageUrl'],
        //     likes: doc['likes'],
        //     postId: doc['postId'],
        //   ),
        // );
      }
    });
    notifyListeners();
  }

  PostsProvider() {
    setPosts();
  }
}
