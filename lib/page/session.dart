import 'dart:developer' as dev;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/main.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/page/view.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/service/user/location.dart';
import 'package:spectrome/service/account/session.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/notification.dart';
import 'package:spectrome/util/route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/util/storage.dart';

class SessionPage extends StatefulWidget {
  static final tag = 'session';

  SessionPage() : super();

  @override
  _SessionState createState() => new _SessionState();
}

class _SessionState extends State<SessionPage> {
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

      dev.log(msg, stackTrace: s);

      // Create unknown error message
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

    final sc = (SharedPreferences sp, SessionResponse r) async {
      dev.log('Session check request sent.');

      // Account is banned for a while
      if (r.banned) {
        dev.log('Account banned.');
        return;
      }

      // Account removed completely
      if (r.removed) {
        dev.log('Account removed.');
        return;
      }

      // Update new session
      sp.setString('_session', r.session);

      // Create route according to response
      var w;
      if (!r.status || r.expired ?? false) {
        w = routes[SignInPage.tag](context);
      } else {
        w = routes[ViewPage.tag](context);

        // Initialize notification system
        NotificationSystem.init(r.session);

        // Detect location and send by using session code
        final language = ui.window.locale.languageCode;
        final country = ui.window.locale.countryCode;

        if (language != null && country != null) {
          dev.log('Location request sent.');

          // Update location by using session
          LocationService.call(r.session, country.toLowerCase(), language);
        }
      }

      final route = new DefaultRoute(widget: w);

      // Replace page with sign in screen
      await Navigator.of(context).pushReplacement(route);
    };

    // Check session etc.
    final c = (SharedPreferences sp) async {
      final session = sp.getString('_session');

      // route page according to session information
      if (session == null) {
        final r = routes[SignInPage.tag](context);
        final route = new DefaultRoute(widget: r);

        // Replace page with sign in screen
        Navigator.of(context).pushReplacement(route);

        return;
      }

      // Check session and route according to response
      await SessionService.call(session).then((r) => sc(sp, r)).catchError(e);
    };

    Storage.load().then(c).whenComplete(cc);
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
        child: AppConst.loader(
          page: SessionPage.tag,
          argument: _loading,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get main page
  Widget _getPage() {
    // Create empty container if everything is okay
    return new Container();
  }
}
