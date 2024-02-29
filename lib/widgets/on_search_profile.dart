import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram_clone/models/user.dart';

class OnSearchProfile extends StatelessWidget {
  const OnSearchProfile({super.key, required this.user});
  final MyUser user;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profilePicUrl),
        backgroundColor: Colors.grey,
      ),
      title: Text(user.username),
    );
  }
}
