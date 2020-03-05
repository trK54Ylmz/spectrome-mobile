import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/main.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/route.dart';

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

    // Check session etc.
    final c = (_) {
      final s = routes[SignInPage.tag](context);
      final route = new DefaultRoute(s);

      // Replace page with sign in screen
      Navigator.of(context).pushReplacement(route);

      setState(() => _loading = false);
    };

    // Handle exceptions
    final ec = (e, StackTrace s) {
      dev.log(e.toString(), stackTrace: s);

      final m = 'Something wrong happened';
      setState(() => _error = ErrorMessage.custom(m));
    };

    // Show loading icon when screen initialized
    setState(() => _loading = true);

    // Initialize http client and check session
    Http.init().then(c).catchError(ec);
  }

  @override
  Widget build(BuildContext context) {
    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      color: const Color(0xffaaaaaa),
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
        color: const Color(0xffaaaaaa),
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
          color: const Color(0xffaaaaaa),
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
