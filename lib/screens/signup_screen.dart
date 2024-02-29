import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_instagram_clone/main.dart';
import 'package:my_instagram_clone/models/user.dart';
import 'package:my_instagram_clone/widgets/intagram_logo.dart';
import 'package:my_instagram_clone/widgets/my_button.dart';
import 'package:my_instagram_clone/widgets/my_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? file;
  bool isLoading = false;

  void pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      file = await image.readAsBytes();
      setState(() {});
    }
  }

  void signUp() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _bioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter all the fields')));
    } else {
      setState(() {
        isLoading = true;
      });

      MyUser.currentUser = await MyUser.signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        file: file,
        bio: _bioController.text,
      );
      if (MyUser.currentUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User signed up successfully!')));
        setState(() {
          isLoading = false;
        });
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (c) => MyApp2()), (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User signning up failed!')));
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InstagramLogo(),
                const SizedBox(
                  height: 18,
                ),
                Stack(
                  children: [
                    file != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(file!),
                            radius: 50,
                          )
                        : const CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                            radius: 50,
                          ),
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: IconButton(
                          onPressed: pickImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          )),
                    )
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                MyTextField(
                  controller: _usernameController,
                  hintText: 'Enter your username',
                ),
                const SizedBox(
                  height: 18,
                ),
                MyTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                ),
                const SizedBox(
                  height: 18,
                ),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Enter your password',
                ),
                const SizedBox(
                  height: 18,
                ),
                MyTextField(
                  controller: _bioController,
                  hintText: 'Enter your bio',
                ),
                const SizedBox(
                  height: 18,
                ),
                MyButton(
                    onPressed: signUp, text: 'Sign up', isLoading: isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
