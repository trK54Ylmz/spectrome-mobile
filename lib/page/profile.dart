import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/theme/color.dart';

class ProfilePage extends StatefulWidget {
  static final tag = 'profile';

  ProfilePage() : super();

  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
    );
  }
}