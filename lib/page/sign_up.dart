import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/page/activation.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/account/sign_up.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';

class SignUpPage extends StatefulWidget {
  static const tag = 'sign_up';

  SignUpPage() : super();

  @override
  _SignUpState createState() => new _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  // Form validation key
  final _fk = new GlobalKey<FormValidationState>();

  // Phone number input controller
  final _phone = new TextEditingController();

  // Username input controller
  final _username = new TextEditingController();

  // E-mail input controller
  final _email = new TextEditingController();

  // Password input controller
  final _password = new TextEditingController();

  // User real name input controller
  final _name = new TextEditingController();

  // Screen focus node
  final _focus = new FocusNode();

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
        child: new GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_focus),
          child: new Container(
            width: width,
            height: height,
            child: new Padding(
              padding: EdgeInsets.symmetric(horizontal: pv),
              child: AppConst.loader(
                page: SignUpPage.tag,
                argument: _sp == null,
                error: _error,
                callback: _getForm,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get sign up form
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
      color: ColorConst.gray,
    );

    final logo = new Image.asset(
      'assets/images/logo@2x.png',
      width: 128.0,
    );

    Widget s;
    if (_loading) {
      s = new Loading(iconWidth: 40.0, iconHeight: 40.0);
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

    // Create e-mail address input
    final email = new FormText(
      hint: 'E-mail address',
      inputType: TextInputType.emailAddress,
      controller: _email,
      style: ts,
      hintStyle: hs,
      validator: (i) {
        if (i.length == 0) {
          return 'The e-mail address is required.';
        }

        if (!EmailValidator.validate(i)) {
          return 'The e-mail address is invalid.';
        }

        return null;
      },
    );

    // Create password input
    final password = new FormText(
      hint: 'Password',
      obscure: true,
      showObscure: true,
      controller: _password,
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

    // Create user name input
    final name = new FormText(
      hint: 'Name',
      controller: _name,
      style: ts,
      hintStyle: hs,
      validator: (i) {
        if (i.length == 0) {
          return 'The name is required.';
        }

        if (i.runes.length < 4) {
          return 'The name cannot be lower than 4 character.';
        }

        if (i.runes.length > 50) {
          return 'The name cannot be higher than 50 character.';
        }

        return null;
      },
    );

    // Create sign-up submit button
    final sub = new Button(
      text: 'Sign Up',
      disabled: _loading,
      onPressed: _signUp,
    );

    // Already have an account text
    final sit = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          'already have an account? ',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            fontSize: 12.0,
            letterSpacing: 0.33,
            color: ColorConst.gray,
          ),
        ),
        new GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed(SignInPage.tag);
          },
          child: new Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 4.0,
            ),
            child: new Text(
              'sign in',
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

    // Create main container
    return new FormValidation(
      key: _fk,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          pt,
          logo,
          s,
          pt,
          phone,
          pt,
          username,
          pt,
          name,
          pt,
          email,
          pt,
          password,
          pt,
          sub,
          ptl,
          sit,
          pt,
        ],
      ),
    );
  }

  /// Make sign up
  ///
  /// Account service must be initialized
  void _signUp() {
    dev.log('Sign up button clicked.');

    // Clear message
    setState(() => _message = null);

    if (_loading) {
      return;
    }

    // Validate form key
    if (!_fk.currentState.validate()) {
      // Create custom error
      setState(() => _message = _fk.currentState.errors.first);

      return;
    }

    dev.log('Sign up request sending.');

    // Set loading true
    setState(() => _loading = true);

    // Handle HTTP response
    final sc = (SignUpResponse r) async {
      dev.log('Sign up request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          _message = r.message;
        }

        return;
      }

      // Set session token
      _sp.setString('_st', r.token);

      // Move to activation page
      await Navigator.of(context).pushReplacementNamed(ActivationPage.tag);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown sign up error. Please try again later.';

      dev.log(msg, stackTrace: s);

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

    final t = _phone.text;
    final m = _email.text;
    final p = _password.text;
    final u = _username.text;
    final n = _name.text;

    // Send sign up request
    SignUpService.call(t, m, p, u, n).then(sc).catchError(e).whenComplete(cc);
  }
}
