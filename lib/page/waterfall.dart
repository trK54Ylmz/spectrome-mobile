import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/service/profile/me.dart';
import 'package:spectrome/theme/color.dart';

class WaterFallPage extends StatefulWidget {
  static final tag = 'waterfall';

  WaterFallPage() : super();

  @override
  _WaterFallState createState() => new _WaterFallState();
}

class _WaterFallState extends State<WaterFallPage> {
  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final c = (SharedPreferences sp) {
      final session = sp.getString('_session');

      // Get my profile
      getMyProfile(session);
    };

    // Get shared preferences
    SharedPreferences.getInstance().then(c);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new SingleChildScrollView(
        child: new Container(
          
        ),
      ),
    );
  }


  /// Get my profile
  void getMyProfile(String session) {
    final c = (MyProfileResponse r) {
      dev.log(r.profile.photoUrl);
    };

    MyProfileService.call(session).then(c);
  }
}
