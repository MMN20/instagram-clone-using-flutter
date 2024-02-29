import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InstagramLogo extends StatelessWidget {
  InstagramLogo({super.key, this.height = 65});
  double height;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/ic_instagram.svg',
      color: Colors.white,
      height: height,
    );
  }
}
