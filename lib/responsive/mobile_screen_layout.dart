import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram_clone/main.dart';
import 'package:my_instagram_clone/models/user.dart';
import 'package:my_instagram_clone/screens/favorite_screen.dart';
import 'package:my_instagram_clone/screens/feed_screen.dart';
import 'package:my_instagram_clone/screens/profile_screen.dart';
import 'package:my_instagram_clone/screens/search_screen.dart';
import 'package:my_instagram_clone/screens/upload_screen.dart';
import 'package:my_instagram_clone/variables/global_variables.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  final PageController pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          const FeedScreen(),
          const SearchScreen(),
          const UploadScreen(),
          const FavoriteScreen(),
          ProfileScreen(
            user: MyUser.currentUser!,
          )
        ],
      ),
      bottomNavigationBar: Theme(
        data: ThemeData.dark().copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
            iconSize: 30,
            onTap: (index) {
              pageController.jumpToPage(index);
              _currentPage = index;
              setState(() {});
            },
            backgroundColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontSize: 0),
            unselectedLabelStyle: const TextStyle(fontSize: 0),
            items: [
              BottomNavigationBarItem(
                  label: 'home',
                  icon: Icon(
                    Icons.home,
                    color: _currentPage == 0 ? Colors.white : Colors.grey,
                  )),
              BottomNavigationBarItem(
                  label: 'search',
                  icon: Icon(
                    Icons.search,
                    color: _currentPage == 1 ? Colors.white : Colors.grey,
                  )),
              BottomNavigationBarItem(
                  label: 'search',
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: _currentPage == 2 ? Colors.white : Colors.grey,
                  )),
              BottomNavigationBarItem(
                  label: 'search',
                  icon: Icon(
                    Icons.favorite,
                    color: _currentPage == 3 ? Colors.white : Colors.grey,
                  )),
              BottomNavigationBarItem(
                label: 'search',
                icon: Icon(
                  Icons.person,
                  color: _currentPage == 4 ? Colors.white : Colors.grey,
                ),
              ),
            ]),
      ),
    );
  }
}
