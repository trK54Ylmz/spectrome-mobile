import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/error.dart';

class InvitePage extends StatefulWidget {
  static const tag = 'invite';

  InvitePage() : super();

  @override
  _InviteState createState() => new _InviteState();
}

class _InviteState extends State<InvitePage> {
  // Form validation key
  final _formKey = GlobalKey<FormValidationState>();

  // Loading indicator
  bool _loading = false;

  // Error message
  ErrorMessage _error;

  // API response, validation error messages
  String _message;

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
            child: getForm(),
          ),
        ),
      ),
    );
  }

  /// Get invitation form
  Widget getForm() {
    final height = MediaQuery.of(context).size.height;
    final ph = height > 800 ? 64.0 : 32.0;

    final pt = const Padding(
      padding: EdgeInsets.only(top: 8.0),
    );

    final ptl = new Padding(
      padding: EdgeInsets.only(top: ph),
    );

    final logo = new Image.asset(
      'assets/images/logo@2x.png',
      width: 128.0,
    );

    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
    );

    final hs = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
      color: ColorConst.grayColor,
    );

    Widget s;
    if (_loading) {
      s = new Image.asset(
        'assets/images/loading.gif',
        width: 40.0,
        height: 40.0,
      );
    } else if (_message != null) {
      s = new Padding(
        padding: EdgeInsets.only(
          top: 20.0,
          bottom: 6.0,
        ),
        child: new Text(
          _message,
          style: new TextStyle(
            fontFamily: FontConst.primary,
            fontSize: 12.0,
            color: ColorConst.darkRed,
          ),
        ),
      );
    } else {
      s = new SizedBox(
        height: 40.0,
      );
    }

    // Create main container
    return new FormValidation(
      key: _formKey,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          pt,
          logo,
          s,
          pt,
        ],
      ),
    );
  }
}
