import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram_clone/models/user.dart';
import 'package:my_instagram_clone/screens/chat_screen.dart';
import 'package:my_instagram_clone/widgets/on_search_profile.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, required this.pageController});
  final PageController pageController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MyUser.currentUser!.username,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            pageController.animateToPage(0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.linear);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: FutureBuilder(
        future: MyUser.currentUser!.getAllMyFollowing(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => ChatScreen(
                                  otherUser: snapshot.data![index],
                                )));
                  },
                  child: OnSearchProfile(
                    user: snapshot.data![index],
                  ),
                );
              });
        },
      ),
    );
  }
}
