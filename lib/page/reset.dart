import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/account/reset.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';

class ResetPage extends StatefulWidget {
  static final tag = 'reset';

  ResetPage() : super();

  @override
  _ResetState createState() => new _ResetState();
}

class _ResetState extends State<ResetPage> {
  // Form validation key
  final _formKey = GlobalKey<FormValidationState>();

  // Code input controller group
  final _inputs = <TextEditingController>[];

  // Code input focus node group
  final _focuses = <FocusNode>[];

  // Password input controller
  final _password = new TextEditingController();

  // Loading indicator
  bool _loading = false;

  // Shared preferences instance
  SharedPreferences _sp;

  // Error message
  ErrorMessage _error;

  // API response, validation error messages
  String _message;

  /// Forgot password token
  String _token;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      _sp = s;

      // Set token code
      _token = s.getString('_fpt');

      // Remove code from shared preferences store
      s.remove('_fpt');

      setState(() => _loading = false);
    };

    Storage.load().then(spc);

    // Create text controllers
    for (int i = 0; i < 6; i++) {
      _inputs.add(new TextEditingController());
      _focuses.add(new FocusNode());
    }

    final dcb = (_) {
      _focuses[0].requestFocus();
    };

    // Focus to first input
    WidgetsBinding.instance.addPostFrameCallback(dcb);
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    for (int i = 0; i < 6; i++) {
      _inputs[i].dispose();
      _focuses[i].dispose();
    }

    super.dispose();
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
      'Please enter code you have received and your new password.',
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

    final items = <Widget>[];
    for (int i = 0; i < 6; i++) {
      // Activation input
      final item = new Padding(
        padding: EdgeInsets.only(right: i < 5 ? 4.0 : 0.0),
        child: new Container(
          width: 34.0,
          child: new FormText(
            controller: _inputs[i],
            focusNode: _focuses[i],
            inputType: TextInputType.number,
            textAlign: TextAlign.center,
            size: 1,
            cursorWidth: 1.0,
            style: new TextStyle(
              fontFamily: FontConst.primary,
              fontSize: 24.0,
              letterSpacing: 0.0,
            ),
            onChange: (i) {
              int index = 0;
              for (int i = 0; i < 6; i++) {
                if (_focuses[i].hasFocus) {
                  index = i;
                  break;
                }
              }

              if (i.length > 0 && index < 5) {
                _focuses[index + 1].requestFocus();
              }

              if (i.length == 0 && index > 0) {
                _focuses[index - 1].requestFocus();
              }

              return null;
            },
            validator: (i) {
              if (i.length == 0) {
                return 'All fields are required.';
              }

              return null;
            },
          ),
        ),
      );

      items.add(item);
    }

    // Activation input items
    final c = new Row(
      children: items,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
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

    // Reset password submit button
    final fpb = new Button(
      text: 'Change password',
      disabled: _loading,
      onPressed: _reset,
    );

    // Sign in page button
    final sib = new Button(
      text: 'Sign In',
      disabled: _loading,
      background: ColorConst.grayColor,
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
          c,
          pt,
          password,
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
  void _reset() {
    dev.log('Reset password button clicked.');

    // Clear message
    _message = null;

    if (_loading) {
      return;
    }

    setState(() => _loading = true);

    dev.log('Resend request sending.');

    final sc = (ResetResponse r) async {
      dev.log('Reset password request sent.');

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

      // Clear API response message
      _message = null;

      await Navigator.of(context).pushReplacementNamed(SignInPage.tag);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _loading = false);
    };

    // Create activation code as integer
    final buffer = <String>[];
    for (int i = 0; i < 6; i++) {
      buffer.add(_inputs[i].text);
    }

    // Send activation request
    final c = buffer.join();
    final p = _password.text;

    // Send activation code again by using request
    ResetService.call(c, p, _token).then(sc).catchError(e).whenComplete(cc);
  }
}
