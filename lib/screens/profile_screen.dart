import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram_clone/main.dart';
import 'package:my_instagram_clone/models/post.dart';
import 'package:my_instagram_clone/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final MyUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool isMe;
  bool doIFollow = false;
  @override
  void initState() {
    super.initState();
    isMe = (widget.user.uid == MyUser.currentUser!.uid);
    setVariables();
  }

  Future<void> setVariables() async {
    doIFollow = await MyUser.currentUser!.doIFollow(widget.user.uid);
    setState(() {});
  }

  //!  Complete the rest of this screen ................................................
  //! which is the username and bio and divider and posts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.username,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.profilePicUrl),
                    backgroundColor: Colors.grey,
                    radius: 40,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        // posts follower following
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            item(
                              name: 'posts',
                              number: widget.user.posts.toString(),
                            ),
                            item(
                              name: 'followers',
                              number: widget.user.followers.toString(),
                            ),
                            item(
                              name: 'following',
                              number: widget.user.following.toString(),
                            ),
                          ],
                        ),
                        isMe
                            ? MaterialButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (c) => const MyApp2()),
                                      (route) => false);
                                },
                                color: Colors.black,
                                minWidth: 270,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2),
                                    side: const BorderSide(
                                      color: Colors.white,
                                    )),
                                child: const Text('sign out'),
                              )
                            : doIFollow
                                ? MaterialButton(
                                    onPressed: () async {
                                      await MyUser.currentUser!.followUnfollow(
                                          widget.user.uid, doIFollow);
                                      await setVariables();
                                      widget.user.followers--;
                                      setState(() {});
                                    },
                                    color: Colors.black,
                                    minWidth: 270,
                                    height: 30,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2),
                                        side: const BorderSide(
                                          color: Colors.white,
                                        )),
                                    child: const Text('Unfollow'),
                                  )
                                : MaterialButton(
                                    onPressed: () async {
                                      await MyUser.currentUser!.followUnfollow(
                                          widget.user.uid, doIFollow);
                                      await setVariables();
                                      widget.user.followers++;
                                      setState(() {});
                                    },
                                    color: Colors.blue,
                                    minWidth: 270,
                                    height: 30,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                      side: BorderSide.none,
                                    ),
                                    child: const Text('Follow'),
                                  )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.user.bio,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const Divider(),
            FutureBuilder(
                future: Post.getAllPostsOfUser(widget.user),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 4,
                            mainAxisExtent: 150),
                    itemBuilder: (context, index) {
                      return Image.network(
                        snapshot.data![index].imageUrl,
                        height: 200,
                        width: 120,
                      );
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget item({required String number, required String name}) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          name,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }
}
