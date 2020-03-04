import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/input.dart';
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
    final pv = width > 400 ? 100.0 : 60.0;

    final pt = const Padding(
      padding: EdgeInsets.only(top: 8.0),
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
    } else if (_error != null) {
      final m = new Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: new Text(_error.error, style: ts),
      );

      // Add re-try button
      final b = new CupertinoButton(
        onPressed: () {
          // Reload home screen
          Navigator.of(context).pushReplacementNamed(SignInPage.tag);
        },
        child: new Text(
          'Try again',
          style: new TextStyle(
            color: const Color(0xffffffff),
            fontFamily: FontConst.primary,
            fontSize: 16.0,
            letterSpacing: 0.33,
          ),
        ),
        color: const Color(0xffaaaaaa),
      );

      // Handle error message
      w = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          m,
          b,
        ],
      );
    } else {
      // Create e-mail address input
      final email = new TextInput(
        hint: 'Username or e-mail address',
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
      final sib = new SizedBox(
        width: double.infinity,
        child: new CupertinoButton(
          onPressed: signIn,
          color: ColorConst.buttonColor,
          borderRadius: BorderRadius.circular(8.0),
          pressedOpacity: 0.9,
          child: new Text(
            'Sign In',
            style: new TextStyle(
              color: const Color(0xffffffff),
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.28,
            ),
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
          sib,
        ],
      );
    }

    return new CupertinoPageScaffold(
      backgroundColor: const Color(0xffffffff),
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: pv),
        child: w,
      ),
    );
  }

  /// Make sign in
  ///
  /// Account service must be initialized
  void signIn() {
    if (_loading) {
      return;
    }

    // Set loading true
    setState(() => _loading = true);

    // Handle HTTP response
    final sc = (SignInResponse r) {
      if (!r.status) {
        if (r.isNetErr) {
          // Create network error
          setState(() => _error = ErrorMessage.network());
        } else {
          setState(() => _error = ErrorMessage.custom(r.message));
        }
        return;
      }

      // Create new auth key
      _preferences.setString('auth', r.auth);

      // Set loading false
      setState(() => _loading = false);
    };

    // Send sign in request
    _as.signIn(_loginId, _password).then(sc);
  }
}
