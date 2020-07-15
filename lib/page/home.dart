import 'dart:developer' as dev;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/main.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/page/waterfall.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/service/user/location.dart';
import 'package:spectrome/service/account/session.dart';
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

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    // Complete callback
    final cc = () {
      setState(() => _loading = false);
    };

    final sc = (SharedPreferences sp, SessionResponse res) {
      dev.log('Session check request sent.');

      // Update new session
      sp.setString('_session', res.session);

      // Create route according to response
      Widget r;
      if (!res.status || res.expired ?? false) {
        r = routes[SignInPage.tag](context);
      } else {
        r = routes[WaterFallPage.tag](context);

        // Detect location and send by using session code
        final language = ui.window.locale.languageCode;
        final country = ui.window.locale.countryCode.toLowerCase();

        dev.log('Location request sent.');

        // Update location by using session
        LocationService.call(res.session, country, language);
      }

      final route = new DefaultRoute(r);

      // Replace page with sign in screen
      Navigator.of(context).pushReplacement(route);
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

        return;
      }

      // Check session and route according to response
      await SessionService.call(session).then((r) => sc(sp, r)).catchError(e);
    };

    SharedPreferences.getInstance().then(c).whenComplete(cc);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final pv = width > 400 ? 100.0 : 60.0;

    // Show loading icon
    return new Container(
      color: ColorConst.white,
      width: width,
      height: height,
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: pv),
        child: _getPage(),
      ),
    );
  }

  /// Get main page
  Widget _getPage() {
    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      color: ColorConst.grayColor,
      fontSize: 14.0,
    );

    if (_loading) {
      // Use loading animation
      return new Center(
        child: new Image.asset(
          'assets/images/loading.gif',
          width: 60.0,
          height: 60.0,
        ),
      );
    }

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
          onPressed: () {
            // Reload home screen
            Navigator.of(context).pushReplacementNamed(HomePage.tag);
          },
          child: new Text(
            'Try again',
            style: new TextStyle(
              color: ColorConst.white,
              fontFamily: FontConst.primary,
              fontSize: 14.0,
              letterSpacing: 0.33,
            ),
          ),
          color: ColorConst.grayColor,
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

    // Create empty container if everything is okay
    return new Container(
      color: ColorConst.white,
    );
  }
}
