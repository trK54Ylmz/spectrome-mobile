import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/page/sign_up_done.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/service/account/activate.dart';
import 'package:spectrome/service/account/activation.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
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
  final _fk = new GlobalKey<FormValidationState>();

  // Code input controller group
  final _inputs = <TextEditingController>[];

  // Code input focus node group
  final _focuses = <FocusNode>[];

  // Loading indicator
  bool _loading = true;

  // Resend request loading indicator;
  bool _sending = false;

  // Shared preferences instance
  SharedPreferences _sp;

  // Token code from sign in response
  String _token;

  // Error message
  ErrorMessage _error;

  // API response, validation error messages
  String _message;

  // The last time activation code has been sent
  DateTime _lastSent;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      _sp = s;

      // Set token code
      _token = s.getString('_st');

      // Remove code from shared preferences store
      s.remove('_st');

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
            child: AppConst.loader(
              page: ActivationPage.tag,
              argument: _sp == null,
              error: _error,
              callback: _getForm,
            ),
          ),
        ),
      ),
    );
  }

  /// Get activation form
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

    // Loading indicator for API requests
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

    final t = new Text(
      'Please enter 6 digits which we have sent to your e-mail address.',
      textAlign: TextAlign.center,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        letterSpacing: 0.33,
        color: ColorConst.gray,
      ),
    );

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

    // Create activation submit button
    final aib = new Button(
      text: 'Complete',
      disabled: _loading,
      onPressed: _activate,
    );

    // Send activation code button
    final cl = _sending ? ColorConst.gray.withOpacity(0.14) : ColorConst.gray;
    final art = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          'you didn’t receive? ',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            fontSize: 12.0,
            letterSpacing: 0.33,
            color: cl,
          ),
        ),
        new GestureDetector(
          onTap: () {
            if (_sending) {
              return;
            }

            final now = DateTime.now();

            // Check that if we already sent activation code
            if (_lastSent != null && now.difference(_lastSent).inSeconds < 10) {
              setState(() => _message = 'Activation code has been sent recently.');

              // Clear message 5 seconds later
              final c = (_) => setState(() => _message = null);
              Future.delayed(Duration(seconds: 5)).then(c);

              return;
            }

            _lastSent = now;

            _activation();
          },
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
                color: cl,
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
          ptl,
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

  /// Create and send activation code request
  void _activate() {
    dev.log('Activation button clicked.');

    if (_loading) {
      return;
    }

    // Clear message
    setState(() => _message = null);

    // Validate form key
    if (!_fk.currentState.validate()) {
      // Create custom error
      setState(() => _message = _fk.currentState.errors.first);

      return;
    }

    dev.log('Activation request sending.');

    // Set loading true
    setState(() => _loading = true);

    final sc = (ActivateResponse r) async {
      dev.log('Activation request sent.');

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

      // Create new auth key
      _sp.setString('_session', r.session);

      // Route to sign up complete page
      await Navigator.of(context).pushReplacementNamed(SignUpDonePage.tag);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown activate error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create error message
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

    // Create activation code as integer
    final buffer = <String>[];
    for (int i = 0; i < 6; i++) {
      buffer.add(_inputs[i].text);
    }

    // Send activation request
    final code = buffer.join();
    ActivateService.call(code, _token).then(sc).catchError(e).whenComplete(cc);
  }

  void _activation() {
    dev.log('Resend activation button clicked.');

    // Clear message
    _message = null;
    if (_sending) {
      return;
    }

    if (_token == null) {
      _message = 'The token is required.';
      return;
    }

    setState(() => _sending = true);

    dev.log('Resend request sending.');

    final sc = (ActivationResponse r) {
      dev.log('Resend request sent.');

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

      // Update sign in token
      _token = r.token;
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown activation error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create error message
      _error = ErrorMessage.custom(msg);
    };

    // Complete callback
    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _sending = false);
    };

    // Send activation code again by using request
    ActivationService.call(_token).then(sc).catchError(e).whenComplete(cc);
  }
}
