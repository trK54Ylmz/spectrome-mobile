import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/page/activation.dart';
import 'package:spectrome/page/forgot.dart';
import 'package:spectrome/page/invite.dart';
import 'package:spectrome/page/sign_up.dart';
import 'package:spectrome/page/view.dart';
import 'package:spectrome/service/account/sign_in.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';

class SignInPage extends StatefulWidget {
  static final tag = 'sign_in';

  SignInPage() : super();

  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignInPage> {
  // Form validation key
  final _formKey = GlobalKey<FormValidationState>();

  // Username or e-mail input controller
  final _loginId = new TextEditingController();

  // Password input controller
  final _password = new TextEditingController();

  // Loading indicator
  bool _loading = true;

  // Shared preferences instance
  SharedPreferences _sp;

  // Error message
  ErrorMessage _error;

  // API response, validation error messages
  String _message;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      // Remove if legacy session code still exists
      s.remove('_st');

      _sp = s;

      setState(() => _loading = false);
    };

    Storage.load().then(spc);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final pv = width > 400 ? 100.0 : 60.0;

    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new SingleChildScrollView(
        child: new Container(
          width: width,
          height: height,
          child: new Padding(
            padding: EdgeInsets.symmetric(horizontal: pv),
            child: AppConst.loader(context, _sp == null, _error, _getForm),
          ),
        ),
      ),
    );
  }

  /// Get sign in form
  Widget _getForm() {
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
      color: ColorConst.gray,
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

    // Create e-mail address input
    final email = new FormText(
      hint: 'Username or e-mail address',
      controller: _loginId,
      style: ts,
      hintStyle: hs,
      validator: (i) {
        if (i.length == 0) {
          return 'The username or e-mail address is required.';
        }

        if (i.runes.length < 2) {
          return 'The username or e-mail address is too short.';
        }

        return null;
      },
    );

    // Create password input
    final password = new FormText(
      hint: 'Password',
      controller: _password,
      obscure: true,
      showObscure: true,
      style: ts,
      hintStyle: hs,
      validator: (i) {
        if (i.length == 0) {
          return 'The password is required.';
        }

        if (i.runes.length < 8) {
          return 'The password cannot be lower than 8 character.';
        }

        if (i.runes.length > 50) {
          return 'The password cannot be higher than 50 character.';
        }

        return null;
      },
    );

    // Create sign-in submit button
    final sib = new Button(
      text: 'Sign In',
      disabled: _loading,
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
            color: ColorConst.gray,
          ),
        ),
        new GestureDetector(
          onTap: () => Navigator.of(context).pushReplacementNamed(ForgotPage.tag),
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
                color: ColorConst.gray,
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
      disabled: _loading,
      background: ColorConst.gray,
      onPressed: () => Navigator.of(context).pushReplacementNamed(SignUpPage.tag),
    );

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

    // Validate form key
    if (!_formKey.currentState.validate()) {
      // Create custom error
      setState(() => _message = _formKey.currentState.errors.first);

      return;
    }

    dev.log('Sign in request sending.');

    // Set loading true
    setState(() => _loading = true);

    // Handle HTTP response
    final sc = (SignInResponse r) async {
      dev.log('Sign in request sent.');

      if (!r.status) {
        // Route to activation page, if activation is wating
        if (r.activation == false) {
          // Set session token
          _sp.setString('_st', r.token);

          await Navigator.of(context).pushReplacementNamed(ActivationPage.tag);
          return;
        }

        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          _message = r.message;
        }

        return;
      }

      // Clear API response message
      _message = null;

      // Create new auth key
      _sp.setString('_session', r.session);

      // Show invitation control
      final ac = _sp.getBool('_ac');

      final tag = ac == true ? InvitePage.tag : ViewPage.tag;

      await Navigator.of(context).pushReplacementNamed(tag);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    // Complete callback
    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _loading = false);
    };

    final l = _loginId.text;
    final p = _password.text;

    // Send sign in request
    SignInService.call(l, p).then(sc).catchError(e).whenComplete(cc);
  }
}
