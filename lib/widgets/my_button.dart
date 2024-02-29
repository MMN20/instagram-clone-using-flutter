import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.isLoading});
  final String text;
  final void Function() onPressed;
  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Colors.blue,
      minWidth: double.infinity,
      padding: const EdgeInsets.all(12),
      child: isLoading
          ? const CircularProgressIndicator(
              color: Colors.black,
            )
          : Text(text),
    );
  }
}
