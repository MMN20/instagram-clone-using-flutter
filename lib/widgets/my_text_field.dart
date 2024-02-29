import 'package:flutter/material.dart';

// for login and signup
class MyTextField extends StatelessWidget {
  const MyTextField(
      {super.key, required this.hintText, required this.controller});
  final String hintText;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white24,
        hintStyle: const TextStyle(),
        contentPadding: const EdgeInsets.all(12),
        border: const OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}
