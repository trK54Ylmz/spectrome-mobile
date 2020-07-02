import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/service/system/version.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
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
        return;
      }
    };

    VersionService.call().then(c);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final pv = width > 400 ? 100.0 : 60.0;

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
    }

    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new SingleChildScrollView(
        child: new Container(
          height: height,
          child: new Padding(
            padding: EdgeInsets.symmetric(horizontal: pv),
            child: w,
          ),
        ),
      ),
    );
  }
}
