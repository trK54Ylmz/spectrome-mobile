import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/input.dart';

import 'package:spectrome/item/button.dart';

import 'package:spectrome/page/sign_up.dart';
import 'package:spectrome/service/account.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/util/error.dart';

class SignInPage extends StatefulWidget {
  static final tag = 'sign_in';

  SignInPage() : super();

  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignInPage> {
  // Loading indicator
  bool _loading = true;

  SharedPreferences _preferences;

  // Account service
  AccountService _as;

  // Error message
  ErrorMessage _error;

  // Login id means username or e-mail address
  String _loginId;

  // Account password
  String _password;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      _preferences = s;

      setState(() => _loading = false);
    };

    SharedPreferences.getInstance().then(spc);

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
    if (_preferences == null) {
      if (_loading) {
        // Use loading animation
        w = new Center(
          child: new Image.asset(
            'assets/images/loading.gif',
            width: 60.0,
            height: 60.0,
          ),
        );
      } else if (_error != null) {
        final icon = new Icon(
          new IconData(
            _error.icon,
            fontFamily: FontConst.fa,
          ),
          color: ColorConst.grayColor,
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
            color: ColorConst.grayColor,
            onPressed: () {
              // Reload sign in screen
              Navigator.of(context).pushReplacementNamed(SignInPage.tag);
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
      }
    } else {
      final logo = new Image.asset(
        'assets/images/logo@2x.png',
        width: 128.0,
      );

      final loading = new Image.asset(
        'assets/images/loading.gif',
        width: 40.0,
        height: 40.0,
      );

      final empty = new SizedBox(
        height: 40.0,
      );

      // Create e-mail address input
      final email = new TextInput(
        hint: 'Username or e-mail address',
        onChange: (i) => _loginId = i,
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

      // Create sign-in submit button
      final sib = new Button(
        text: 'Sign In',
        onPressed: _signIn,
      );

      // Forgot password page button
      final fpt = new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            'forgot password? ',
            style: new TextStyle(
              fontFamily: FontConst.primary,
              fontSize: 12.0,
              letterSpacing: 0.33,
              color: ColorConst.grayColor,
            ),
          ),
          new GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(SignUpPage.tag);
            },
            child: new Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: new Text(
                'reset',
                style: new TextStyle(
                  fontFamily: FontConst.primary,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.33,
                  color: ColorConst.grayColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      );

      // Create sign-up page button
      final sub = new Button(
        text: 'Sign Up',
        color: ColorConst.grayColor,
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(SignUpPage.tag);
        },
      );

      // Create main container
      w = new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          pt,
          logo,
          _loading ? loading : empty,
          email,
          pt,
          password,
          pt,
          sib,
          pt,
          fpt,
          ptl,
          sub,
          pt,
        ],
      );
    }

    return new Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: new Center(
        child: new Padding(
          padding: EdgeInsets.symmetric(horizontal: pv),
          child: w,
        ),
      ),
    );
  }

  /// Make sign in
  ///
  /// Account service must be initialized
  void _signIn() {
    dev.log('Sign in button clicked.');

    if (_loading) {
      return;
    }

    dev.log('Sign in request sending.');

    // Set loading true
    setState(() => _loading = true);

    // Handle HTTP response
    final sc = (SignInResponse r) {
      dev.log('Sign in request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          setState(() => _error = ErrorMessage.network());
        } else {
          // Create custom error
          setState(() => _error = ErrorMessage.custom(r.message));
        }

        // Set loading false
        setState(() => _loading = false);

        return;
      }

      // Create new auth key
      _preferences.setString('_session', r.session);

      // Set loading false
      setState(() => _loading = false);
    };

    // Send sign in request
    _as.signIn(_loginId, _password).then(sc);
  }
}
