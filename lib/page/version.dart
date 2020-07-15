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

    final c = (VersionResponse v) async {
      dev.log('Version request sent.');

      if (!v.status) {
        if (v.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          _error = ErrorMessage.custom(v.message);
        }
        return;
      }

      // Move to home page
      if (v.version == AppConst.version) {
        await Navigator.of(context).pushReplacementNamed(HomePage.tag);
      }
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Create error message
      _error = ErrorMessage.custom(msg);
    };

    // Complete callback
    final cc = () {
      setState(() => _loading = false);
    };

    VersionService.call().then(c).catchError(e).whenComplete(cc);
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
              child: AppConst.loader(context, _loading, _error, _getPage),
            ),
          ),
        ),
      ),
    );
  }

  /// Get content of the version page
  Widget _getPage() {
    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
      color: ColorConst.darkGrayColor,
    );

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
