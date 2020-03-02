import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/main.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/util/http.dart';
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

  // Network error object
  bool _nerr = false;

  // Error message
  String _error;

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

      setState(() => _error = 'Something wrong happened');
    };

    // Show loading icon when screen initialized
    setState(() => _loading = true);

    // Initialize http client and check session
    Http.init().then(c).catchError(ec);
  }

  @override
  Widget build(BuildContext context) {
    final ts = new TextStyle(
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
    } else if (_nerr) {
      final icon = new Icon(
        const IconData(0xffff),
        size: 32.0,
      );

      final message = new Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: new Text(
          'Please check your network connection',
          style: ts,
        ),
      );

      // Add re-try button
      final button = new Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: new CupertinoButton(
          onPressed: () {
            // Reload home screen
            Navigator.of(context).pushReplacementNamed(HomePage.tag);
          },
          child: new Text(
            'Try again',
            style: new TextStyle(
              color: const Color(0xffffffff),
            ),
          ),
          color: const Color(0xffaaaaaa),
        ),
      );

      // Handle network error
      w = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon,
          message,
          button,
        ],
      );
    } else if (_error != null) {
      final m = new Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: new Text(_error, style: ts),
      );

      // Add re-try button
      final b = new CupertinoButton(
        onPressed: () {
          // Reload home screen
          Navigator.of(context).pushReplacementNamed(HomePage.tag);
        },
        child: new Text(
          'Try again',
          style: new TextStyle(
            color: const Color(0xffffffff),
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
