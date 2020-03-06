import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/account.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/error.dart';

class SignUpPage extends StatefulWidget {
  static const tag = 'sign_up';

  SignUpPage() : super();

  @override
  _SignUpState createState() => new _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final FocusNode _focus = new FocusNode();

  // Loading indicator
  bool _loading = false;

  // Is sign up operation completed
  bool _completed = false;

  // Account service
  AccountService _as;

  // Error message
  ErrorMessage _error;

  // E-mail address
  String _email;

  // Username
  String _username;

  // Account password
  String _password;

  // User's name and surname
  String _name;

  @override
  void initState() {
    super.initState();

    // Initialize account service
    _as = new AccountService();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final pv = width > 400 ? 100.0 : 60.0;
    final ph = height > 800 ? 64.0 : 32.0;

    final pt = const Padding(
      padding: EdgeInsets.only(top: 8.0),
    );

    final ptl = new Padding(
      padding: EdgeInsets.only(top: ph),
    );

    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
    );

    Widget w;
    if (_loading) {
      // Use loading animation
      w = new Center(
        child: new Image.asset(
          'assets/images/loading.gif',
          width: 60.0,
          height: 60.0,
        ),
      );
    } else if (_completed) {
    } else if (_error != null) {
      final icon = new Icon(
        new IconData(
          _error.icon,
          fontFamily: FontConst.fa,
        ),
        color: const Color(0xffaaaaaa),
        size: 32.0,
      );

      final message = new Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: new Text(_error.error, style: ts),
      );

      // Add re-try button
      final button = new Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: new CupertinoButton(
          onPressed: () {
            // Reload sign up screen
            Navigator.of(context).pushReplacementNamed(SignUpPage.tag);
          },
          child: new Text(
            'Try again',
            style: new TextStyle(
              color: const Color(0xffffffff),
              fontFamily: FontConst.primary,
              fontSize: 14.0,
              letterSpacing: 0.33,
            ),
          ),
          color: const Color(0xffaaaaaa),
        ),
      );

      // Handle error
      w = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon,
          message,
          button,
        ],
      );
    } else {
      // Create e-mail address input
      final email = new TextInput(
        hint: 'Username or e-mail address',
        onChange: (i) => _email = i,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: const Color(0xffcccccc),
        ),
      );

      // Create password input
      final password = new TextInput(
        hint: 'Password',
        obscure: true,
        onChange: (i) => _password = i,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: const Color(0xffcccccc),
        ),
      );

      // Create username input
      final username = new TextInput(
        hint: 'Username',
        onChange: (i) => _username = i,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: const Color(0xffcccccc),
        ),
      );

      // Create user name input
      final name = new TextInput(
        hint: 'Name',
        onChange: (i) => _name = i,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: const Color(0xffcccccc),
        ),
      );

      // Create sign-up submit button
      final sub = new SizedBox(
        width: double.infinity,
        child: new CupertinoButton(
          onPressed: _signUp,
          color: ColorConst.buttonColor,
          borderRadius: BorderRadius.circular(8.0),
          pressedOpacity: 0.9,
          padding: EdgeInsets.zero,
          child: new Text(
            'Sign Up',
            style: new TextStyle(
              color: const Color(0xffffffff),
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.28,
            ),
          ),
        ),
      );

      // Already have an account text
      final sit = new Text(
        'You already have an account?',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 12.0,
          letterSpacing: 0.33,
          color: ColorConst.grayColor,
        ),
      );

      // Create sign-in page button
      final sib = new CupertinoButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed(SignInPage.tag),
        color: ColorConst.transparent,
        pressedOpacity: 1,
        padding: EdgeInsets.all(8.0),
        minSize: 4.0,
        child: new Text(
          'Sign In',
          style: new TextStyle(
            color: ColorConst.grayColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.28,
          ),
        ),
      );

      // Create main container
      w = new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          email,
          pt,
          password,
          pt,
          username,
          pt,
          name,
          pt,
          sub,
          ptl,
          sit,
          sib,
        ],
      );
    }

    return new CupertinoPageScaffold(
      backgroundColor: const Color(0xffffffff),
      child: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: new Padding(
          padding: EdgeInsets.symmetric(horizontal: pv),
          child: w,
        ),
      ),
    );
  }

  void _signUp() {}
}
