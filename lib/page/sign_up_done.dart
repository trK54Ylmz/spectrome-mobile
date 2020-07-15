import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

class SignUpDonePage extends StatefulWidget {
  static const tag = 'sign_up_done';

  SignUpDonePage() : super();

  @override
  _SignUpDoneState createState() => new _SignUpDoneState();
}

class _SignUpDoneState extends State<SignUpDonePage> {
  // Loading indicator
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final c = (SharedPreferences sp) {
      sp.setBool('_ac', true);

      setState(() => _loading = false);
    };

    // Get shared preferences
    SharedPreferences.getInstance().then(c);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new SingleChildScrollView(
        child: Container(
          width: width,
          height: height,
          child: _getPage(),
        ),
      ),
    );
  }

  // Get page widget
  Widget _getPage() {
    if (_loading) {
      return new Center(
        child: new Image.asset(
          'assets/images/loading.gif',
          width: 40.0,
          height: 40.0,
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final pv = width > 400 ? 100.0 : 60.0;
    final ph = height > 800 ? 64.0 : 32.0;

    final ptl = new Padding(
      padding: EdgeInsets.only(top: ph),
    );

    final logo = new Image.asset(
      'assets/images/logo@2x.png',
      width: 128.0,
    );

    final si = new Icon(
      new IconData(0xf00c, fontFamily: FontConst.fa),
      color: ColorConst.successColor,
      size: 48.0,
    );

    final msg = new Text(
      'Account created and ready to go!',
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        letterSpacing: 0.33,
        color: ColorConst.darkGrayColor,
      ),
    );

    // Sign in button
    final sib = new Button(
      color: ColorConst.buttonColor,
      text: 'Sign In',
      onPressed: () => Navigator.of(context).pushReplacementNamed(SignInPage.tag),
    );

    return new Padding(
      padding: EdgeInsets.symmetric(
        vertical: ph,
        horizontal: pv,
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          logo,
          ptl,
          si,
          ptl,
          msg,
          ptl,
          sib,
        ],
      ),
    );
  }
}
