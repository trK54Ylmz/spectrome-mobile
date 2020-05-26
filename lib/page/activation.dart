import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/service/account.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/storage.dart';
import 'package:spectrome/util/error.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivationPage extends StatefulWidget {
  static final tag = 'activation';

  ActivationPage() : super();

  @override
  _ActivationState createState() => new _ActivationState();
}

class _ActivationState extends State<ActivationPage> {
  // Form validation key
  final _formKey = GlobalKey<FormValidationState>();

  // Username or e-mail input controller
  final _inputs = <TextEditingController>[];

  // Loading indicator
  bool _loading = true;

  // Shared preferences instance
  SharedPreferences _preferences;

  // Account service
  AccountService _as;

  // Error message
  ErrorMessage _error;

  // API response, validation error messages
  String _message;

  _ActivationState() {
    // Create text controllers
    for (int i = 0; i < 6; i++) {
      _inputs[i] = new TextEditingController();
    }
  }

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
    if (_loading) {
      // Use loading animation
      w = new Center(
        child: new Image.asset(
          'assets/images/loading.gif',
          width: 60.0,
          height: 60.0,
        ),
      );
    } else {
      final logo = new Image.asset(
        'assets/images/logo@2x.png',
        width: 128.0,
      );

      // Loading indicator for API requests
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

      final at = '''
      Please enter activation code as one-by-one 
      which sent to your e-mail address
      ''';

      final t = new Text(
        at.replaceAll(new RegExp(r'[\s]{2,}'), ' ').trim(),
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 12.0,
          letterSpacing: 0.33,
          color: ColorConst.grayColor,
        ),
      );

      final items = <Widget>[];
      for (int i = 0; i < 6; i++) {
        // Activation input
        final item = new TextInput(
          controller: _inputs[i],
          style: new TextStyle(
            fontFamily: FontConst.primary,
            fontSize: 14.0,
            letterSpacing: 0.33,
          ),
          validator: (i) {
            if (i.length == 0) {
              return 'All fields are required.';
            }

            return null;
          },
        );

        items.add(item);
      }

      // Activation input items
      final c = new Row(
        children: items,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
      );

      // Create activation submit button
      final aib = new Button(
        text: 'Activation',
        onPressed: _activation,
      );

      // Send activation code button
      final art = new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            'you didn’t receive? ',
            style: new TextStyle(
              fontFamily: FontConst.primary,
              fontSize: 12.0,
              letterSpacing: 0.33,
              color: ColorConst.grayColor,
            ),
          ),
          new GestureDetector(
            onTap: _activation,
            child: new Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: new Text(
                'send again',
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

      // Create main container
      w = new FormValidation(
        key: _formKey,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            pt,
            logo,
            pt,
            t,
            pt,
            s,
            c,
            pt,
            aib,
            pt,
            art,
            pt,
          ],
        ),
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

  void _activation() {}
}
