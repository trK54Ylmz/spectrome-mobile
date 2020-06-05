import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/main.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/page/timeline.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/service/account.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/route.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static final tag = 'home';

  HomePage() : super();

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomePage> {
  // Status of loading anything
  bool _loading = true;

  // Error object
  ErrorMessage _error;

  @override
  void initState() {
    super.initState();

    // Handle exceptions
    final ec = (e, StackTrace s) {
      dev.log(e.toString(), stackTrace: s);

      final m = 'Something wrong happened';
      setState(() => _error = ErrorMessage.custom(m));
    };

    final sc = (SessionResponse res) {
      // Create route according to response
      Widget r;
      if (!res.status || res.expired ?? false) {
        r = routes[SignInPage.tag](context);
      } else {
        r = routes[TimeLinePage.tag](context);
      }

      final route = new DefaultRoute(r);

      // Replace page with sign in screen
      Navigator.of(context).pushReplacement(route);

      setState(() => _loading = false);
    };

    // Check session etc.
    final c = (SharedPreferences sp) async {
      final session = sp.getString('_session');

      // route page according to session information
      if (session == null) {
        final r = routes[SignInPage.tag](context);
        final route = new DefaultRoute(r);

        // Replace page with sign in screen
        Navigator.of(context).pushReplacement(route);

        setState(() => _loading = false);
        return;
      }

      final _as = new AccountService();

      // Check session and route according to response
      _as.checkSession(session).then(sc).catchError(ec);  
    };

    // Show loading icon when screen initialized
    setState(() => _loading = true);

    SharedPreferences.getInstance().then(c);
  }

  @override
  Widget build(BuildContext context) {
    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      color: ColorConst.grayColor,
      fontSize: 14.0,
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
          onPressed: () {
            // Reload home screen
            Navigator.of(context).pushReplacementNamed(HomePage.tag);
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
          color: ColorConst.grayColor,
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
      // Create empty container if everything is okay
      w = new Container(color: const Color(0xffffffff));
    }

    // Show loading icon
    return new Container(
      color: const Color(0xffffffff),
      child: w,
    );
  }
}
