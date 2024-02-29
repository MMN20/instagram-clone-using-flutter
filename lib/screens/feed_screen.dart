import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram_clone/models/post.dart';
import 'package:my_instagram_clone/screens/favorite_screen.dart';
import 'package:my_instagram_clone/screens/messages_screen.dart';
import 'package:my_instagram_clone/widgets/intagram_logo.dart';
import 'package:my_instagram_clone/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  PageController pageController = PageController();
  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: [
        Scaffold(
          appBar: AppBar(
            title: InstagramLogo(height: 40),
            actions: [
              IconButton(
                  onPressed: () {
                    pageController.animateToPage(1,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.linear);
                  },
                  icon: const Icon(Icons.messenger_outline_rounded))
            ],
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  print(
                      'index $index =================================================== my pic ======================================== ${snapshot.data!.docs[index]['imageUrl']} ');

                  return PostCard(
                    post: Post(
                      uid: snapshot.data!.docs[index]['uid'],
                      profilePicUrl: snapshot.data!.docs[index]
                          ['profilePicUrl'],
                      username: snapshot.data!.docs[index]['username'],
                      pubDate: snapshot.data!.docs[index]['pubDate'].toString(),
                      description: snapshot.data!.docs[index]['description'],
                      comments: snapshot.data!.docs[index]['comments'],
                      imageUrl: snapshot.data!.docs[index]['imageUrl'],
                      likes: snapshot.data!.docs[index]['likes'],
                      postId: snapshot.data!.docs[index]['postId'],
                    ),
                  );
                },
              );
            },
          ),
        ),
        MessagesScreen(
          pageController: pageController,
        )
      ],
    );
  }
}
