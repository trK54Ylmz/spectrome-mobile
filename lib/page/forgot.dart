import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/account/forgot.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';

class ForgotPage extends StatefulWidget {
  static final tag = 'forgot';

  ForgotPage() : super();

  @override
  _ForgotState createState() => new _ForgotState();
}

class _ForgotState extends State<ForgotPage> {
  // Form validation key
  final _formKey = GlobalKey<FormValidationState>();

  // Username input controller
  final _username = new TextEditingController();

  // Phone number input controller
  final _phone = new TextEditingController();

  // Loading indicator
  bool _loading = false;

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
      // Remove if legacy forgot token still exists
      s.remove('_fpt');

      _sp = s;

      setState(() => _loading = false);
    };

    SharedPreferences.getInstance().then(spc);
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

  /// Get forgot password form
  Widget _getForm() {
    final height = MediaQuery.of(context).size.height;
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

    final hs = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
      color: ColorConst.grayColor,
    );

    final logo = new Image.asset(
      'assets/images/logo@2x.png',
      width: 128.0,
    );

    final t = new Text(
      'Please enter username and phone number to reset password.',
      textAlign: TextAlign.center,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        letterSpacing: 0.33,
        color: ColorConst.grayColor,
      ),
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

    // Create username input
    final username = new FormText(
      hint: 'Username',
      controller: _username,
      style: ts,
      hintStyle: hs,
      validator: (i) {
        if (i.length == 0) {
          return 'The username is required.';
        }

        if (i.runes.length < 2) {
          return 'The username cannot be lower than 2 character.';
        }

        if (i.runes.length > 24) {
          return 'The username cannot be higher than 24 character.';
        }

        return null;
      },
    );

    // Create phone number input
    final phone = new FormText(
      hint: 'Phone number',
      inputType: TextInputType.phone,
      controller: _phone,
      style: ts,
      hintStyle: hs,
      validator: (i) {
        if (i.length == 0) {
          return 'The phone number is required.';
        }

        // Example format is +905431234567
        if (i.runes.length < 9 || i.runes.length > 16) {
          return 'Invalid phone number.';
        }

        // Check according E.164 format
        final r = new RegExp(r'\+[1-9]\d{7,14}$');
        if (r.allMatches(i).isEmpty) {
          return 'Invalid phone number.';
        }

        return null;
      },
    );

    // Reset password submit button
    final fpb = new Button(
      text: 'Reset password',
      disabled: _loading,
      onPressed: _forgot,
    );

    // Sign in page button
    final sib = new Button(
      text: 'Sign In',
      disabled: _loading,
      color: ColorConst.grayColor,
      onPressed: () => Navigator.of(context).pushReplacementNamed(SignInPage.tag),
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
          ptl,
          t,
          pt,
          s,
          username,
          pt,
          phone,
          pt,
          fpb,
          pt,
          ptl,
          sib,
          pt,
        ],
      ),
    );
  }

  /// Send e-mail to reset password
  void _forgot() {
    dev.log('Reset password button clicked.');

    // Clear message
    _message = null;

    if (_loading) {
      return;
    }

    setState(() => _loading = true);

    dev.log('Resend request sending.');

    final sc = (ForgotResponse r) {
      dev.log('Forgot password request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          setState(() => _error = ErrorMessage.network());
        } else {
          // Create custom error
          setState(() => _message = r.message);
        }

        return;
      }

      _sp.setString('_fpt', r.token);

      // Clear API response message
      setState(() => _message = null);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    final cc = () {
      setState(() => _loading = false);
    };

    final u = _username.text;
    final p = _phone.text;

    // Send activation code again by using request
    ForgotService.call(u, p).then(sc).catchError(e).whenComplete(cc);
  }
}
