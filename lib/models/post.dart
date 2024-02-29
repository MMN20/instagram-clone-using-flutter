// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'package:my_instagram_clone/models/firebase_storage_methods.dart';
import 'package:my_instagram_clone/models/user.dart';

class Post {
  String postId;
  String uid;
  String profilePicUrl;
  String username;
  String imageUrl;
  List likes;
  int comments;
  String pubDate;
  String description;

  Post({
    this.postId = '',
    required this.uid,
    required this.profilePicUrl,
    required this.username,
    this.imageUrl = '',
    this.likes = const [],
    this.comments = 0,
    required this.pubDate,
    required this.description,
  });

  static Future<void> deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }

  static Stream<List<Post>> getAllPosts() {
    List<Post> posts = [];

    StreamController<List<Post>> streamController =
        StreamController<List<Post>>();

    FirebaseFirestore.instance.collection('posts').snapshots().listen((event) {
      posts = [];
      for (var doc in event.docs) {
        // for getting the comments
        posts.add(
          Post(
            uid: doc['uid'],
            profilePicUrl: doc['profilePicUrl'],
            username: doc['username'],
            pubDate: doc['pubDate'].toString(),
            description: doc['description'],
            comments: doc['comments'],
            imageUrl: doc['imageUrl'],
            likes: doc['likes'].length,
            postId: doc['postId'],
          ),
        );
        streamController.add(posts);
      }
    });

    return streamController.stream;
  }

  Future<bool> isCurrentUserLikesThisPost() async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    return doc['likes'].contains(MyUser.currentUser!.uid);
  }

  Future<bool> likeUnlike() async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    if (doc['likes'].contains(MyUser.currentUser!.uid)) {
      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([MyUser.currentUser!.uid])
      });
      return false;
    } else {
      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([MyUser.currentUser!.uid])
      });
      return true;
    }
  }

  static Future<List<Post>> getAllPostsOfUser(MyUser user) async {
    List<Post> posts = [];
    QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: user.uid)
        .get();
    for (var doc in snap.docs) {
      posts.add(
        Post(
          uid: doc['uid'],
          profilePicUrl: doc['profilePicUrl'],
          username: doc['username'],
          pubDate: doc['pubDate'],
          description: doc['description'],
          comments: doc['comments'],
          imageUrl: doc['imageUrl'],
          likes: doc['likes'],
          postId: doc['postId'],
        ),
      );
    }
    return posts;
  }

  Future<void> uploadPost(Uint8List file) async {
    String postId = const Uuid().v1();
    String imageUrl = await FirebaseStorageMethods.uploadFile(file, postId);
    await FirebaseFirestore.instance.collection('posts').doc(postId).set({
      'postId': postId,
      'uid': uid,
      'profilePicUrl': profilePicUrl,
      'username': username,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'pubDate': DateTime.now().toString(),
      'description': description,
    });
  }
}

class Comment {
  String uid;
  String commentId;
  String text;
  String profilePicUrl;
  String pubDate;
  int likes;
  String postId;
  Comment({
    required this.uid,
    this.commentId = '',
    required this.text,
    required this.profilePicUrl,
    required this.pubDate,
    required this.likes,
    required this.postId,
  });

  // static Future<List<Comment>> getAllComments(String postId) async {

  //   List<Comment> comments = [];
  //   QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore.instance
  //       .collection('posts')
  //       .doc(postId)
  //       .collection('comments')
  //       .get();

  // for (var doc in snap.docs) {

  // }
  // }

  Future<void> addComment(String postId) async {
    String commentId = Uuid().v1();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .set({
      'uid': uid,
      'commentId': commentId,
      'text': text,
      'likes': [],
      'profilePicUrl': profilePicUrl,
      'pubDate': pubDate,
      'postId': postId
    });
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'comments': FieldValue.increment(1)});
  }

  Future<bool> didILikeThisComment() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .get();
    print(
        '${doc['likes'].contains(uid)} ================== likes result ====================');
    return doc['likes'].contains(uid);
  }

  static Future<void> deleteComment(String postId, String commentId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'comments': FieldValue.increment(-1)});
  }

  Future<bool> likeUnlikeAComment() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .get();
    if (doc['likes'].contains(MyUser.currentUser!.uid)) {
      doc.reference.update({
        'likes': FieldValue.arrayRemove([MyUser.currentUser!.uid])
      });
      return false;
    } else {
      doc.reference.update({
        'likes': FieldValue.arrayUnion([MyUser.currentUser!.uid])
      });
      return true;
    }
  }
}
