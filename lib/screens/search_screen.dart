import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram_clone/models/post.dart';
import 'package:my_instagram_clone/models/user.dart';
import 'package:my_instagram_clone/screens/profile_screen.dart';
import 'package:my_instagram_clone/widgets/on_search_profile.dart';
import 'package:my_instagram_clone/widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Widget explore;

  @override
  void initState() {
    super.initState();
    explore = exploreBody();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              onChanged: (s) {
                setState(() {});
              },
              controller: _searchController,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Search for a user'),
            ),
            if (_searchController.text == '')
              explore
            else
              Expanded(
                child: FutureBuilder(
                  future: MyUser.getSearchedUsers(_searchController.text),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => ProfileScreen(
                                  user: snapshot.data![index],
                                ),
                              ),
                            );
                          },
                          child: OnSearchProfile(
                            user: snapshot.data![index],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget exploreBody() {
    return Expanded(
      child: FutureBuilder(
          future: FirebaseFirestore.instance.collection('posts').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: snapshot.data!.size,
              itemBuilder: (context, index) {
                QueryDocumentSnapshot<Map<String, dynamic>> doc =
                    snapshot.data!.docs[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => Scaffold(
                                  body: SafeArea(
                                    child: PostCard(
                                      post: Post(
                                        uid: doc['uid'],
                                        profilePicUrl: doc['profilePicUrl'],
                                        username: doc['username'],
                                        pubDate: doc['pubDate'].toString(),
                                        description: doc['description'],
                                        comments: doc['comments'],
                                        imageUrl: doc['imageUrl'],
                                        likes: doc['likes'],
                                        postId: doc['postId'],
                                      ),
                                    ),
                                  ),
                                )));
                  },
                  child: Image.network(snapshot.data!.docs[index]['imageUrl']),
                );
              },
            );
          }),
    );
  }
}
