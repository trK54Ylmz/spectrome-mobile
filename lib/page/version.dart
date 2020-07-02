import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/page/home.dart';
import 'package:spectrome/service/system/version.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';

class VersionPage extends StatefulWidget {
  static final tag = 'version';

  VersionPage() : super();

  @override
  _VersionState createState() => new _VersionState();
}

class _VersionState extends State<VersionPage> {
  // Loading indicator
  bool _loading = true;

  // Error message
  ErrorMessage _error;

  @override
  void initState() {
    super.initState();

    final c = (VersionResponse v) {
      dev.log('Version request sent.');

      if (!v.status) {
        if (v.isNetErr ?? false) {
          // Create network error
          setState(() => _error = ErrorMessage.network());
        } else {
          // Create custom error
          setState(() => _error = ErrorMessage.custom(v.message));
        }

        // Set loading false
        setState(() => _loading = false);
        return;
      }

      // Move to home page
      if (v.version == AppConst.version) {
        Navigator.of(context).pushReplacementNamed(HomePage.tag);
        return;
      }

      // Set loading false
      setState(() => _loading = false);
    };

    // Error callback
    final e = (e, s) {
      // Create unknown error message
      final st = () {
        _loading = false;

        final msg = 'Unknown error. Please try again later.';
        _error = ErrorMessage.custom(msg);
      };

      setState(st);
    };

    VersionService.call().then(c).catchError(e);
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
          height: height,
          child: new Padding(
            padding: EdgeInsets.symmetric(horizontal: pv),
            child: new Center(
              child: getPage(),
            ),
          ),
        ),
      ),
    );
  }

  /// Get content of the version page
  Widget getPage() {
    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
      color: ColorConst.darkGrayColor,
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
          color: ColorConst.grayColor,
          onPressed: () => Navigator.of(context).pushReplacementNamed(VersionPage.tag),
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
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon,
          message,
          button,
        ],
      );
    }

    final icon = new Icon(
      new IconData(
        Platform.isAndroid ? 0xf3ab : 0xf370,
        fontFamily: FontConst.fab,
      ),
      color: ColorConst.grayColor,
      size: 32.0,
    );

    final pt = const Padding(
      padding: EdgeInsets.only(top: 8.0),
    );

    final msg = 'The application requires update.';
    final message = new Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: new Text(msg, style: ts),
    );

    // Update application
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        icon,
        pt,
        message,
      ],
    );
  }
}
