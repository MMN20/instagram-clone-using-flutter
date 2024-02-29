import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram_clone/models/user.dart';
import 'package:my_instagram_clone/providers/posts_provider.dart';
import 'package:my_instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:my_instagram_clone/responsive/responsive_layout.dart';
import 'package:my_instagram_clone/responsive/web_screen_layout.dart';
import 'package:my_instagram_clone/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAw-VVIC4vSsaNs_CiLhYjZC1swvrsfxrY",
            authDomain: "my-instagram-clone-99822.firebaseapp.com",
            projectId: "my-instagram-clone-99822",
            storageBucket: "my-instagram-clone-99822.appspot.com",
            messagingSenderId: "201074650580",
            appId: "1:201074650580:web:586e0a2c7abafbb043fa41"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (c) => PostsProvider())],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData.dark().copyWith(
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(backgroundColor: Colors.black)),
          home: const MyApp2()),
    );
  }
}

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  bool isGotCurrentUser = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    MyUser.currentUser = await MyUser.getCurrentUser;
    setState(() {
      isGotCurrentUser = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isGotCurrentUser
        ? MyUser.currentUser == null
            ? const LoginScreen()
            : const ResponsiveLayout(
                mobileScreenLayout: MobileScreenLayout(),
                webScreenLayout: WebScreenLayout(),
              )
        : const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
