import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/theme/color.dart';

class SignUpDonePage extends StatefulWidget {
  static const tag = 'sign_up_done';

  SignUpDonePage() : super();

  @override
  _SignUpDoneState createState() => new _SignUpDoneState();
}

class _SignUpDoneState extends State<SignUpDonePage> {
  // Loading indicator
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final c = (SharedPreferences sp) {
      sp.setBool('_ac', true);
    };

    // Get shared preferences
    SharedPreferences.getInstance().then(c);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final pv = width > 400 ? 100.0 : 60.0;

    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new SingleChildScrollView(
        child: Container(
          height: height,
          child: new Padding(
            padding: EdgeInsets.symmetric(horizontal: pv),
          ),
        ),
      ),
    );
  }
}
