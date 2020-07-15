import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/page/waterfall.dart';
import 'package:spectrome/service/user/invite.dart';
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

  // First e-mail input controller
  final _first = new TextEditingController();

  // Second e-mail input controller
  final _second = new TextEditingController();

  // Third e-mail input controller
  final _third = new TextEditingController();

  // Number of active inputs
  int _active = 1;

  // Loading indicator
  bool _loading = false;

  // Error message
  ErrorMessage _error;

    // Account session key
  String _session;

  // API response, validation error messages
  String _message;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final c = (SharedPreferences sp) {
      // Remove invite page checker
      sp.remove('_ac');

      _session = sp.getString('_session');

      setState(() => _loading = false);
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
            child: _session == null ? _getLoading() : _getForm(),
          ),
        ),
      ),
    );
  }

  /// Get loading form
  Widget _getLoading() {
    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
    );

    if (_error != null) {
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
          onPressed: () => Navigator.of(context).pushReplacementNamed(InvitePage.tag),
          child: new Text(
            'Try again',
            style: new TextStyle(
              color: ColorConst.white,
              fontFamily: FontConst.primary,
              fontSize: 14.0,
              letterSpacing: 0.33,
            ),
          ),
        ),
      );

      // Handle error
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon,
          message,
          button,
        ],
      );
    }

    // Use loading animation
    return new Center(
      child: new Image.asset(
        'assets/images/loading.gif',
        width: 60.0,
        height: 60.0,
      ),
    );
  }

  /// Get invitation form
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

    final msg = new Text(
      'Would you like to invite up to 3 people?',
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        letterSpacing: 0.33,
        color: ColorConst.darkGrayColor,
      ),
    );

    // First e-mail address input
    final ef = new FormText(
      hint: 'The first e-mail address',
      inputType: TextInputType.emailAddress,
      controller: _first,
      style: ts,
      hintStyle: hs,
      validator: (i) {
        if (i.length == 0) {
          return 'The e-mail address is required.';
        }

        if (i.runes.length < 2) {
          return 'The e-mail address is too short.';
        }

        if (!EmailValidator.validate(i)) {
          return 'The e-mail address is invalid.';
        }

        return null;
      },
      onSaved: (i) {
        final valid = EmailValidator.validate(i);
        setState(() => _active = valid ? 2 : 1);

        return null;
      },
    );

    // First e-mail address input
    final es = new FormText(
        hint: 'The second e-mail address',
        inputType: TextInputType.emailAddress,
        controller: _second,
        enabled: _active >= 2,
        style: ts,
        hintStyle: hs,
        validator: (i) {
          // User may want to skip this input
          if (i.length == 0) {
            return null;
          }

          if (i.runes.length < 2) {
            return 'The e-mail address is too short.';
          }

          if (!EmailValidator.validate(i)) {
            return 'The e-mail address is invalid.';
          }

          return null;
        },
        onSaved: (i) {
          final valid = EmailValidator.validate(i);
          setState(() => _active = valid ? 3 : 2);

          return null;
        });

    // First e-mail address input
    final et = new FormText(
      hint: 'The third e-mail address',
      controller: _third,
      enabled: _active >= 3,
      style: ts,
      hintStyle: hs,
      validator: (i) {
        // User may want to skip this input
        if (i.length == 0) {
          return null;
        }

        if (i.runes.length < 2) {
          return 'The e-mail address is too short.';
        }

        if (!EmailValidator.validate(i)) {
          return 'The e-mail address is invalid.';
        }

        return null;
      },
    );

    // Invite button
    final ib = new Button(
      color: ColorConst.buttonColor,
      text: 'Invite',
      disabled: _loading,
      onPressed: _invite,
    );

    // Skip button
    final skip = new GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed(WaterFallPage.tag),
      child: new Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 4.0,
        ),
        child: new Text(
          'skip',
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
          msg,
          pt,
          s,
          pt,
          ef,
          pt,
          es,
          pt,
          et,
          pt,
          ib,
          ptl,
          skip,
          pt,
        ],
      ),
    );
  }

  /// Make user invitation
  ///
  /// Makes HTTP call
  void _invite() {
    dev.log('Invite button clicked.');

    // Clear message
    setState(() => _message = null);

    if (_loading) {
      return;
    }

    // Validate form key
    if (!_formKey.currentState.validate()) {
      // Create custom error
      setState(() => _message = _formKey.currentState.errors.first);

      return;
    }

    dev.log('Invitation request sending.');

    // Set loading true
    setState(() => _loading = true);

    // Handle HTTP response
    final sc = (InviteResponse r) {
      dev.log('Invitation request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          setState(() => _error = ErrorMessage.network());
        } else {
          // Create custom error
          setState(() => _message = r.message);
        }

        // Set loading false
        setState(() => _loading = false);

        return;
      }

      // Set loading false
      setState(() => _loading = false);

      // Move to activation page
      Navigator.of(context).pushReplacementNamed(WaterFallPage.tag);
    };

    final emails = <String>[_first.text];

    // Add if user specify second e-mail address
    if (_second.text.length != 0) {
      emails.add(_second.text);
    }

    // Add if user specify third e-mail address
    if (_third.text.length != 0) {
      emails.add(_third.text);
    }

    // Send sign up request
    InviteService.call(_session, emails).then(sc);
  }
}
