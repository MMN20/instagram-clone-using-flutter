import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_instagram_clone/main.dart';
import 'package:my_instagram_clone/models/user.dart';
import 'package:my_instagram_clone/screens/signup_screen.dart';
import 'package:my_instagram_clone/variables/global_variables.dart';
import 'package:my_instagram_clone/widgets/intagram_logo.dart';
import 'package:my_instagram_clone/widgets/my_button.dart';
import 'package:my_instagram_clone/widgets/my_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all the text fields',
          ),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    MyUser.currentUser = await MyUser.signInUser(
        _emailController.text, _passwordController.text);
    if (MyUser.currentUser != null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (c) => const MyApp2()), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Some error occurred',
          ),
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
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
                MyButton(
                  onPressed: login,
                  text: 'Log in',
                  isLoading: isLoading,
                ),
                const SizedBox(
                  height: 18,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        " Sign up",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
