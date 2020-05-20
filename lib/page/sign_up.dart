import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/form.dart';
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

  // Form validation key
  final _formKey = GlobalKey<FormValidationState>();

  // Screen focus node
  final _focus = new FocusNode();

  // Loading indicator
  bool _loading = false;

  // Is sign up operation completed
  bool _completed = false;

  // Account service
  AccountService _as;

  // Error message
  ErrorMessage _error;

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
      final ts = new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        letterSpacing: 0.33,
        color: ColorConst.grayColor,
      );

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
        child: new Button(
          text: 'Try again',
          color: ColorConst.grayColor,
          onPressed: () {
            // Reload sign up screen
            Navigator.of(context).pushReplacementNamed(SignUpPage.tag);
          },
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

      // Create phone number input
      final phone = new TextInput(
        hint: 'Phone number',
        inputType: TextInputType.phone,
        controller: _phone,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
          color: const Color(0xffcccccc),
        ),
      );

      // Create e-mail address input
      final email = new TextInput(
        hint: 'E-mail address',
        inputType: TextInputType.emailAddress,
        controller: _email,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
          color: const Color(0xffcccccc),
        ),
      );

      // Create password input
      final password = new TextInput(
        hint: 'Password',
        obscure: true,
        controller: _password,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
          color: const Color(0xffcccccc),
        ),
      );

      // Create username input
      final username = new TextInput(
        hint: 'Username',
        controller: _username,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
          color: const Color(0xffcccccc),
        ),
        validator: (i) {
          if (i.length < 6) {
            return 'The username cannot be lower than 6 character';
          }

          return null;
        },
      );

      // Create user name input
      final name = new TextInput(
        hint: 'Name',
        controller: _name,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0,
          color: const Color(0xffcccccc),
        ),
      );

      // Create sign-up submit button
      final sub = new Button(
        onPressed: _signUp,
        color: ColorConst.buttonColor,
        text: 'Sign Up',
      );

      // Already have an account text
      final sit = new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            'already have an account? ',
            style: new TextStyle(
              fontFamily: FontConst.primary,
              fontSize: 12.0,
              letterSpacing: 0.33,
              color: ColorConst.grayColor,
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
                  color: ColorConst.grayColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      );

      // Create sign-in page button
      final sib = new Button(
        color: ColorConst.transparent,
        text: 'Sign In',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(SignInPage.tag);
        },
      );

      // Create main container
      w = new FormValidation(
        key: _formKey,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            pt,
            logo,
            _loading ? loading : empty,
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
            sib,
          ],
        ),
      );
    }

    return new Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: new GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_focus),
        child: new Center(
          child: new Padding(
            padding: EdgeInsets.symmetric(horizontal: pv),
            child: w,
          ),
        ),
      ),
    );
  }

  /// Make sign up
  ///
  /// Account service must be initialized
  void _signUp() {
    dev.log('Sign up button clicked.');

    // Say application to sign up in process
    setState(() => _completed = false);

    if (_loading) {
      return;
    }

    // Validate form key
    if (!_formKey.currentState.validate()) {
      // Create custom error
      setState(() => _error = ErrorMessage.custom(_formKey.currentState.errors.first));

      return;
    }

    dev.log('Sign up request sending.');

    // Set loading true
    setState(() => _loading = true);

    // Handle HTTP response
    final sc = (SignUpResponse r) {
      dev.log('Sign up request sent.');

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

      // Set loading false
      setState(() => _loading = false);

      // Say application to sign up completed
      setState(() => _completed = true);
    };

    // Send sign up request
    _as.signUp(_email.text, _password.text, _name.text, _username.text).then(sc);
  }
}
